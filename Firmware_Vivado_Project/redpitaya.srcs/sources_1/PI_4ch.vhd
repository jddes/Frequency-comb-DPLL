library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- unwraps from 14 to 25 bits, integrate and dump, filter with PI loop filter, add offset, apply limits
entity PI_4ch is
Generic (
    INPUT_WIDTH     : integer := 14;
    UNWRAPPED_WIDTH : integer := 25;
    COUNTER_WIDTH   : integer := 32;
    OUTPUT_WIDTH    : integer := 48;
    N_CHANNELS : integer := 4 -- can't change this without rewriting the module partially
);
port (
    clk               : in  std_logic;

    -- four-channel phase data inputs
    -- designed for input rate at clk/6
    clk_enable_in     : in  std_logic;
    wrapped_phase_in1 : in  std_logic_vector(INPUT_WIDTH-1 downto 0);
    wrapped_phase_in2 : in  std_logic_vector(INPUT_WIDTH-1 downto 0);
    wrapped_phase_in3 : in  std_logic_vector(INPUT_WIDTH-1 downto 0);
    wrapped_phase_in4 : in  std_logic_vector(INPUT_WIDTH-1 downto 0);

    -- config port:
    n_cycles          : in  std_logic_vector(COUNTER_WIDTH-1 downto 0);

    P_enable : in  std_logic_vector(N_CHANNELS-1 downto 0); -- one enable per channel
    I_enable : in  std_logic_vector(N_CHANNELS-1 downto 0); -- one enable per channel

    gain_fine1        : in  std_logic_vector(4-1 downto 0); -- signed: also sets the overall loop sign
    gain_fine2        : in  std_logic_vector(4-1 downto 0); -- signed: also sets the overall loop sign
    gain_fine4        : in  std_logic_vector(4-1 downto 0); -- signed: also sets the overall loop sign
    gain_fine3        : in  std_logic_vector(4-1 downto 0); -- signed: also sets the overall loop sign

    P_gain_coarse1    : in  std_logic_vector(6-1 downto 0); -- max is 48 bits shift
    P_gain_coarse2    : in  std_logic_vector(6-1 downto 0); -- max is 48 bits shift
    P_gain_coarse3    : in  std_logic_vector(6-1 downto 0); -- max is 48 bits shift
    P_gain_coarse4    : in  std_logic_vector(6-1 downto 0); -- max is 48 bits shift

    I_gain_coarse1    : in  std_logic_vector(6-1 downto 0); -- max is 48 bits shift
    I_gain_coarse2    : in  std_logic_vector(6-1 downto 0); -- max is 48 bits shift
    I_gain_coarse3    : in  std_logic_vector(6-1 downto 0); -- max is 48 bits shift
    I_gain_coarse4    : in  std_logic_vector(6-1 downto 0); -- max is 48 bits shift

    manual_offset_changed : in  std_logic_vector(N_CHANNELS-1 downto 0);
    manual_offset1 : in  std_logic_vector(OUTPUT_WIDTH-1 downto 0);
    manual_offset2 : in  std_logic_vector(OUTPUT_WIDTH-1 downto 0);
    manual_offset3 : in  std_logic_vector(OUTPUT_WIDTH-1 downto 0);
    manual_offset4 : in  std_logic_vector(OUTPUT_WIDTH-1 downto 0);

    limit_high1 : in  std_logic_vector(16-1 downto 0); -- these get multiplied by 48-16 internally to save a few registers
    limit_high2 : in  std_logic_vector(16-1 downto 0); -- these get multiplied by 48-16 internally to save a few registers
    limit_high3 : in  std_logic_vector(16-1 downto 0); -- these get multiplied by 48-16 internally to save a few registers
    limit_high4 : in  std_logic_vector(16-1 downto 0); -- these get multiplied by 48-16 internally to save a few registers

    limit_low1  : in  std_logic_vector(16-1 downto 0); -- these get multiplied by 48-16 internally to save a few registers
    limit_low2  : in  std_logic_vector(16-1 downto 0); -- these get multiplied by 48-16 internally to save a few registers
    limit_low3  : in  std_logic_vector(16-1 downto 0); -- these get multiplied by 48-16 internally to save a few registers
    limit_low4  : in  std_logic_vector(16-1 downto 0); -- these get multiplied by 48-16 internally to save a few registers

    -- register interface, for setting up the dithers
    cmd_trig    : in  std_logic;
    cmd_addr    : in  std_logic_vector(32-1 downto 0);
    cmd_data    : in  std_logic_vector(32-1 downto 0);

    -- status registers, containing the results of the dither lock-ins:
    dither_results1 : out std_logic_vector(64-1 downto 0);
    dither_results2 : out std_logic_vector(64-1 downto 0);
    dither_results3 : out std_logic_vector(64-1 downto 0);
    dither_results4 : out std_logic_vector(64-1 downto 0);

    -- four-channel of frequency control efforts,
    -- meant to go to DDSes
    -- output rate is input rate/n_cyles
    clk_enable_out : out std_logic;
    freq_out1      : out std_logic_vector(OUTPUT_WIDTH-1 downto 0);
    freq_out2      : out std_logic_vector(OUTPUT_WIDTH-1 downto 0);
    freq_out3      : out std_logic_vector(OUTPUT_WIDTH-1 downto 0);
    freq_out4      : out std_logic_vector(OUTPUT_WIDTH-1 downto 0)
    );
end entity;

architecture Behavioral of PI_4ch is
    type addresses_type is array (0 to N_CHANNELS-1) of integer;
    constant DITHER_BASE_ADDRESS : addresses_type := (16#100#, 16#110#, 16#120#, 16#130#);

    type unwrapped_phases_type is array (0 to N_CHANNELS-1) of std_logic_vector(UNWRAPPED_WIDTH-1 downto 0);
    type freq_output_type      is array (0 to N_CHANNELS-1) of std_logic_vector(OUTPUT_WIDTH-1 downto 0);
    type fine_gain_type        is array (0 to N_CHANNELS-1) of std_logic_vector(4-1 downto 0);
    type coarse_gain_type      is array (0 to N_CHANNELS-1) of std_logic_vector(6-1 downto 0);
    type dither_results_type   is array (0 to N_CHANNELS-1) of std_logic_vector(64-1 downto 0);
    signal gain_fines     : fine_gain_type;
    signal P_gain_coarses : coarse_gain_type;
    signal I_gain_coarses : coarse_gain_type;



    signal phi_integrated_clk_enable : std_logic := '0';
    signal phi_unwrapped  : unwrapped_phases_type := (others => (others => '0'));
    signal phi_integrated : unwrapped_phases_type := (others => (others => '0'));

    signal railed_high           : std_logic_vector(N_CHANNELS-1 downto 0) := (others => '0');
    signal railed_low            : std_logic_vector(N_CHANNELS-1 downto 0) := (others => '0');
    signal PI_output_clk_enable  : std_logic_vector(N_CHANNELS-1 downto 0) := (others => '0');
    signal sum_output_clk_enable : std_logic_vector(N_CHANNELS-1 downto 0) := (others => '0');
    signal PI_data_out           : freq_output_type;
    signal summing_data_out      : freq_output_type;
    signal limits_high           : freq_output_type;
    signal limits_low            : freq_output_type;
    signal manual_offset         : freq_output_type;
    signal dither_out            : freq_output_type;

    signal dither_results : dither_results_type;

    signal reset_offset1 : std_logic := '0';
    signal reset_offset2 : std_logic := '0';
    signal reset_offset3 : std_logic := '0';
    signal reset_offset4 : std_logic := '0';
    signal P_enable_d1 : std_logic_vector(N_CHANNELS-1 downto 0) := (others => '0');

    --attribute mark_debug : string;
    --attribute mark_debug of wrapped_phase_in1: signal is "True";
    --attribute mark_debug of phi_integrated:    signal is "True";
    --attribute mark_debug of phi_unwrapped:     signal is "True";
begin

    -- unwraps from 14 to 25 bits, integrate and dump
    unwrap_integrate_and_dump_4ch_inst : entity work.unwrap_integrate_and_dump_4ch
    generic map (
        INPUT_WIDTH     => INPUT_WIDTH,
        UNWRAPPED_WIDTH => UNWRAPPED_WIDTH,
        COUNTER_WIDTH   => COUNTER_WIDTH
    ) port map (
        clk                        => clk,
        clk_enable_in              => clk_enable_in,
        wrapped_phase_in1          => wrapped_phase_in1,
        wrapped_phase_in2          => wrapped_phase_in2,
        wrapped_phase_in3          => wrapped_phase_in3,
        wrapped_phase_in4          => wrapped_phase_in4,
        n_cycles                   => n_cycles,
        reset_offset1              => reset_offset1,
        reset_offset2              => reset_offset2,
        reset_offset3              => reset_offset3,
        reset_offset4              => reset_offset4,
        unwrapped_phase_clk_enable => open,
        unwrapped_phase1           => phi_unwrapped(0),
        unwrapped_phase2           => phi_unwrapped(1),
        unwrapped_phase3           => phi_unwrapped(2),
        unwrapped_phase4           => phi_unwrapped(3),
        phi_integrated_clk_enable  => phi_integrated_clk_enable,
        phi_integrated1            => phi_integrated(0),
        phi_integrated2            => phi_integrated(1),
        phi_integrated3            => phi_integrated(2),
        phi_integrated4            => phi_integrated(3)
    );


    gen_backend : for I in 0 to 3 generate
        -- filter each phase with PI loop filter
        PI_loop_filter_inst : entity work.PI_loop_filter
        generic map (
            INPUT_WIDTH  => UNWRAPPED_WIDTH,
            OUTPUT_WIDTH => OUTPUT_WIDTH
        ) port map (
            clk                => clk,
            input_clk_enable   => phi_integrated_clk_enable,
            unwrapped_phase_in =>       phi_integrated(I),
            gain_fine          =>           gain_fines(I),
            P_gain_coarse      =>       P_gain_coarses(I),
            I_gain_coarse      =>       I_gain_coarses(I),
            P_enable           =>             P_enable(I),
            I_enable           =>             I_enable(I),
            railed_high        =>          railed_high(I),
            railed_low         =>           railed_low(I),
            output_clk_enable  => PI_output_clk_enable(I),
            data_out           =>          PI_data_out(I)
        );
        -- generate dither:
        dither_lockin_wrapper_inst : entity work.dither_lockin_wrapper
        generic map (
            BASE_ADDRESS     => DITHER_BASE_ADDRESS(I),
            N_BITS_INPUT     => UNWRAPPED_WIDTH,
            N_BITS_OUTPUT    => OUTPUT_WIDTH,
            INTEGRATORS_BITS => dither_results1'length
        ) port map (
            clk               => clk,
            data_input        => (others => '0'), --phi_unwrapped(I), TODO! I think I have to subtract at least the first point before accumulating summing/subtracting the results, so that we handle the case of a phase near the rail properly
            cmd_trig          => cmd_trig,
            cmd_addr          => cmd_addr,
            cmd_data          => cmd_data,
            output_to_dac     => dither_out(I),
            results_output_I  => dither_results(I),
            results_output_Q  => open,
            output_clk_enable => open
        );

        -- add offset and dither, apply limits
        output_summing_inst : entity work.output_summing
        generic map (
            INPUT_SIZE  => OUTPUT_WIDTH,
            OUTPUT_SIZE => OUTPUT_WIDTH,
            GUARD_BITS  => 2
        ) port map (
            clk               =>                      clk,
            input_clk_enable  =>  PI_output_clk_enable(I) or manual_offset_changed(I),
            in0               =>           PI_data_out(I),
            in1               =>         manual_offset(I),
            in2               =>            dither_out(I),
            in3               =>          (others => '0'),
            output_clk_enable => sum_output_clk_enable(I),
            data_output       =>      summing_data_out(I),
            positive_limit    =>           limits_high(I),
            negative_limit    =>            limits_low(I),
            railed_positive   =>           railed_high(I),
            railed_negative   =>            railed_low(I)
        );

    end generate;

    -- reset phase unwrap each time we start the PI:
    -- this does rising edge detection on each P_enable(I) signal
    process (clk)
    begin
        if rising_edge(clk) then
            P_enable_d1 <= P_enable;

            reset_offset1 <= '0';
            if P_enable(0) = '1' and P_enable_d1(0) = '0' then
                reset_offset1 <= '1';
            end if;

            reset_offset2 <= '0';
            if P_enable(1) = '1' and P_enable_d1(1) = '0' then
                reset_offset2 <= '1';
            end if;

            reset_offset3 <= '0';
            if P_enable(2) = '1' and P_enable_d1(2) = '0' then
                reset_offset3 <= '1';
            end if;

            reset_offset4 <= '0';
            if P_enable(3) = '1' and P_enable_d1(3) = '0' then
                reset_offset4 <= '1';
            end if;
        end if;
    end process;

    -- Assignments needed to interface the generate statement and the external interface (which we want to keep simple):
    gain_fines(0) <= gain_fine1;
    gain_fines(1) <= gain_fine2;
    gain_fines(2) <= gain_fine3;
    gain_fines(3) <= gain_fine4;

    P_gain_coarses(0) <= P_gain_coarse1;
    P_gain_coarses(1) <= P_gain_coarse2;
    P_gain_coarses(2) <= P_gain_coarse3;
    P_gain_coarses(3) <= P_gain_coarse4;

    I_gain_coarses(0) <= I_gain_coarse1;
    I_gain_coarses(1) <= I_gain_coarse2;
    I_gain_coarses(2) <= I_gain_coarse3;
    I_gain_coarses(3) <= I_gain_coarse4;

    limits_high(0) <= std_logic_vector(shift_left(resize(signed(limit_high1), OUTPUT_WIDTH), OUTPUT_WIDTH-limit_high1'length));
    limits_high(1) <= std_logic_vector(shift_left(resize(signed(limit_high2), OUTPUT_WIDTH), OUTPUT_WIDTH-limit_high1'length));
    limits_high(2) <= std_logic_vector(shift_left(resize(signed(limit_high3), OUTPUT_WIDTH), OUTPUT_WIDTH-limit_high1'length));
    limits_high(3) <= std_logic_vector(shift_left(resize(signed(limit_high4), OUTPUT_WIDTH), OUTPUT_WIDTH-limit_high1'length));

    limits_low(0) <= std_logic_vector(shift_left(resize(signed(limit_low1), OUTPUT_WIDTH), OUTPUT_WIDTH-limit_high1'length));
    limits_low(1) <= std_logic_vector(shift_left(resize(signed(limit_low2), OUTPUT_WIDTH), OUTPUT_WIDTH-limit_high1'length));
    limits_low(2) <= std_logic_vector(shift_left(resize(signed(limit_low3), OUTPUT_WIDTH), OUTPUT_WIDTH-limit_high1'length));
    limits_low(3) <= std_logic_vector(shift_left(resize(signed(limit_low4), OUTPUT_WIDTH), OUTPUT_WIDTH-limit_high1'length));

    manual_offset(0) <= manual_offset1;
    manual_offset(1) <= manual_offset2;
    manual_offset(2) <= manual_offset3;
    manual_offset(3) <= manual_offset4;

    clk_enable_out <= sum_output_clk_enable(0);
    freq_out1 <= summing_data_out(0);
    freq_out2 <= summing_data_out(1);
    freq_out3 <= summing_data_out(2);
    freq_out4 <= summing_data_out(3);

    dither_results1 <= dither_results(0);
    dither_results2 <= dither_results(1);
    dither_results3 <= dither_results(2);
    dither_results4 <= dither_results(3);
end;
