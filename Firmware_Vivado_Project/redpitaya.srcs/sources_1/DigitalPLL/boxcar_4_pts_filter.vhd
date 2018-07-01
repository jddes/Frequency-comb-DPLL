----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    22:07:11 11/22/2013 
-- Design Name: 
-- Module Name:    boxcar_4_pts_filter - Behavioral 
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
-- Description: Implements a 4-pts boxcar filter (also called moving-average filter).
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

entity boxcar_4_pts_filter is
	Generic (
		INPUT_SIZE : integer := 16
	);
    Port ( clk : in  STD_LOGIC;
           data_input : in  STD_LOGIC_VECTOR(INPUT_SIZE-1 downto 0);
           data_output : out  STD_LOGIC_VECTOR(INPUT_SIZE+2-1 downto 0));
end boxcar_4_pts_filter;

architecture Behavioral of boxcar_4_pts_filter is
	signal sum_register : signed(INPUT_SIZE+2-1 downto 0) := (others => '0');
	
	-- signal delay line:
	signal in0, in1, in2, in3 : signed(INPUT_SIZE-1 downto 0) := (others => '0');
begin
	process (clk)
	begin
		if rising_edge(clk) then
			-- signal delay line:
			in0 <= signed(data_input);
			in1 <= in0;
			in2 <= in1;
			in3 <= in2;
			
		
			-- If this block has trouble meeting timing, we can always switch to a tree of 2-inputs adders (3 adders total)
			-- instead of this 4-inputs adder
			sum_register <= resize(signed(in0), sum_register'length) + resize(signed(in1), sum_register'length)
									+ resize(signed(in2), sum_register'length) + resize(signed(in3), sum_register'length);
									

			
		end if;
	end process;
	data_output <= std_logic_vector(sum_register);
	
	
end Behavioral;

