----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    22:07:11 11/22/2013 
-- Design Name: 
-- Module Name:    output_summing - Behavioral 
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

entity output_summing is
	Generic (
		INPUT_SIZE : integer := 16;
		OUTPUT_SIZE : integer := 16;
		GUARD_BITS : integer := 6
		
	
	);
    Port ( clk : in  STD_LOGIC;
           in0 : in  STD_LOGIC_VECTOR(INPUT_SIZE-1 downto 0);
           in1 : in  STD_LOGIC_VECTOR(INPUT_SIZE-1 downto 0);
           in2 : in  STD_LOGIC_VECTOR(INPUT_SIZE-1 downto 0);
           in3 : in  STD_LOGIC_VECTOR(INPUT_SIZE-1 downto 0);
           data_output : out  STD_LOGIC_VECTOR(OUTPUT_SIZE-1 downto 0);
			  positive_limit : in STD_LOGIC_VECTOR(OUTPUT_SIZE-1 downto 0);
			  negative_limit : in STD_LOGIC_VECTOR(OUTPUT_SIZE-1 downto 0);
           railed_positive : out  STD_LOGIC;
           railed_negative : out  STD_LOGIC);
end output_summing;

architecture Behavioral of output_summing is
	signal sum_register : signed(OUTPUT_SIZE+GUARD_BITS-1 downto 0) := (others => '0');
	
begin
	process (clk)
	begin
		if rising_edge(clk) then
			-- If this block has trouble meeting timing, we can always switch to a tree of 2-inputs adders (3 adders total)
			-- instead of this 4-inputs adder
			sum_register <= resize(signed(in0), sum_register'length) + resize(signed(in1), sum_register'length)
									+ resize(signed(in2), sum_register'length) + resize(signed(in3), sum_register'length);
									
			if sum_register > signed(positive_limit) then
				data_output <= positive_limit;
				railed_positive <= '1';
				railed_negative <= '0';
			elsif sum_register < signed(negative_limit) then
				data_output <= negative_limit;
				railed_positive <= '0';
				railed_negative <= '1';
			else
				data_output <= std_logic_vector(sum_register(data_output'range));
				railed_positive <= '0';
				railed_negative <= '0';
			end if;
			
		end if;
	end process;

end Behavioral;

