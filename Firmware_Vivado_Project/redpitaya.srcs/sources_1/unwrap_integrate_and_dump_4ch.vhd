library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- unwraps from INPUT_WIDTH to UNWRAPPED_WIDTH bits, then integrate and dump each separately
entity unwrap_integrate_and_dump_4ch is
Generic (
    INPUT_WIDTH     : integer := 14;
    UNWRAPPED_WIDTH : integer := 64;
    COUNTER_WIDTH   : integer := 32
);
port (
    clk                       : in  std_logic;
    
    -- four-channel phase data inputs
    clk_enable_in             : in  std_logic;
    wrapped_phase_in1         : in  std_logic_vector(INPUT_WIDTH-1 downto 0);
    wrapped_phase_in2         : in  std_logic_vector(INPUT_WIDTH-1 downto 0);
    wrapped_phase_in3         : in  std_logic_vector(INPUT_WIDTH-1 downto 0);
    wrapped_phase_in4         : in  std_logic_vector(INPUT_WIDTH-1 downto 0);
    
    -- config port:
    n_cycles                  : in  std_logic_vector(COUNTER_WIDTH-1 downto 0);
    
    -- output port
    phi_integrated_clk_enable : out std_logic;
    phi_integrated1           : out std_logic_vector(UNWRAPPED_WIDTH-1 downto 0);
    phi_integrated2           : out std_logic_vector(UNWRAPPED_WIDTH-1 downto 0);
    phi_integrated3           : out std_logic_vector(UNWRAPPED_WIDTH-1 downto 0);
    phi_integrated4           : out std_logic_vector(UNWRAPPED_WIDTH-1 downto 0)
    );
end entity;

architecture Behavioral of unwrap_integrate_and_dump_4ch is
    signal unwrapped_phase_clk_enable : std_logic := '0';
    signal unwrapped_phase1 : std_logic_vector(UNWRAPPED_WIDTH-1 downto 0) := (others => '0');
    signal unwrapped_phase2 : std_logic_vector(UNWRAPPED_WIDTH-1 downto 0) := (others => '0');
    signal unwrapped_phase3 : std_logic_vector(UNWRAPPED_WIDTH-1 downto 0) := (others => '0');
    signal unwrapped_phase4 : std_logic_vector(UNWRAPPED_WIDTH-1 downto 0) := (others => '0');
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

end;
