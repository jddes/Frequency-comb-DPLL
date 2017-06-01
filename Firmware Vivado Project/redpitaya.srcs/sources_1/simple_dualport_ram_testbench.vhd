library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity simple_dualport_ram_testbench is
end simple_dualport_ram_testbench;

architecture behavior of simple_dualport_ram_testbench is


	constant ADDRESS_WIDTH : integer := 5;
	constant DATA_WIDTH : integer := 5;

	-- Inputs
	signal clk_write : std_logic := '0';
	signal write_enable : std_logic := '0';
	signal write_address :  std_logic_vector (address_width-1 downto 0) := (others => '0');
	signal write_data : std_logic_vector(data_width-1 downto 0) := (others => '0');
	signal clk_read :  std_logic := '0';
	signal read_enable : std_logic := '0';
	signal read_address :  std_logic_vector (address_width-1 downto 0) := (others => '0');
	
	-- Outputs
	signal read_data :  std_logic_vector (data_width-1 downto 0) := (others => '0');

	signal bStartRead : std_logic := '0';
	
	-- Clock period definition
	constant clk_period : time := 5 ns;
	constant clk_period2 : time := 7 ns;
begin

	-- Unit under test
	simple_dualport_ram_inst : entity work.simple_dualport_ram
	generic map (
		ADDRESS_WIDTH => ADDRESS_WIDTH,
		DATA_WIDTH => DATA_WIDTH

	)
	port map (
		-- write port
		clk_write => clk_write,
		write_enable => write_enable,
		write_address => write_address,
		write_data => write_data,
		-- read port
		clk_read => clk_read,
		read_enable => read_enable,
		read_address => read_address,
		read_data => read_data
	);

	-- Clock process definition for "clk_write"
	process
	begin
		clk_write <= '0';
		wait for clk_period/2;
		clk_write <= '1';
		wait for clk_period/2;
	end process;

	-- Clock process definition for "clk_read"
	process
	begin
		clk_read <= '0';
		wait for clk_period2/2;
		clk_read <= '1';
		wait for clk_period2/2;
	end process;

	-- read and write address processes:
	process (clk_write)
	begin
		if rising_edge(clk_write) then
			write_enable <= '1';
			write_data <= std_logic_vector(shift_left(unsigned(write_address) + 1, 1));
			write_address <= std_logic_vector(unsigned(write_address) + 1);
		end if;
	end process;

	process (clk_read)
	begin
		if rising_edge(clk_read) then
			if bStartRead = '1' then
				read_enable <= '1';
				read_address <= std_logic_vector(unsigned(read_address) + 1);
			end if;
		end if;
	end process;

	-- Stimulus process
	process
	begin
		-- wait for a few data points to be written before starting the read
		wait for clk_period*10;
		wait until rising_edge(clk_write);
		bStartRead <= '1';
		wait;
	end process;
end;
