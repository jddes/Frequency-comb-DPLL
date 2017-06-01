----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    17:13:42 02/09/2014 
-- Design Name: 
-- Module Name:    quadrature_dither_generator - Behavioral 
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

entity quadrature_dither_generator is
	Generic (
		N_BITS_OUTPUT : integer := 16;
		COUNTER_BITS : integer := 27	-- 27 bits gives ~ 134 Millions clock cycles, or 1.34 seconds at 100 MHz clock rate
	
	);
    Port ( clk : in  STD_LOGIC;
           modulation_period_divided_by_4_minus_one : in  STD_LOGIC_VECTOR (COUNTER_BITS-1 downto 0);
           modulation_amplitude : in  STD_LOGIC_VECTOR (N_BITS_OUTPUT-1 downto 0);
           bOutputEnable : in  STD_LOGIC;
           output_to_dac : out  STD_LOGIC_VECTOR (N_BITS_OUTPUT-1 downto 0);
           sync_I : out  STD_LOGIC;
           sync_Q : out  STD_LOGIC);
end quadrature_dither_generator;

architecture Behavioral of quadrature_dither_generator is
	signal counter : unsigned(COUNTER_BITS-1 downto 0) := (others => '0');
	
	signal current_state : unsigned(1 downto 0) := (others => '0');
	
	-- outputs
	signal output_to_dac_internal : STD_LOGIC_VECTOR (N_BITS_OUTPUT-1 downto 0) := (others => '0');
	signal sync_I_internal, sync_Q_internal, sync_I_internal2, sync_Q_internal2 : std_logic := '0';
begin
	-- Simple counter from 0 to modulation_period_divided_by_4_minus_one
	process (clk)
	begin
		if rising_edge(clk) then
			if counter < unsigned(modulation_period_divided_by_4_minus_one) then
				counter <= counter + 1;
			else
				counter <= (others => '0');
			end if;
		end if;
	end process;


	-- This process loops between four states, switching every time the counter reaches 0.
	process (clk)
	begin
		if rising_edge(clk) then
			if counter = 0 then
				current_state <= current_state + 1;
			end if;
			
			-- Output decoder:
			case current_state is
				when b"00" =>
					sync_I_internal <= '1';
					sync_Q_internal <= '0';
				when b"01" =>
					sync_I_internal <= '1';
					sync_Q_internal <= '1';
				when b"10" =>
					sync_I_internal <= '0';
					sync_Q_internal <= '1';
				when b"11" =>
					sync_I_internal <= '0';
					sync_Q_internal <= '0';
				when others =>
					-- essentially only for simulation
					sync_I_internal <= '0';
					sync_Q_internal <= '0';
			end case;

		end if;
	end process;
	
	
	-- Output process:
	-- computes output_to_dac based on sync_I_internal, and delays the sync_I and Q signals
	process (clk)
	begin
		if rising_edge(clk) then
			if bOutputEnable = '1' then
				if sync_I_internal = '1' then
					-- output_to_dac = +modulation_amplitude
					output_to_dac_internal <= modulation_amplitude;
				else
					-- output_to_dac = -modulation_amplitude
					output_to_dac_internal <= std_logic_vector(-signed(modulation_amplitude));
				end if;
			else
				-- output_to_dac = 0
				output_to_dac_internal <= (others => '0');
			end if;

			-- Extra delay stage, to make the output line up with the sync outputs:
			sync_I_internal2 <= sync_I_internal;
			sync_Q_internal2 <= sync_Q_internal;
		end if;
	end process;
	sync_I <= sync_I_internal2;
	sync_Q <= sync_Q_internal2;
	output_to_dac <= output_to_dac_internal;
	
end Behavioral;

