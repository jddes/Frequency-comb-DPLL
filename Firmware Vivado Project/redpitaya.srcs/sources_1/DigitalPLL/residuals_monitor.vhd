----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    12:07:07 02/19/2014 
-- Design Name: 
-- Module Name:    residuals_monitor - Behavioral 
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

entity residuals_monitor is
	Generic (
		N_BITS_DATA : integer := 32
		);
    Port ( clk : in  STD_LOGIC;
           phase_residuals : in  STD_LOGIC_VECTOR (N_BITS_DATA-1 downto 0);
           residuals_threshold : in  STD_LOGIC_VECTOR (N_BITS_DATA-1 downto 0);
           residuals_are_above_threshold : out  STD_LOGIC);
end residuals_monitor;

architecture Behavioral of residuals_monitor is
	-- note the extra bit since we are taking the absolute value of a signed number, which can overflow unless we add a bit
	signal abs_of_residuals : unsigned(N_BITS_DATA downto 0) := (others => '0');
	signal residuals_are_above_threshold_internal : std_logic := '0';
begin
	process (clk)
	begin
		if rising_edge(clk) then
			abs_of_residuals <= unsigned(  abs( resize(signed(phase_residuals), N_BITS_DATA+1) ) );
			if abs_of_residuals > unsigned(residuals_threshold) then
				residuals_are_above_threshold_internal <= '1';
			else
				residuals_are_above_threshold_internal <= '0';
			end if;

		end if;
	end process;
	residuals_are_above_threshold <= residuals_are_above_threshold_internal;
	
	
end Behavioral;

