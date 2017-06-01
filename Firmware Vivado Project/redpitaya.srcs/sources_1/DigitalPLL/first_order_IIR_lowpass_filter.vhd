----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    15:49:34 03/29/2014 
-- Design Name: 
-- Module Name:    first_order_IIR_lowpass_filter - Behavioral 
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

entity first_order_IIR_lowpass_filter is
Generic (
	N_DATA_BITS : integer := 16;
	N_INTERNAL_BITS : integer := 48;
	N_LOG2_TIME_CONSTANT_IN_SAMPLES : integer := 11 -- 100 MHz/(2*pi*2^11) = ~8 kHz cutoff frequency at 100 MHz clock rate
	-- N_INTERNAL_BITS has to be > N_DATA_BITS + N_LOG2_TIME_CONSTANT_IN_SAMPLES
);
    Port ( clk : in  STD_LOGIC;
           data_in : in  STD_LOGIC_VECTOR (N_DATA_BITS-1 downto 0);
			  internal_accumulator : out std_logic_vector( N_INTERNAL_BITS-1 downto 0);
           data_out : out  STD_LOGIC_VECTOR (N_DATA_BITS-1 downto 0));
end first_order_IIR_lowpass_filter;

architecture Behavioral of first_order_IIR_lowpass_filter is
	signal accumulator : signed(N_INTERNAL_BITS-1 downto 0) := (others => '0');
	
begin

	process (clk)
	begin
		if rising_edge(clk) then
			accumulator <= accumulator																	-- this, along with the next time is the leaky integration of the input
								- shift_right(accumulator, N_LOG2_TIME_CONSTANT_IN_SAMPLES)	-- this makes the integrator leaky which makes it converge after approximately 2^N_LOG2_TIME_CONSTANT_IN_SAMPLES
								+ shift_left(resize(signed(data_in), accumulator'length), N_INTERNAL_BITS-N_DATA_BITS-N_LOG2_TIME_CONSTANT_IN_SAMPLES);	-- todo: add input
			-- Note that this division (right shift) has a bias because we are effectively using floor() instead of round.
			-- this is a hit we have to take because 1. some bias doesn't really matter in our phase-lock application, 2. adding half a quantization step before applying the right shift, which is what we need to do to solve this,
			-- could cause the output to wrap for some extreme input values.  I don't really want to implement an explicit saturation either to keep the core simple.
			data_out <= std_logic_vector( resize( shift_right(accumulator, N_INTERNAL_BITS-N_DATA_BITS), data_out'length) );
		end if;
	end process;
	internal_accumulator <= std_logic_vector(accumulator);
	
end Behavioral;

