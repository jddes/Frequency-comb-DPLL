----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    10:20:22 12/12/2013 
-- Design Name: 
-- Module Name:    resize_with_saturation - Behavioral 
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
-- Description:  This module takes an N_INPUT bits input, and outputs an N_OUTPUT bits output, with
-- N_OUTPUT < N_INPUT, and makes sure that the input is properly saturated so that no wrapping occurs.
-- The delay between input and output is 1 clock cycle.  The "railed_positive" and "railed_negative" outputs indicate whether the 
-- the input was too big to fit in the output, and to which rail the output is clamped.
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

entity resize_with_saturation is
	Generic (
		N_INPUT : integer := 20;
		N_OUTPUT : integer := 16
	);
    Port ( clk : in  STD_LOGIC;
			  synchronous_clear : in std_logic;
           data_in : in  STD_LOGIC_VECTOR (N_INPUT-1 downto 0);
			  railed_positive : out std_logic;
			  railed_negative : out std_logic;
           data_out : out  STD_LOGIC_VECTOR (N_OUTPUT-1 downto 0));
end resize_with_saturation;

architecture Behavioral of resize_with_saturation is

	constant MAX_VALUE : signed(N_OUTPUT-1 downto 0) := shift_left(to_signed(1, N_OUTPUT), N_OUTPUT-1)-1;	-- (2^(N_OUTPUT-1)-1)
	constant MIN_VALUE : signed(N_OUTPUT-1 downto 0) := shift_left(to_signed(-1, N_OUTPUT), N_OUTPUT-1);	-- (-2**(N_OUTPUT-1))

	-- these signals have no other purpose than to give a default value to the outputs so that there are no undefined values in simulation
	signal railed_positive_temp : std_logic := '0';
	signal railed_negative_temp : std_logic := '0';
	signal data_out_temp : STD_LOGIC_VECTOR (N_OUTPUT-1 downto 0) := (others => '0');

begin
	process (clk)
	begin
		if rising_edge(clk) then
			if synchronous_clear = '1' then
				-- Reset state
				data_out_temp <= (others => '0');
				railed_positive_temp <= '0';
				railed_negative_temp <= '0';
			else
				if signed(data_in) > MAX_VALUE then
					-- Saturated positive
					data_out_temp <= std_logic_vector(MAX_VALUE(data_out'range));
					railed_positive_temp <= '1';
					railed_negative_temp <= '0';
				elsif signed(data_in) < MIN_VALUE then
					-- Saturated negative
					data_out_temp <= std_logic_vector(MIN_VALUE(data_out'range));
					railed_positive_temp <= '0';
					railed_negative_temp <= '1';
				else
					-- Linear range
					data_out_temp <= data_in(data_out'range);
					railed_positive_temp <= '0';
					railed_negative_temp <= '0';
				end if;
			end if;
		end if;
	end process;
	
	railed_positive <= railed_positive_temp;
	railed_negative <= railed_negative_temp;
	data_out <= data_out_temp;

end Behavioral;

