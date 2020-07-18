library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

entity integrate_and_dump_tb is
end integrate_and_dump_tb;

architecture behavior of integrate_and_dump_tb is

    -- integrate_and_dump signals
    -- Generics as constants
    constant DATA_WIDTH    : integer := 16;
    constant COUNTER_WIDTH : integer := 32;
    -- Inputs
    signal clk           : std_logic                                  := '0';
    signal clk_enable_in : std_logic                                  := '0';
    signal data_in       : std_logic_vector(DATA_WIDTH-1 downto 0)    := (others => '0');
    signal n_cycles      : std_logic_vector(COUNTER_WIDTH-1 downto 0) := std_logic_vector(to_unsigned(10, COUNTER_WIDTH));
    -- Outputs
    signal clk_enable_out : std_logic;
    signal data_out       : std_logic_vector(DATA_WIDTH-1 downto 0);

    -- Clock period definition
    constant clk_period : time := 5 ns;
begin

    -- Unit under test
    integrate_and_dump_inst : entity work.integrate_and_dump
    generic map (
        DATA_WIDTH    => DATA_WIDTH,
        COUNTER_WIDTH => COUNTER_WIDTH
    ) port map (
        clk            => clk,
        clk_enable_in  => clk_enable_in,
        data_in        => data_in,
        n_cycles       => n_cycles,
        clk_enable_out => clk_enable_out,
        data_out       => data_out
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
        -- DC input
        wait for clk_period*10;
        wait until rising_edge(clk);
            clk_enable_in <= '1';
            data_in <= std_logic_vector(to_signed(23, DATA_WIDTH));
        wait for clk_period*100;
        wait until rising_edge(clk);
            clk_enable_in <= '0';

        wait until rising_edge(clk);
        -- DC input, but clk enabled at a slower rate
        for I in 0 to 500-1 loop
            wait until rising_edge(clk);
                clk_enable_in <= '1';
                data_in <= std_logic_vector(to_signed(12, DATA_WIDTH));
            wait until rising_edge(clk);
                clk_enable_in <= '0';
                data_in <= std_logic_vector(to_signed(0, DATA_WIDTH));
            wait for clk_period*5;
        end loop;

        -- pulses input once every 11 clk cycles
        for I in 0 to 500-1 loop
            wait until rising_edge(clk);
                clk_enable_in <= '1';
                data_in <= std_logic_vector(to_signed(12, DATA_WIDTH));
            wait until rising_edge(clk);
                data_in <= std_logic_vector(to_signed(0, DATA_WIDTH));
            wait for clk_period*9;
        end loop;


        wait;


    end process;
    
end;
