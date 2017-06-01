----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    10:12:20 02/06/2014 
-- Design Name: 
-- Module Name:    serialize_register_value - Behavioral 
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

entity serialize_register_value is
	generic (
		N_BITS_INPUT : integer := 8;
		WAIT_COUNTER_BITS : integer := 23
		);
    Port ( clk : in  STD_LOGIC;
           register_in : in  STD_LOGIC_VECTOR (N_BITS_INPUT-1 downto 0);
           serial_out : out  STD_LOGIC);
end serialize_register_value;

architecture Behavioral of serialize_register_value is
	signal wait_counter : unsigned(WAIT_COUNTER_BITS-1 downto 0) := (others => '0');
	
	signal bWaiting : std_logic := '1';
	signal bits_counter : unsigned(WAIT_COUNTER_BITS-1 downto 0) := (others => '0');
	
	signal register_srl : STD_LOGIC_VECTOR (N_BITS_INPUT-1 downto 0) := (others => '0');
	signal serial_out_internal : std_logic := '0';
begin

	process (clk)
	begin
		if rising_edge(clk) then
			wait_counter <= wait_counter + 1;
			
			-- this is really like a small state machine
			if bWaiting = '1' then
			
				
				register_srl <= register_in;
				bits_counter <= (others => '0');
				
				if wait_counter = 0 then
					-- Switch to the other state (serialize the input)
					bWaiting <= '0';
					-- Output a start bit
					serial_out_internal <= '1';
				else
					serial_out_internal <= '0';
				end if;
				
			else
			

				register_srl <= (register_srl(register_srl'left-1 downto 0) & '0');
				serial_out_internal <= register_srl(register_srl'left);
				
				-- Wait until serialization is finished
				if bits_counter < N_BITS_INPUT then
					bits_counter <= bits_counter + 1;
				else
					bWaiting <= '1';
				end if;
				
			end if;
		end if;
	end process;
	
	serial_out <= serial_out_internal;
end Behavioral;

