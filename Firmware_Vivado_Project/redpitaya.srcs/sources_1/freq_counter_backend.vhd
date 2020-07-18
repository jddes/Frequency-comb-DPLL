library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- unwraps from 14 to 64 bits, then integrate and dump, save to a ram data logger
entity freq_counter_backend is
Generic (
    INPUT_WIDTH     : integer := 14;
    UNWRAPPED_WIDTH : integer := 64;
    LOGGER_WIDTH    : integer := 32;
    COUNTER_WIDTH   : integer := 32
);
port (
    clk               : in  std_logic;

    -- four-channel phase data inputs
    clk_enable_in     : in  std_logic;
    wrapped_phase_in1 : in  std_logic_vector(INPUT_WIDTH-1 downto 0);
    wrapped_phase_in2 : in  std_logic_vector(INPUT_WIDTH-1 downto 0);
    wrapped_phase_in3 : in  std_logic_vector(INPUT_WIDTH-1 downto 0);
    wrapped_phase_in4 : in  std_logic_vector(INPUT_WIDTH-1 downto 0);

    -- config port:
    n_cycles          : in  std_logic_vector(COUNTER_WIDTH-1 downto 0);

    -- CPU interface
    sys_addr                               : in  std_logic_vector(32-1 downto 0);   -- bus address
    sys_wdata                              : in  std_logic_vector(32-1 downto 0);   -- bus write data
    sys_wen                                : in  std_logic;   -- bus write enable
    sys_ren                                : in  std_logic;   -- bus read enable
    sys_rdata                              : out std_logic_vector(32-1 downto 0);  -- bus read data
    sys_err                                : out std_logic;  -- bus error indicator
    sys_ack                                : out std_logic   -- bus acknowledge signal
    );
end entity;

architecture Behavioral of freq_counter_backend is

    --type state_type is (STATE_IDLE, STATE_POS_OFFSET, STATE_ZERO1, STATE_NEG_OFFSET, STATE_ZERO2);
    --signal FSM_state      : state_type := STATE_IDLE;
    signal unwrapped_phase_clk_enable : std_logic := '0';
    signal unwrapped_phase1 : std_logic_vector(UNWRAPPED_WIDTH-1 downto 0) := (others => '0');
    signal unwrapped_phase2 : std_logic_vector(UNWRAPPED_WIDTH-1 downto 0) := (others => '0');
    signal unwrapped_phase3 : std_logic_vector(UNWRAPPED_WIDTH-1 downto 0) := (others => '0');
    signal unwrapped_phase4 : std_logic_vector(UNWRAPPED_WIDTH-1 downto 0) := (others => '0');



    signal phi_integrated_clk_enable : std_logic := '0';
    signal phi_integrated1 : std_logic_vector(UNWRAPPED_WIDTH-1 downto 0) := (others => '0');
    signal phi_integrated2 : std_logic_vector(UNWRAPPED_WIDTH-1 downto 0) := (others => '0');
    signal phi_integrated3 : std_logic_vector(UNWRAPPED_WIDTH-1 downto 0) := (others => '0');
    signal phi_integrated4 : std_logic_vector(UNWRAPPED_WIDTH-1 downto 0) := (others => '0');



    signal clk_enable_to_logger : std_logic := '0';
    signal new_data_chunk : std_logic := '0';
    signal data_to_logger : std_logic_vector(LOGGER_WIDTH-1 downto 0) := (others => '0');


begin

    phase_unwrapper_inst1 : entity work.phase_unwrapper
    generic map (
        INPUT_WIDTH  => INPUT_WIDTH,
        OUTPUT_WIDTH => UNWRAPPED_WIDTH
    ) port map (
        clk                 => clk,
        clk_enable_in       => clk_enable_in,
        wrapped_phase_in    => wrapped_phase_in1,
        clk_enable_out      => unwrapped_phase_clk_enable,
        unwrapped_phase_out => unwrapped_phase1
    );

    phase_unwrapper_inst2 : entity work.phase_unwrapper
    generic map (
        INPUT_WIDTH  => INPUT_WIDTH,
        OUTPUT_WIDTH => UNWRAPPED_WIDTH
    ) port map (
        clk                 => clk,
        clk_enable_in       => clk_enable_in,
        wrapped_phase_in    => wrapped_phase_in2,
        clk_enable_out      => open,
        unwrapped_phase_out => unwrapped_phase2
    );

    phase_unwrapper_inst3 : entity work.phase_unwrapper
    generic map (
        INPUT_WIDTH  => INPUT_WIDTH,
        OUTPUT_WIDTH => UNWRAPPED_WIDTH
    ) port map (
        clk                 => clk,
        clk_enable_in       => clk_enable_in,
        wrapped_phase_in    => wrapped_phase_in3,
        clk_enable_out      => open,
        unwrapped_phase_out => unwrapped_phase3
    );

    phase_unwrapper_inst4 : entity work.phase_unwrapper
    generic map (
        INPUT_WIDTH  => INPUT_WIDTH,
        OUTPUT_WIDTH => UNWRAPPED_WIDTH
    ) port map (
        clk                 => clk,
        clk_enable_in       => clk_enable_in,
        wrapped_phase_in    => wrapped_phase_in4,
        clk_enable_out      => open,
        unwrapped_phase_out => unwrapped_phase4
    );

    integrate_and_dump_4ch_inst : entity work.integrate_and_dump_4ch
    generic map (
        DATA_WIDTH    => UNWRAPPED_WIDTH,
        COUNTER_WIDTH => COUNTER_WIDTH
    ) port map (
        clk            => clk,
        clk_enable_in  => unwrapped_phase_clk_enable,
        data_in1       => unwrapped_phase1,
        data_in2       => unwrapped_phase2,
        data_in3       => unwrapped_phase3,
        data_in4       => unwrapped_phase4,
        n_cycles       => n_cycles,
        clk_enable_out => phi_integrated_clk_enable,
        data_out1      => phi_integrated1,
        data_out2      => phi_integrated2,
        data_out3      => phi_integrated3,
        data_out4      => phi_integrated4
    );

    mux_phase_to_logger_inst : entity work.mux_phase_to_logger
    generic map (
        INPUT_WIDTH     => UNWRAPPED_WIDTH,
        OUTPUT_WIDTH    => LOGGER_WIDTH
    ) port map (
        clk            => clk,
        clk_enable_in  => phi_integrated_clk_enable,
        phi1           => phi_integrated1,
        phi2           => phi_integrated2,
        phi3           => phi_integrated3,
        phi4           => phi_integrated4,
        clk_enable_out => clk_enable_to_logger,
        new_data_chunk => new_data_chunk,
        data_out       => data_to_logger
    );

    -- contains the logger and register interface
    registers_read_inst : entity work.registers_read
    generic map (
        LOGGER_WIDTH => LOGGER_WIDTH
    ) port map (
        clk                         => clk,

        -- legacy inputs from DPLL code (all unused at the moment)
        status_flags                => (others => '0'),
        dither0_lockin_output       => (others => '0'),
        dither1_lockin_output       => (others => '0'),
        zdtc_samples_number_counter => (others => '0'),
        counter0_out                => (others => '0'),
        counter1_out                => (others => '0'),
        DAC0_out                    => (others => '0'),
        DAC1_out                    => (others => '0'),
        DAC2_out                    => (others => '0'),

        -- phase streaming input 
        clk_enable_logger           => clk_enable_to_logger,
        new_data_chunk              => new_data_chunk,
        data_logger                 => data_to_logger,

        -- cpu interface
        sys_addr                    => sys_addr,
        sys_wdata                   => sys_wdata,
        sys_wen                     => sys_wen,
        sys_ren                     => sys_ren,
        sys_rdata                   => sys_rdata,
        sys_err                     => sys_err,
        sys_ack                     => sys_ack
    );

end;
