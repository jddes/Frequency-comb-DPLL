----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    12:34:12 02/09/2014 
-- Design Name: 
-- Module Name:    dac2_error_computation - Behavioral 
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
-- Description: This computes the desired setpoint for dac1's output equal to halfway between the minimum and the maximum,
-- and then computes the error signal as the offset between this setpoint and the current dac1 value.
-- There is a little bit of bitgrowth (1 more bit on the error output than on the inpuut values) to make sure that there is no wrapping in the arithmetic.
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

entity dac2_error_computation is
	Generic (
		N_BITS_DAC1 : integer := 16
		);
    Port ( clk : in  STD_LOGIC;
           dac1_minimum : in  STD_LOGIC_VECTOR (N_BITS_DAC1-1 downto 0);
           dac1_maximum : in  STD_LOGIC_VECTOR (N_BITS_DAC1-1 downto 0);
           dac1_current : in  STD_LOGIC_VECTOR (N_BITS_DAC1-1 downto 0);
			  flip_error_sign	: in std_logic;
           dac1_error : out  STD_LOGIC_VECTOR (N_BITS_DAC1+1-1 downto 0));
end dac2_error_computation;

architecture Behavioral of dac2_error_computation is
	signal dac1_desired_setpoint_times_two 	: signed(N_BITS_DAC1+1-1 downto 0) := (others => '0');
	signal dac1_desired_setpoint 					: signed(N_BITS_DAC1+1-1 downto 0) := (others => '0');
	
	signal dac1_error_internal 					: signed(N_BITS_DAC1+1-1 downto 0) := (others => '0');
	signal dac1_error_internal2 					: signed(N_BITS_DAC1+1-1 downto 0) := (others => '0');
	
begin
	process (clk)
	begin
		if rising_edge(clk) then
			-- computes the average of dac1's maximum and minimum's value:
			-- this incurs a bit growth of two, which we cancel in the next assignement
			dac1_desired_setpoint_times_two <=		  resize(signed(dac1_minimum), N_BITS_DAC1+1)
																+ resize(signed(dac1_maximum), N_BITS_DAC1+1);
																
			-- there is no bitgrowth on this value as we simply divide the sum by two.
			-- we keep the signal as N_BITS_DAC1+1 however to prevent overflow of the next computation.
			dac1_desired_setpoint <= shift_right( dac1_desired_setpoint_times_two, 1);
			
			-- computes the error as the subtraction between the computed setpoint and the current value or the opposite sign.
			if flip_error_sign = '1' then
				dac1_error_internal <= dac1_desired_setpoint - resize(signed(dac1_current), N_BITS_DAC1+1);
			else
				dac1_error_internal <= resize(signed(dac1_current), N_BITS_DAC1+1) - dac1_desired_setpoint;
			end if;
			
			-- Extra register stage to make the timing easy to achieve.
			dac1_error_internal2 <= dac1_error_internal;
		end if;
	end process;
	dac1_error <= std_logic_vector(dac1_error_internal2);
	
end Behavioral;

