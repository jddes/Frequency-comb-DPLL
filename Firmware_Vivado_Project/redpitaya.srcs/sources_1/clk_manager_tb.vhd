library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

entity clk_manager_tb is
end clk_manager_tb;

architecture behavior of clk_manager_tb is

    -- clk_manager signals
    -- Generics as constants
    constant COUNTER_WIDTH : integer := 16;
    type two_dim_array is array (natural range <>, natural range <>) of std_logic;
    -- Inputs
    signal clk_stable                       : std_logic                                  := '0';
    signal clk_ext                          : std_logic                                  := '0';
    signal clk_int_or_ext_desired           : std_logic                                  := '0';
    signal minimum_cycles_of_clk_under_test : std_logic_vector(COUNTER_WIDTH-1 downto 0) := std_logic_vector(to_unsigned(1, COUNTER_WIDTH));
    signal cycles_of_clk_stable             : std_logic_vector(COUNTER_WIDTH-1 downto 0) := std_logic_vector(to_unsigned(100, COUNTER_WIDTH));
    -- Outputs
    signal clk_ext_good          : std_logic;
    signal clk_int_or_ext_actual : std_logic;

    -- Clock period definition
    constant clk_period : time := 5 ns;
    constant clk_ext_period : time := 100 ns;
begin

    -- Unit under test
    clk_manager_inst : entity work.clk_manager
    generic map (
        COUNTER_WIDTH => COUNTER_WIDTH
    ) port map (
        clk_stable                       => clk_stable,
        clk_ext                          => clk_ext,
        clk_int_or_ext_desired           => clk_int_or_ext_desired,
        minimum_cycles_of_clk_under_test => minimum_cycles_of_clk_under_test,
        cycles_of_clk_stable             => cycles_of_clk_stable,
        clk_ext_good                     => clk_ext_good,
        clk_int_or_ext_actual            => clk_int_or_ext_actual
    );

    -- Clock process definition for "clk_stable"
    process
    begin
        clk_stable <= '0';
        wait for clk_period/2;
        clk_stable <= '1';
        wait for clk_period/2;
    end process;

    -- Clock process definition for "clk_ext"
    process
    begin
        for I in 0 to 5000 loop
            clk_ext <= '0';
            wait for clk_ext_period/2;
            clk_ext <= '1';
            wait for clk_ext_period/2;
        end loop;
        wait for clk_period*1000;
        for I in 0 to 5000 loop
            clk_ext <= '0';
            wait for clk_ext_period/2;
            clk_ext <= '1';
            wait for clk_ext_period/2;
        end loop;
        wait;
    end process;

    -- toggle between internal or external clock mode requested, so that we test all possibilities
    process
    begin
        wait for clk_period*100;
            clk_int_or_ext_desired <= '0';
        wait for clk_period*100;
            clk_int_or_ext_desired <= '1';
    end process;

    -- Stimulus process
    process
    begin
        wait for clk_period*10;
        wait until rising_edge(clk_stable);
        wait;

    end process;
    
end;
