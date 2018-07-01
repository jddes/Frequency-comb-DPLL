----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    10:09:13 11/07/2013 
-- Design Name: 
-- Module Name:    multiplexer_NbitsxMsignals_to_Nbits - Behavioral 
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
-- Description: Multiplexes 8 N-bits signals into 1 N-bit signal, through two multiplexing stages, and an intermediate registers stage.
-- Total delay is 3 clock cycles from input to output when this input is selected.
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
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity multiplexer_NbitsxMsignals_to_Nbits is
	Generic (
		N_bits_per_signal : integer := 17
		
		);
    Port ( 
           clk : in  STD_LOGIC;
			  
			  -- If the input signal contains a clock enable, we just need to concatenate it with the data bits to ensure it gets the same delay as the signal
           in0 : in  STD_LOGIC_VECTOR (N_bits_per_signal-1 downto 0);
           in1 : in  STD_LOGIC_VECTOR (N_bits_per_signal-1 downto 0);
           in2 : in  STD_LOGIC_VECTOR (N_bits_per_signal-1 downto 0);
           in3 : in  STD_LOGIC_VECTOR (N_bits_per_signal-1 downto 0);
           in4 : in  STD_LOGIC_VECTOR (N_bits_per_signal-1 downto 0);
           in5 : in  STD_LOGIC_VECTOR (N_bits_per_signal-1 downto 0);
           in6 : in  STD_LOGIC_VECTOR (N_bits_per_signal-1 downto 0);
           in7 : in  STD_LOGIC_VECTOR (N_bits_per_signal-1 downto 0);
			  
			  in8 : in  STD_LOGIC_VECTOR (N_bits_per_signal-1 downto 0);
			  in9 : in  STD_LOGIC_VECTOR (N_bits_per_signal-1 downto 0);
			  in10 : in  STD_LOGIC_VECTOR (N_bits_per_signal-1 downto 0);
			  
           selector : in  STD_LOGIC_VECTOR (4 downto 0);
           selected_output : out  STD_LOGIC_VECTOR (N_bits_per_signal-1 downto 0)
			  
			  );
end multiplexer_NbitsxMsignals_to_Nbits;

architecture Behavioral of multiplexer_NbitsxMsignals_to_Nbits is
	signal mux01, mux23, mux45, mux67 : std_logic_vector(N_bits_per_signal-1 downto 0);
	signal mux01_reg, mux23_reg, mux45_reg, mux67_reg : std_logic_vector(N_bits_per_signal-1 downto 0);
	signal mux01234567_reg : std_logic_vector(N_bits_per_signal-1 downto 0);
	
begin

	-- The multiplexer architecture is:
	-- Signals are first muxed in pairs in 2-to-1 muxes, then an extra register stage to help with the routing, then they all go through a 4-to-1 mux
	-- This design is done to help with the locality of signals: pairs of sources that are close together should be connected to a pair of signals that goes to a single mux
	-- for example, (in0 + in1), (in2 + in3), ...
	
	
	-- Implements the first 2-to-1 mux stage
	process (clk)
	begin
		if rising_edge(clk) then
			case selector(0) is
				when '0' =>
					mux01 <= in0;
					mux23 <= in2;
					mux45 <= in4;
					mux67 <= in6;
				when '1' =>
					mux01 <= in1;
					mux23 <= in3;
					mux45 <= in5;
					mux67 <= in7;
				when others =>
					-- shouldn't be possible except in simulation, just to keep synthesis appy
					mux01 <= in0;
					mux23 <= in2;
					mux45 <= in4;
					mux67 <= in6;
				end case;
		end if;
	end process;
	
	-- Implements the intermediate registers (to help with splitting up routing delays between clock cycles)
	process (clk)
	begin
		if rising_edge(clk) then
			mux01_reg <= mux01;
			mux23_reg <= mux23;
			mux45_reg <= mux45;
			mux67_reg <= mux67;
		end if;
	end process;
	
	-- Implements the second 4-to-1 mux stage.
	process (clk)
	begin
		if rising_edge(clk) then
			case selector(2 downto 1) is
				when b"00" =>
					mux01234567_reg <= mux01_reg;
				when b"01" =>
					mux01234567_reg <= mux23_reg;
				when b"10" =>
					mux01234567_reg <= mux45_reg;
				when b"11" =>
					mux01234567_reg <= mux67_reg;
				when others =>
					mux01234567_reg <= mux01_reg;	-- shouldn't be possible except in simulation, just to keep synthesis appy
				end case;
		end if;
	end process;
	
	-- Implements the last 4-to-1 mux stage.
	process (clk)
	begin
		if rising_edge(clk) then
			case selector(4 downto 3) is
				when b"00" =>
					selected_output <= mux01234567_reg;
				when b"01" =>
					selected_output <= in8;
				when b"10" =>
					selected_output <= in9;
				when b"11" =>
					selected_output <= in10;
				when others =>
					selected_output <= mux01234567_reg;	-- shouldn't be possible except in simulation, just to keep synthesis appy
				end case;
		end if;
	end process;
	

end Behavioral;

