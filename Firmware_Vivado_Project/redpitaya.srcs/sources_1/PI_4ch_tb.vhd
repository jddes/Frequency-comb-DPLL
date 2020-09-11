library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

entity PI_4ch_tb is
end PI_4ch_tb;

architecture behavior of PI_4ch_tb is

    -- PI_4ch signals
    -- Generics as constants
    constant INPUT_WIDTH     : integer := 14;
    constant UNWRAPPED_WIDTH : integer := 25;
    constant COUNTER_WIDTH   : integer := 32;
    constant OUTPUT_WIDTH    : integer := 48;
    constant N_CHANNELS      : integer := 4;
    type two_dim_array is array (natural range <>, natural range <>) of std_logic;
    -- Inputs
    signal clk               : std_logic                                  := '0';
    signal clk_enable_in     : std_logic                                  := '0';
    signal wrapped_phase_in1 : std_logic_vector(INPUT_WIDTH-1 downto 0)   := (others => '0');
    signal wrapped_phase_in2 : std_logic_vector(INPUT_WIDTH-1 downto 0)   := (others => '0');
    signal wrapped_phase_in3 : std_logic_vector(INPUT_WIDTH-1 downto 0)   := (others => '0');
    signal wrapped_phase_in4 : std_logic_vector(INPUT_WIDTH-1 downto 0)   := (others => '0');
    signal n_cycles          : std_logic_vector(COUNTER_WIDTH-1 downto 0) := std_logic_vector(to_unsigned(10, 32));
    signal P_enable          : std_logic_vector(N_CHANNELS-1 downto 0)    := (others => '1');
    signal I_enable          : std_logic_vector(N_CHANNELS-1 downto 0)    := (others => '0');
    signal gain_fine1        : std_logic_vector(4-1 downto 0)             := std_logic_vector(to_signed(3, 4));
    signal gain_fine2        : std_logic_vector(4-1 downto 0)             := std_logic_vector(to_signed(3, 4));
    signal gain_fine4        : std_logic_vector(4-1 downto 0)             := std_logic_vector(to_signed(3, 4));
    signal gain_fine3        : std_logic_vector(4-1 downto 0)             := std_logic_vector(to_signed(3, 4));
    signal P_gain_coarse1    : std_logic_vector(6-1 downto 0)             := (others => '0');
    signal P_gain_coarse2    : std_logic_vector(6-1 downto 0)             := (others => '0');
    signal P_gain_coarse3    : std_logic_vector(6-1 downto 0)             := (others => '0');
    signal P_gain_coarse4    : std_logic_vector(6-1 downto 0)             := (others => '0');
    signal I_gain_coarse1    : std_logic_vector(6-1 downto 0)             := (others => '0');
    signal I_gain_coarse2    : std_logic_vector(6-1 downto 0)             := (others => '0');
    signal I_gain_coarse3    : std_logic_vector(6-1 downto 0)             := (others => '0');
    signal I_gain_coarse4    : std_logic_vector(6-1 downto 0)             := (others => '0');
    signal manual_offset1    : std_logic_vector(OUTPUT_WIDTH-1 downto 0)  := (others => '0');
    signal manual_offset2    : std_logic_vector(OUTPUT_WIDTH-1 downto 0)  := (others => '0');
    signal manual_offset3    : std_logic_vector(OUTPUT_WIDTH-1 downto 0)  := (others => '0');
    signal manual_offset4    : std_logic_vector(OUTPUT_WIDTH-1 downto 0)  := (others => '0');
    signal limit_high1       : std_logic_vector(16-1 downto 0)            := std_logic_vector(to_signed(2**15-1, 16));
    signal limit_high2       : std_logic_vector(16-1 downto 0)            := std_logic_vector(to_signed(2**15-1, 16));
    signal limit_high3       : std_logic_vector(16-1 downto 0)            := std_logic_vector(to_signed(2**15-1, 16));
    signal limit_high4       : std_logic_vector(16-1 downto 0)            := std_logic_vector(to_signed(2**15-1, 16));
    signal limit_low1        : std_logic_vector(16-1 downto 0)            := std_logic_vector(to_signed(-2**15, 16));
    signal limit_low2        : std_logic_vector(16-1 downto 0)            := std_logic_vector(to_signed(-2**15, 16));
    signal limit_low3        : std_logic_vector(16-1 downto 0)            := std_logic_vector(to_signed(-2**15, 16));
    signal limit_low4        : std_logic_vector(16-1 downto 0)            := std_logic_vector(to_signed(-2**15, 16));
    signal cmd_trig          : std_logic                                  := '0';
    signal cmd_addr          : std_logic_vector(32-1 downto 0)            := (others => '0');
    signal cmd_data          : std_logic_vector(32-1 downto 0)            := (others => '0');
    -- Outputs
    signal dither_results1 : std_logic_vector(64-1 downto 0);
    signal dither_results2 : std_logic_vector(64-1 downto 0);
    signal dither_results3 : std_logic_vector(64-1 downto 0);
    signal dither_results4 : std_logic_vector(64-1 downto 0);
    signal clk_enable_out  : std_logic;
    signal freq_out1       : std_logic_vector(OUTPUT_WIDTH-1 downto 0);
    signal freq_out2       : std_logic_vector(OUTPUT_WIDTH-1 downto 0);
    signal freq_out3       : std_logic_vector(OUTPUT_WIDTH-1 downto 0);
    signal freq_out4       : std_logic_vector(OUTPUT_WIDTH-1 downto 0);

    -- Clock period definition
    constant clk_period : time := 5 ns;
begin

    -- Unit under test
    PI_4ch_inst : entity work.PI_4ch
    generic map (
        INPUT_WIDTH     => INPUT_WIDTH,
        UNWRAPPED_WIDTH => UNWRAPPED_WIDTH,
        COUNTER_WIDTH   => COUNTER_WIDTH,
        OUTPUT_WIDTH    => OUTPUT_WIDTH,
        N_CHANNELS      => N_CHANNELS
    ) port map (
        clk               => clk,
        clk_enable_in     => clk_enable_in,
        wrapped_phase_in1 => wrapped_phase_in1,
        wrapped_phase_in2 => wrapped_phase_in2,
        wrapped_phase_in3 => wrapped_phase_in3,
        wrapped_phase_in4 => wrapped_phase_in4,
        n_cycles          => n_cycles,
        P_enable          => P_enable,
        I_enable          => I_enable,
        gain_fine1        => gain_fine1,
        gain_fine2        => gain_fine2,
        gain_fine4        => gain_fine4,
        gain_fine3        => gain_fine3,
        P_gain_coarse1    => P_gain_coarse1,
        P_gain_coarse2    => P_gain_coarse2,
        P_gain_coarse3    => P_gain_coarse3,
        P_gain_coarse4    => P_gain_coarse4,
        I_gain_coarse1    => I_gain_coarse1,
        I_gain_coarse2    => I_gain_coarse2,
        I_gain_coarse3    => I_gain_coarse3,
        I_gain_coarse4    => I_gain_coarse4,
        manual_offset1    => manual_offset1,
        manual_offset2    => manual_offset2,
        manual_offset3    => manual_offset3,
        manual_offset4    => manual_offset4,
        limit_high1       => limit_high1,
        limit_high2       => limit_high2,
        limit_high3       => limit_high3,
        limit_high4       => limit_high4,
        limit_low1        => limit_low1,
        limit_low2        => limit_low2,
        limit_low3        => limit_low3,
        limit_low4        => limit_low4,
        cmd_trig          => cmd_trig,
        cmd_addr          => cmd_addr,
        cmd_data          => cmd_data,
        dither_results1   => dither_results1,
        dither_results2   => dither_results2,
        dither_results3   => dither_results3,
        dither_results4   => dither_results4,
        clk_enable_out    => clk_enable_out,
        freq_out1         => freq_out1,
        freq_out2         => freq_out2,
        freq_out3         => freq_out3,
        freq_out4         => freq_out4
    );

    -- Clock process definition for "clk"
    process
    begin
        clk <= '0';
        wait for clk_period/2;
        clk <= '1';
        wait for clk_period/2;
    end process;

    -- Stimulus process
    process
    begin
        wait for clk_period*10;
        wait until rising_edge(clk);

        for I in 0 to 100 loop
            wait until rising_edge(clk);
                clk_enable_in <= '1';
                wrapped_phase_in1 <= std_logic_vector(to_signed(1000, wrapped_phase_in1'length));
            wait until rising_edge(clk);
                clk_enable_in <= '0';
            wait for clk_period*6;
        end loop;

        for I in 0 to 100 loop
            wait until rising_edge(clk);
                clk_enable_in <= '1';
                wrapped_phase_in2 <= std_logic_vector(to_signed(2000, wrapped_phase_in1'length));
            wait until rising_edge(clk);
                clk_enable_in <= '0';
            wait for clk_period*6;
        end loop;

        for I in 0 to 100 loop
            wait until rising_edge(clk);
                clk_enable_in <= '1';
                wrapped_phase_in3 <= std_logic_vector(to_signed(3000, wrapped_phase_in1'length));
            wait until rising_edge(clk);
                clk_enable_in <= '0';
            wait for clk_period*6;
        end loop;

        for I in 0 to 100 loop
            wait until rising_edge(clk);
                clk_enable_in <= '1';
                wrapped_phase_in4 <= std_logic_vector(to_signed(4000, wrapped_phase_in1'length));
            wait until rising_edge(clk);
                clk_enable_in <= '0';
            wait for clk_period*6;
        end loop;

        wait;

    end process;
    
end;
