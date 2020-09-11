----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    22:55:07 11/22/2013 
-- Design Name: 
-- Module Name:    parallel_bus_register_32bits_or_less - Behavioral 
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

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity parallel_bus_register_32bits_or_less is
	Generic (
		REGISTER_SIZE	: integer := 32;	-- 32 bits or less
		REGISTER_DEFAULT_VALUE : integer := 0;
		ADDRESS			: integer := 0		-- between 0 and 65535 inclusively
	);
    Port ( 
        clk             : in  std_logic;
        bus_strobe      : in  std_logic;
        bus_address     : in  std_logic_vector (32-1 downto 0);
        bus_data        : in  std_logic_vector (32-1 downto 0);
        register_output : out  std_logic_vector (REGISTER_SIZE-1 downto 0);
        update_flag     : out  std_logic
    );
end parallel_bus_register_32bits_or_less;

architecture Behavioral of parallel_bus_register_32bits_or_less is
	signal output						: std_logic_vector(REGISTER_SIZE-1 downto 0) := std_logic_vector(to_unsigned(REGISTER_DEFAULT_VALUE , REGISTER_SIZE));
	signal update_flag_internal : std_logic := '0';

begin

	process (clk)
	begin
		if rising_edge(clk) then
			update_flag_internal <= '0';	-- default value
			if bus_strobe = '1' and bus_address = std_logic_vector(to_unsigned(ADDRESS, bus_address'length)) then
				output <= bus_data(register_output'range);
				update_flag_internal <= '1';
			end if;
		end if;
	end process;
	
	register_output <= output;
	update_flag <= update_flag_internal;

end Behavioral;

