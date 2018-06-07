library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity lock_on_trigger_testbench is
end lock_on_trigger_testbench;

architecture behavior of lock_on_trigger_testbench is

	constant COUNTER_BITS    : integer := 32;

	-- Inputs
	signal clk : std_logic := '0';
	signal trigger_in : std_logic := '0';
	signal lock_on_next_trigger : std_logic := '0';
	signal delay_before_lock : std_logic_vector(counter_bits-1 downto 0) := std_logic_vector(to_unsigned(100, COUNTER_BITS));
	signal block_manual : std_logic := '0';
	
	-- Outputs
	signal lock_output : std_logic;
	
	-- Clock period definition
	constant clk_period : time := 5 ns;
begin

	-- Unit under test
	lock_on_trigger_inst : entity work.lock_on_trigger
	port map (
		clk => clk,
		trigger_in => trigger_in,
		lock_on_next_trigger => lock_on_next_trigger,
		delay_before_lock => delay_before_lock,
		block_manual => block_manual,
		lock_output => lock_output
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
		-- Test the manual lock:
		wait for clk_period*10;
		wait until rising_edge(clk);
			block_manual <= '1';
		wait for clk_period*100;
		wait until rising_edge(clk);
			block_manual <= '0';

		wait for clk_period*100;
			lock_on_next_trigger <= '1';
		wait for clk_period*300;
		-- bouncing trigger:
		wait until rising_edge(clk);
			trigger_in <= '1';
		wait until rising_edge(clk);
			trigger_in <= '0';
		wait until rising_edge(clk);
			trigger_in <= '1';
		wait until rising_edge(clk);
			trigger_in <= '0';
		wait until rising_edge(clk);
			trigger_in <= '1';
		wait until rising_edge(clk);
			trigger_in <= '0';
		wait until rising_edge(clk);
			trigger_in <= '1';
		wait until rising_edge(clk);
			trigger_in <= '0';

		wait for clk_period*1000;
		wait until rising_edge(clk);
			lock_on_next_trigger <= '0';

		wait for clk_period*300;


		-- try again, to make sure that everything has reset properly:
		wait for clk_period*100;
			lock_on_next_trigger <= '1';
		wait for clk_period*300;
		-- bouncing trigger:
		wait until rising_edge(clk);
			trigger_in <= '1';
		wait until rising_edge(clk);
			trigger_in <= '0';
		wait until rising_edge(clk);
			trigger_in <= '1';
		wait until rising_edge(clk);
			trigger_in <= '0';
		wait until rising_edge(clk);
			trigger_in <= '1';
		wait until rising_edge(clk);
			trigger_in <= '0';
		wait until rising_edge(clk);
			trigger_in <= '1';
		wait until rising_edge(clk);
			trigger_in <= '0';

		wait for clk_period*1000;
		wait until rising_edge(clk);
			lock_on_next_trigger <= '0';

		wait;

    end process;
    
end;
