library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

entity clock_presence_detector_tb is
end clock_presence_detector_tb;

architecture behavior of clock_presence_detector_tb is

    -- clock_presence_detector signals
    -- Generics as constants
    constant COUNTER_WIDTH : integer := 24;
    -- Inputs
    signal clk_stable                       : std_logic                                  := '0';
    signal clk_under_test                   : std_logic                                  := '0';
    signal minimum_cycles_of_clk_under_test : std_logic_vector(COUNTER_WIDTH-1 downto 0) := std_logic_vector(to_unsigned(2, COUNTER_WIDTH));
    signal cycles_of_clk_stable             : std_logic_vector(COUNTER_WIDTH-1 downto 0) := std_logic_vector(to_unsigned(100, COUNTER_WIDTH));
    -- Outputs
    signal clk_good : std_logic;

    -- Clock period definition
    constant clk_period : time := 5 ns;
    constant clk_under_test_period : time := 100 ns;
begin

    -- Unit under test
    clock_presence_detector_inst : entity work.clock_presence_detector
    generic map (
        COUNTER_WIDTH => COUNTER_WIDTH
    ) port map (
        clk_stable                       => clk_stable,
        clk_under_test                   => clk_under_test,
        minimum_cycles_of_clk_under_test => minimum_cycles_of_clk_under_test,
        cycles_of_clk_stable             => cycles_of_clk_stable,
        clk_good                         => clk_good
    );

    -- Clock process definition for "clk_stable"
    process
    begin
        clk_stable <= '0';
        wait for clk_period/2;
        clk_stable <= '1';
        wait for clk_period/2;
    end process;

    -- Clock process definition for "clk_under_test"
    process
    begin
        for I in 0 to 5000 loop
            clk_under_test <= '0';
            wait for clk_under_test_period/2;
            clk_under_test <= '1';
            wait for clk_under_test_period/2;
        end loop;
        wait for clk_period*1000;
        for I in 0 to 5000 loop
            clk_under_test <= '0';
            wait for clk_under_test_period/2;
            clk_under_test <= '1';
            wait for clk_under_test_period/2;
        end loop;
        wait;
    end process;


    -- Stimulus process
    process
    begin
        wait for clk_period*10;
        wait until rising_edge(clk_stable);
        wait;
    end process;
    
end;
