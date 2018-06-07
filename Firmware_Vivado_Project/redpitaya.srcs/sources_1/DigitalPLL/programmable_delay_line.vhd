----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    13:55:37 03/25/2012 
-- Design Name: 
-- Module Name:    programmable_delay_line - Behavioral 
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
use ieee.std_logic_unsigned.all;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity programmable_delay_line is
	Generic (
				MAXIMUM_DELAY	: positive := 16;		-- maximum supported value is 2048, since the addresses are 12 bits.
				DATA_BITS		: positive := 16
	);
	Port (
				rst : in  STD_LOGIC;
				clk : in  STD_LOGIC;
				
				-- Input port
				input_clk_enable : in  STD_LOGIC;
				data_in : in  STD_LOGIC_VECTOR (DATA_BITS-1 downto 0);
				
				-- Configuration port.  The actual delay will be desired_delay_minus_one_minus_one+1.
				-- Reset must be asserted after changing the delay value in order for the change to take effect.
				desired_delay_minus_one : in  STD_LOGIC_VECTOR (11 downto 0);
				
				-- Output port
				data_out : out  STD_LOGIC_VECTOR (DATA_BITS-1 downto 0);
				output_clk_enable : out  STD_LOGIC

	);
end programmable_delay_line;

architecture Behavioral of programmable_delay_line is

	-- RAM data signals
	type ram_type is array (MAXIMUM_DELAY-1 downto 0) of std_logic_vector (DATA_BITS-1 downto 0);
	signal RAM: ram_type;
	signal RAM_input : std_logic_vector(DATA_BITS-1 downto 0) := (others => '0');
	signal RAM_output : std_logic_vector(DATA_BITS-1 downto 0) := (others => '0');

	-- RAM control signals
	signal write_address : std_logic_vector(11 downto 0) := (others => '0');
	signal read_address : std_logic_vector(11 downto 0) := (others => '0');
	
	-- To ensure that we never output undefined data:
--	signal reset_counter : std_logic_vector(11 downto 0) := (others => '0');
	signal reset_complete : std_logic := '0';

begin
	-- This process describes the RAM, which is accessed as a circular buffer of size MAXIMUM_DELAY.
	process (clk)
	begin
		if rising_edge(clk) then
			if rst = '1' then
				-- Initializes the read/write pointers with the desired offset:
				read_address <= (others => '0');
				write_address <= desired_delay_minus_one;
				output_clk_enable <= '0';
--				reset_counter <= (others => '0');
				reset_complete <= '0';
				RAM_output <= (others => '0');
			else
			
				
				output_clk_enable <= input_clk_enable;
				-- RAM read, conditionnal to read address being filled with valid data
				if input_clk_enable = '1' and reset_complete = '1' then
					-- Normal circular buffer behavior
					RAM_output <= RAM(conv_integer(read_address));						
				elsif input_clk_enable = '1' then
					-- Wait until we reach an address with valid data:
					RAM_output <= (others => '0');
					if read_address = desired_delay_minus_one-1 then
						reset_complete <= '1';
					end if;
				
				end if;
				
--				-- RAM read, conditionnal to read address being filled with valid data
--				if input_clk_enable = '1' and reset_counter = desired_delay_minus_one then
--					-- Normal circular buffer behavior
--					RAM_output <= RAM(conv_integer(read_address));						
----					output_clk_enable <= input_clk_enable;
--				elsif input_clk_enable = '1' then
--					-- Wait until we reach an address with valid data:
--					RAM_output <= (others => '0');
--					reset_counter <= reset_counter + 1;
----					output_clk_enable <= '0';
--				
--				end if;
				
				if input_clk_enable = '1' then
					-- RAM write
					RAM(conv_integer(write_address)) <= RAM_input;
					
					-- Increment the write/read pointers modulo MAXIMUM_DELAY.
					if write_address < MAXIMUM_DELAY-1 then
						write_address <= write_address + 1;
					else
						write_address <= (others => '0');
					end if;
					if read_address < MAXIMUM_DELAY-1 then
						read_address <= read_address + 1;
					else
						read_address <= (others => '0');
					end if;
						
						
				end if;
				
			end if;
			
		end if;
	end process;

	RAM_input <= data_in;
	data_out <= RAM_output;

end Behavioral;

