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

    -- status registers:
    dither_results1   : in  std_logic_vector(64-1 downto 0);
    dither_results2   : in  std_logic_vector(64-1 downto 0);
    dither_results3   : in  std_logic_vector(64-1 downto 0);
    dither_results4   : in  std_logic_vector(64-1 downto 0);

    clk_int_or_ext_actual   : in  std_logic;
    clk_int_or_ext_desired  : in  std_logic;
    clk_ext_good            : in  std_logic;

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

    signal phi_integrated_clk_enable : std_logic := '0';
    signal phi_integrated1 : std_logic_vector(UNWRAPPED_WIDTH-1 downto 0) := (others => '0');
    signal phi_integrated2 : std_logic_vector(UNWRAPPED_WIDTH-1 downto 0) := (others => '0');
    signal phi_integrated3 : std_logic_vector(UNWRAPPED_WIDTH-1 downto 0) := (others => '0');
    signal phi_integrated4 : std_logic_vector(UNWRAPPED_WIDTH-1 downto 0) := (others => '0');

    signal clk_enable_to_logger : std_logic := '0';
    signal new_data_chunk : std_logic := '0';
    signal data_to_logger : std_logic_vector(LOGGER_WIDTH-1 downto 0) := (others => '0');

begin

    unwrap_integrate_and_dump_4ch_inst : entity work.unwrap_integrate_and_dump_4ch
    generic map (
        INPUT_WIDTH     => INPUT_WIDTH,
        UNWRAPPED_WIDTH => UNWRAPPED_WIDTH,
        COUNTER_WIDTH   => COUNTER_WIDTH
    ) port map (
        clk                       => clk,
        clk_enable_in             => clk_enable_in,
        wrapped_phase_in1         => wrapped_phase_in1,
        wrapped_phase_in2         => wrapped_phase_in2,
        wrapped_phase_in3         => wrapped_phase_in3,
        wrapped_phase_in4         => wrapped_phase_in4,
        n_cycles                  => n_cycles,
        reset_offset1             => '0',
        reset_offset2             => '0',
        reset_offset3             => '0',
        reset_offset4             => '0',
        phi_integrated_clk_enable => phi_integrated_clk_enable,
        phi_integrated1           => phi_integrated1,
        phi_integrated2           => phi_integrated2,
        phi_integrated3           => phi_integrated3,
        phi_integrated4           => phi_integrated4
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

        dither_results1             => dither_results1,
        dither_results2             => dither_results2,
        dither_results3             => dither_results3,
        dither_results4             => dither_results4,

        clk_int_or_ext_actual       => clk_int_or_ext_actual,
        clk_int_or_ext_desired      => clk_int_or_ext_desired,
        clk_ext_good                => clk_ext_good,

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
