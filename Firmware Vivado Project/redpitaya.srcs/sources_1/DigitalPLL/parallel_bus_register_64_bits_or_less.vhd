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
-- Description:  Combines two 32-bits registers.  Has an additional register so that both 32-bits sections change at the same time on the output.
-- To get this smooth update behavior, the script must update the LSBs first (the lower address), and then the MSBs (the higher address).
-- This module does not support having a default value yet.
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

entity parallel_bus_register_64_bits_or_less is
	Generic (
		REGISTER_SIZE	: integer := 64;	-- 64 bits or less
		ADDRESS			: integer := 0		-- between 0 and 65535 inclusively.  This is the address for the 32 LSBs.  The address for the 32 MSBs will be ADDRESS+1
	);
    Port ( clk : in  STD_LOGIC;
           bus_strobe : in  STD_LOGIC;
           bus_address : in  STD_LOGIC_VECTOR (15 downto 0);
           bus_data : in  STD_LOGIC_VECTOR (31 downto 0);
           register_output : out  STD_LOGIC_VECTOR (REGISTER_SIZE-1 downto 0);
           update_flag : out  STD_LOGIC);
end parallel_bus_register_64_bits_or_less;

architecture Behavioral of parallel_bus_register_64_bits_or_less is

	signal register_lsbs					: std_logic_vector(32-1 downto 0) := std_logic_vector(to_unsigned(0 , 32));
--	signal register_msbs					: std_logic_vector(32-1 downto 0) := std_logic_vector(to_unsigned(0 , 32));
	signal output							: std_logic_vector(64-1 downto 0) := std_logic_vector(to_unsigned(0 , 64));
	
	signal update_flag_internal		: std_logic := '0';
begin

	process (clk)
	begin
		if rising_edge(clk) then
			-- update the LSBs: doesn't affect the output
			if bus_strobe = '1' and bus_address = std_logic_vector(to_unsigned(ADDRESS, bus_address'length)) then
				register_lsbs <= bus_data;
			end if;
			-- update the MSBs: also updates the output
			if bus_strobe = '1' and bus_address = std_logic_vector(to_unsigned(ADDRESS+1, bus_address'length)) then
--				register_msbs <= bus_data;
				output <= bus_data & register_lsbs;
				update_flag_internal <= '1';
			else
				update_flag_internal <= '0';
			end if;
		end if;
	end process;
	
	register_output <= output(register_output'range);
	update_flag <= update_flag_internal;
	
end Behavioral;

