library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

entity duty_cycle_protector_tb is
end duty_cycle_protector_tb;

architecture behavior of duty_cycle_protector_tb is

    -- duty_cycle_protector signals
    -- Generics as constants
    constant MAX_CYCLES_ON       : integer := 100;
    constant TIMEOUT_CYCLES_LOG2 : integer := 10;
    constant COUNTER_WIDTH       : integer := 24;
    -- Inputs
    signal clk                     : std_logic := '0';
    signal clk_under_test          : std_logic := '0';
    signal clk_under_test_glitched : std_logic := '0';
    -- Outputs
    signal clk_gated : std_logic;

    -- testbench signals:
    signal consecutive_counter : unsigned(32-1 downto 0) := (others => '0');
    signal counter      : unsigned(32-1 downto 0) := (others => '0');
    signal clk_on_value : unsigned(32-1 downto 0) := to_unsigned(30, 32);
    signal clk_under_test1 : std_logic := '0';
    signal clk_under_test2 : std_logic := '0';
    signal clk_under_test3 : std_logic := '0';
    signal clk_under_test4 : std_logic := '0';
    signal clk_under_test5 : std_logic := '0';
    signal clk_glitch_gate : std_logic := '0';

    signal glitchy_clock : std_logic := '0';

    -- Clock period definition
    constant clk_period : time := 5 ns;
begin

    -- Unit under test
    duty_cycle_protector_inst : entity work.duty_cycle_protector
    generic map (
        MAX_CYCLES_ON       => MAX_CYCLES_ON,
        TIMEOUT_CYCLES_LOG2 => TIMEOUT_CYCLES_LOG2,
        COUNTER_WIDTH       => COUNTER_WIDTH
    ) port map (
        clk            => clk,
        clk_under_test => clk_under_test_glitched,
        clk_gated      => clk_gated
    );

    -- Clock process definition for "clk"
    process
    begin
        clk <= '0';
        wait for clk_period/2;
        clk <= '1';
        wait for clk_period/2;
    end process;

    -- counter process
    process( clk )
    begin
        if rising_edge(clk) then
            if counter < 500-1 then
                counter <= counter + 1;
            else
                counter <= (others => '0');
            end if;

            if counter < clk_on_value then
                clk_under_test <= '1';
            else
                clk_under_test <= '0';
            end if;

        end if;
    end process;

    process(clk)
    begin
        if rising_edge(clk) then
            clk_under_test1 <= clk_under_test;
            clk_under_test2 <= clk_under_test1;
            clk_under_test3 <= clk_under_test2;
            clk_under_test4 <= clk_under_test3;
            clk_under_test5 <= clk_under_test4;

            if glitchy_clock = '1' then
                if (clk_under_test='1') xor (clk_under_test2='1') xor (clk_under_test4='1') then
                    clk_under_test_glitched <= '1';
                else
                    clk_under_test_glitched <= '0';
                end if;
            else
                clk_under_test_glitched <= clk_under_test;
            end if;
        end if;
    end process;


    -- invariant testing: clock output should never be high more than MAX_CYCLES_ON cycles consecutively
    -- (give or take a few, we don't care)
    process(clk)
    begin
        if rising_edge(clk) then
            if clk_gated = '1' then
                consecutive_counter <= consecutive_counter + 1;
                -- assert consecutive_counter < MAX_CYCLES_ON+10 report "ERROR: too many high cycles!" severity error;
            else
                consecutive_counter <= (others => '0');
            end if;
        end if;
    end process;

    -- Stimulus process
    process
    begin
        wait for clk_period*10;
        wait until rising_edge(clk);
        wait for clk_period*50000;

        wait until rising_edge(clk);
            clk_on_value <= to_unsigned(MAX_CYCLES_ON+20, 32); -- expect the clock to stop
        wait for clk_period*50000;

        wait until rising_edge(clk);
            clk_on_value <= to_unsigned(80, 32); -- expect the clock to start again

        wait for clk_period*50000;

        -- simulate a glitchy clock
        wait for clk_period*50000;
            glitchy_clock <= '1';


        wait for clk_period*50000;
        wait until rising_edge(clk);
            clk_on_value <= to_unsigned(MAX_CYCLES_ON+20, 32); -- expect the clock to stop

        --for I in 0 to 1023 loop
        --    wait until rising_edge(clk);
        --        read_enable <= '1';
        --    wait until rising_edge(clk);
        --        read_enable <= '0';
        --    wait for clk_period*5;
        --end loop;

        wait;

    end process;
    
end;
