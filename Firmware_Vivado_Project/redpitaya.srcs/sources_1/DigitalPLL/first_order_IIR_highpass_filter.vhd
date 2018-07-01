----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    16:42:01 03/29/2014 
-- Design Name: 
-- Module Name:    first_order_IIR_highpass_filter - Behavioral 
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

entity first_order_IIR_highpass_filter is
Generic (
	N_DATA_BITS : integer := 16;
	N_INTERNAL_BITS : integer := 48;
	N_LOG2_TIME_CONSTANT_IN_SAMPLES : integer := 11 -- 100 MHz/(2*pi*2^11) = ~8 kHz cutoff frequency at 100 MHz clock rate
	-- N_INTERNAL_BITS has to be > N_DATA_BITS + N_LOG2_TIME_CONSTANT_IN_SAMPLES
);
    Port ( clk : in  STD_LOGIC;
           data_in : in  STD_LOGIC_VECTOR (N_DATA_BITS-1 downto 0);
           data_out : out  STD_LOGIC_VECTOR (N_DATA_BITS-1 downto 0));
end first_order_IIR_highpass_filter;

architecture Behavioral of first_order_IIR_highpass_filter is
	signal accumulator : signed(N_INTERNAL_BITS-1 downto 0) := (others => '0');
	signal data_out_internal : signed(N_INTERNAL_BITS-1 downto 0) := (others => '0');
begin

		  
	process (clk)
	begin
		if rising_edge(clk) then
			accumulator <= accumulator																	-- this, along with the next time is the leaky integration of the input
								- shift_right(accumulator, N_LOG2_TIME_CONSTANT_IN_SAMPLES)	-- this makes the integrator leaky which makes it converge after approximately 2^N_LOG2_TIME_CONSTANT_IN_SAMPLES
								+ shift_left(resize(signed(data_in), accumulator'length), N_INTERNAL_BITS-N_DATA_BITS-N_LOG2_TIME_CONSTANT_IN_SAMPLES-2);

			data_out_internal <= 
							shift_left(resize(signed(data_in), accumulator'length), N_INTERNAL_BITS-N_DATA_BITS-2) - accumulator
							+ shift_left(to_signed(1, accumulator'length), N_INTERNAL_BITS-N_DATA_BITS-2-1);
		end if;
	end process;
	data_out <= std_logic_vector( resize( shift_right( data_out_internal, N_INTERNAL_BITS-N_DATA_BITS-2), data_out'length) );

end Behavioral;

