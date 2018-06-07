----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    15:52:50 04/09/2012 
-- Design Name: 
-- Module Name:    integrate_and_dump - Behavioral 
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
--	This module integrates the input for 2^N_BITS_CYCLES_COUNTER, then outputs the result.
-- This makes a boxcar filter on the input signal with a DC gain of 2^N_BITS_CYCLES_COUNTER,
-- Whose output is sampled at fs/2^N_BITS_CYCLES_COUNTER, where fs is the input clock rate.
-- There is only one additional delay (in addition to the (2^N_BITS_CYCLES_COUNTER)/2 group delay of the filter.
-- The output is scaled accordingly for bit growth and should never wrap or saturate regardless of the input value
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

entity integrate_and_dump is
	Generic (
		N_BITS_CYCLES_COUNTER : positive := 4;
		N_DATA_BITS : positive := 8
		);
    Port ( rst : in  STD_LOGIC;
           clk : in  STD_LOGIC;
			  
			  -- Data input
           data_in : in  STD_LOGIC_VECTOR (N_DATA_BITS-1 downto 0);
			  
			  -- Data output
           data_output : out  STD_LOGIC_VECTOR (N_DATA_BITS+N_BITS_CYCLES_COUNTER-1 downto 0);
			  output_clk_enable : out std_logic
			  
			  );
end integrate_and_dump;

architecture Behavioral of integrate_and_dump is
	signal accumulator : signed(N_DATA_BITS+N_BITS_CYCLES_COUNTER-1 downto 0) := (others => '0');
	signal data_out_register : signed(N_DATA_BITS+N_BITS_CYCLES_COUNTER-1 downto 0) := (others => '0');
	signal clk_cycles_counter : unsigned(N_BITS_CYCLES_COUNTER-1 downto 0) := (others => '0');
--	signal output_clk_enable_register : std_logic;
	
begin

	
	process (clk)
	begin
		if rising_edge(clk) then
			if rst = '1' then
				accumulator <= (others => '0');
				clk_cycles_counter <= (others => '0');
--				output_clk_enable_register <= '0';
				output_clk_enable <= '0';
			else
			
				-- The counter is always running and overflows to signal the end of the cycle
				clk_cycles_counter <= clk_cycles_counter + 1;
				
				if clk_cycles_counter = 0 then
					-- Reset the integrator and 
					accumulator <= resize(signed(data_in), accumulator'length);
					-- output new value
					output_clk_enable <= '1';
					data_out_register <= accumulator;

				else
					-- We are integrating:
					accumulator <= accumulator + resize(signed(data_in), accumulator'length);
					-- No new output
					output_clk_enable <= '0';
				end if;
					
			end if;
		end if;
			
	end process;

	data_output <= std_logic_vector(data_out_register);

end Behavioral;

