-- simlpe dual-port ram, based on vivado coding example
-- 1 cycle of latency for writes
-- 1 cycle of latency for reads
-- this makes a total of 2 clk cycles of latency (if the same clock is used for both ports)


library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity simple_dualport_ram is
	Generic (
		ADDRESS_WIDTH : positive := 15;
		DATA_WIDTH : positive := 16
	);
	Port (

		-- Write port:
		clk_write : in std_logic;
		write_enable : in std_logic;
		write_address : in  std_logic_vector (ADDRESS_WIDTH-1 downto 0);
		write_data : in std_logic_vector(DATA_WIDTH-1 downto 0);

		-- Read port:
		clk_read : in  std_logic;
		read_enable : in std_logic;
		read_address : in  std_logic_vector (ADDRESS_WIDTH-1 downto 0);
		read_data : out  std_logic_vector (DATA_WIDTH-1 downto 0)
	);
end simple_dualport_ram;

architecture Behavioral of simple_dualport_ram is



	type RAM_TYPE is array(0 to 2**ADDRESS_WIDTH-1) of std_logic_vector(DATA_WIDTH-1 downto 0);    
    signal RAM : RAM_TYPE := (others => (others => '0'));
	 
	signal read_data_internal : std_logic_vector (DATA_WIDTH-1 downto 0) := (others => '0');

begin

	-- write port, 1 cycle latency:
	process (clk_write)                                                
	begin                                                        
		if rising_edge(clk_write) then                           
			if write_enable = '1' then   
				RAM(to_integer(unsigned(write_address))) <= write_data;
			end if;
		end if;
	end process;

	-- Read port, 1 cycle latency:
	process (clk_read)                                                
	begin                                                        
		if rising_edge(clk_read) then
			if read_enable = '1' then
				read_data_internal <= RAM(to_integer(unsigned(read_address)));
			end if;
			
		end if;
	end process;
	read_data <= read_data_internal;

end Behavioral;

