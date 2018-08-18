library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity variable_duty_cycle_oscillator_testbench is
end variable_duty_cycle_oscillator_testbench;

architecture behavior of variable_duty_cycle_oscillator_testbench is

    constant COUNTER_BITS    : integer := 24;

    -- Inputs
    signal clk            : std_logic := '0';
    signal benable        : std_logic := '1';
    signal bpolarity      : std_logic := '1';
    signal modulus        : std_logic_vector(counter_bits-1 downto 0) := std_logic_vector(to_unsigned(1000, counter_bits));
    signal modulus_active : std_logic_vector(counter_bits-1 downto 0) := std_logic_vector(to_unsigned( 100, counter_bits));
    
    -- Outputs
    signal output_square_wave : std_logic;
    
    -- Clock period definition
    constant clk_period : time := 5 ns;
begin

    -- Unit under test
    variable_duty_cycle_oscillator_inst : entity work.variable_duty_cycle_oscillator
    port map (
        clk => clk,
        benable => benable,
        bpolarity => bpolarity,
        modulus => modulus,
        modulus_active => modulus_active,
        output_square_wave => output_square_wave
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

        wait for clk_period*10000;
            bpolarity <= '0';
        wait for clk_period*10000;
            modulus        <= std_logic_vector(to_unsigned( 100, counter_bits));
            modulus_active <= std_logic_vector(to_unsigned(  10, counter_bits));

        wait for clk_period*1000;
            benable <= '0';

        wait for clk_period*1000;
            benable <= '1';
            bpolarity <= '1';
        wait;

    end process;
    
end;
