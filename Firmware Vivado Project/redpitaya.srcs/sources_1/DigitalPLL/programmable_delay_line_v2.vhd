----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    13:55:37 03/25/2012 
-- Design Name: 
-- Module Name:    programmable_delay_line - Behavioral 
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
-- Description: 
--
-- Dependencies: 
--
-- Revision: 
-- Revision 0.01 - File Created
-- Additional Comments: 
--
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
--use ieee.std_logic_unsigned.all;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity programmable_delay_line_v2 is
	Generic (
				ADDRESS_BITS	: integer := 12;	-- RAM size, and thus maximum delay is 2^ADDRESS_BITS
				DATA_BITS		: positive := 16
	);
	Port (
				clk : in  STD_LOGIC;
				
				-- Input port
				data_in : in  STD_LOGIC_VECTOR (DATA_BITS-1 downto 0);
				
				-- Configuration port.  The actual delay will be desired_delay_minus_one_minus_one+1.
				desired_delay_minus_one : in  STD_LOGIC_VECTOR (ADDRESS_BITS-1 downto 0);
				
				-- Output port
				data_out : out  STD_LOGIC_VECTOR (DATA_BITS-1 downto 0)

	);
end programmable_delay_line_v2;

architecture Behavioral of programmable_delay_line_v2 is

	-- RAM data signals
	type ram_type is array (2**ADDRESS_BITS-1 downto 0) of std_logic_vector (DATA_BITS-1 downto 0);
	signal RAM: ram_type;
	signal RAM_out: std_logic_vector (DATA_BITS-1 downto 0);

	-- RAM control signals
	signal write_address : std_logic_vector(ADDRESS_BITS-1 downto 0) := (others => '0');
	signal read_address : std_logic_vector(ADDRESS_BITS-1 downto 0) := (others => '0');

begin
	-- This process describes the RAM, which is accessed as a circular buffer of size 2^ADDRESS_BITS.
	process (clk)
	begin
		if rising_edge(clk) then

			-- RAM write
			RAM(to_integer(unsigned(write_address))) <= data_in;
			
			-- RAM read
			RAM_out <= RAM(to_integer(unsigned(read_address)));
			
			-- Increment the write/read pointers modulo 2^ADDRESS_BITS.
			read_address  <= std_logic_vector(unsigned(read_address) + 1);
			write_address <= std_logic_vector(unsigned(read_address) + unsigned(desired_delay_minus_one));
		
			-- output register, to match the same delay as the previous version of this code
			data_out <= RAM_out;
		end if;
	end process;
	

end Behavioral;

