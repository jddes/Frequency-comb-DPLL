library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity n_times_clk_fir_wrapper_testbench is
end n_times_clk_fir_wrapper_testbench;

architecture behavior of n_times_clk_fir_wrapper_testbench is

	component n_times_clk_fir_wrapper
	port (
	-- these two clocks need to be phase-locked to have a common edge (0 phase difference at the rising edges of clk_times_1)
		clk_times_1    : in  std_logic;
		clk_times_N    : in  std_logic;
		
		-- these two signals are on the clk_times_1 clock domain
		data_in        : in  std_logic_vector(16-1 downto 0);
		data_out       : out std_logic_vector(16-1 downto 0)
	); end component;

	-- Inputs
	signal clk_times_1 :  std_logic := '0';
	signal clk_times_n :  std_logic := '0';
	signal data_in :  std_logic_vector(16-1 downto 0) := (others => '0');
	
	-- Outputs
	signal data_out :  std_logic_vector(16-1 downto 0) := (others => '0');
	
	-- Clock period definition
	constant clk_period : time := 5 ns;
	constant clk_period_faster : time := 1.666666666666667 ns;	-- not exactly 5/3 of course, but the clocks should stay in sync long enough for this testbench
	signal clk_counter : unsigned(4-1 downto 0) := (others => '0');
begin

	-- Unit under test
	n_times_clk_fir_wrapper_inst : entity work.n_times_clk_fir_wrapper
	port map (
		clk_times_1 => clk_times_1,
		clk_times_n => clk_times_n,
		data_in => data_in,
		data_out => data_out
	);


	-- Clock process definition for "clk_times_1"
	process
	begin
		clk_times_1 <= '0';
		wait for clk_period/2;
		clk_times_1 <= '1';
		wait for clk_period/2;
	end process;

	-- Clock process definition for "clk_times_n"
	process
	begin
		clk_times_n <= '0';
		wait for clk_period_faster/2;
		clk_times_n <= '1';
		wait for clk_period_faster/2;
	end process;



	-- Stimulus process
	process
	begin
		wait for clk_period*50;
		-- impulse test
		wait until rising_edge(clk_times_1);
			data_in <= std_logic_vector(to_signed(1000, data_in'length));
		wait until rising_edge(clk_times_1);
			data_in <= std_logic_vector(to_signed(   0, data_in'length));

		wait for clk_period*50;
		-- (negative) step test
		wait until rising_edge(clk_times_1);
			data_in <= std_logic_vector(to_signed(-1000, data_in'length));
		wait;
	end process;
end;

