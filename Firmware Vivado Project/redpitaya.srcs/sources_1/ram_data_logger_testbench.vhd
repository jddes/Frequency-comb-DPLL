library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity ram_data_logger_testbench is
end ram_data_logger_testbench;

architecture behavior of ram_data_logger_testbench is

	-- Inputs
	signal clk :  std_logic;
	signal data_in :  std_logic_vector(16-1 downto 0) := (others => '0');
	signal data_in_clk_enable :  std_logic := '0';
	signal start_write :  std_logic := '0';
	signal sys_addr :  std_logic_vector(32-1 downto 0) := (others => '0');
	signal sys_wdata :  std_logic_vector(32-1 downto 0) := (others => '0');
	signal sys_sel :  std_logic_vector(4-1 downto 0) := (others => '0');
	signal sys_wen :  std_logic := '0';
	signal sys_ren :  std_logic := '0';
	
	-- Outputs
	signal sys_rdata : std_logic_vector(32-1 downto 0);
	signal sys_err : std_logic;
	signal sys_ack : std_logic;

	-- testbench signals
	signal wait_counter : unsigned(16-1 downto 0) := (others => '0');
	
	-- Clock period definition
	constant clk_period : time := 5 ns;
begin

	-- Unit under test
	ram_data_logger_inst : entity work.ram_data_logger
	port map (
		clk => clk,
		data_in => data_in,
		data_in_clk_enable => data_in_clk_enable,
		start_write => start_write,
		sys_addr => sys_addr,
		sys_wdata => sys_wdata,
		sys_sel => sys_sel,
		sys_wen => sys_wen,
		sys_ren => sys_ren,
		sys_rdata => sys_rdata,
		sys_err => sys_err,
		sys_ack => sys_ack
	);

	-- Clock process definition for "clk"
	process
	begin
		clk <= '0';
		wait for clk_period/2;
		clk <= '1';
		wait for clk_period/2;
	end process;


	process (clk)
	begin
		if rising_edge(clk) then
			data_in_clk_enable <= '0';
			if wait_counter < 10-1 then
				wait_counter <= wait_counter+1;
			else
				data_in <= std_logic_vector(unsigned(data_in)+1);
				wait_counter <= (others => '0');
				data_in_clk_enable <= '1';
			end if;
		end if;
	end process;

	-- Stimulus process
	process
	begin
		wait for clk_period*10;
		wait until rising_edge(clk);
		wait for 5 us;
		wait until rising_edge(clk);
			start_write <= '1';
		wait for clk_period*10;
		wait until rising_edge(clk);
			start_write <= '0';
		wait for clk_period*10*2048;
		wait for clk_period*100;
		wait until rising_edge(clk);
			start_write <= '1';
		wait until rising_edge(clk);
			start_write <= '0';

		wait for clk_period*10*2048;
		wait for clk_period*300;
		wait until rising_edge(clk);
			sys_ren  <= '1';
			sys_addr <= std_logic_vector(to_unsigned(10, sys_addr'length));
		wait until rising_edge(clk);
			sys_ren  <= '0';
			sys_addr <= std_logic_vector(to_unsigned( 0, sys_addr'length));
		wait;
	end process;
end;
