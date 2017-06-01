----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    18:45:08 02/18/2014 
-- Design Name: 
-- Module Name:    dualport_ram_for_monitor - Behavioral 
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


use ieee.std_logic_unsigned.all;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity dualport_ram_for_monitor is
	Generic (
	ADDRESS_BITS : integer := 8;
	DATA_BITS : integer := 16
	);
    Port ( clk : in  STD_LOGIC;
           read_address : in  STD_LOGIC_VECTOR (ADDRESS_BITS-1 downto 0);
           write_address : in  STD_LOGIC_VECTOR (ADDRESS_BITS-1 downto 0);
			  write_enable : in std_logic;
           data_in : in  STD_LOGIC_VECTOR (DATA_BITS-1 downto 0);
           data_out : out  STD_LOGIC_VECTOR (DATA_BITS-1 downto 0));
end dualport_ram_for_monitor;

architecture Behavioral of dualport_ram_for_monitor is
    type ram_type is array (2**ADDRESS_BITS-1 downto 0) of std_logic_vector (DATA_BITS-1 downto 0);
    signal RAM: ram_type := (others => (others => '0'));
	 
	 signal data_out_internal : std_logic_vector(DATA_BITS-1 downto 0) := (others => '0');
begin

	process (clk)
	begin
		if rising_edge(clk) then
			-- Write
			if (write_enable = '1') then
				RAM(conv_integer(write_address)) <= data_in;
			end if;
			
			-- Read, always enable
			data_out_internal <= RAM(conv_integer(read_address));
		end if;
	end process;
	data_out <= data_out_internal;
	
end Behavioral;

