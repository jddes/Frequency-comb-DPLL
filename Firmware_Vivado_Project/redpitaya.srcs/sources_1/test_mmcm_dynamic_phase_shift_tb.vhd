library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity test_mmcm_dynamic_phase_shift_testbench is
end test_mmcm_dynamic_phase_shift_testbench;

architecture behavior of test_mmcm_dynamic_phase_shift_testbench is

    -- test_mmcm_dynamic_phase_shift signals
    -- Generics as constants
    
    -- Inputs
    signal rst    : std_logic := '0';
    signal clk_in : std_logic := '0';
    -- Outputs
    signal PSDONE  : std_logic;
    signal clk_out : std_logic;

    -- Clock period definition
    constant clk_period : time := 5 ns;
begin

    -- Unit under test
    test_mmcm_dynamic_phase_shift_inst : entity work.test_mmcm_dynamic_phase_shift
    port map (
        rst     => rst,
        clk_in  => clk_in,
        PSDONE  => PSDONE,
        clk_out => clk_out
    );

    -- Clock process definition for "clk_in"
    process
    begin
        clk_in <= '0';
        wait for clk_period/2;
        clk_in <= '1';
        wait for clk_period/2;
    end process;

    -- Stimulus process
    process
    begin
        rst <= '1';
        wait for clk_period*10;
        rst <= '0';
        wait until rising_edge(clk_in);
        wait;

    end process;
    
end;
