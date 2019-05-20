----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    13:06:54 04/11/2012 
-- Design Name: 
-- Module Name:    adjustable_boxcar_filter_v2 - Behavioral 
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
-- Description: Implements a simple boxcar filter of length filter_size. Valid sizes range from 2 to 2**LOG2_MAXIMUM_SIZE-1. Maximum value for maximum size is 2047
-- DC gain is equal to filter length.  It is all implemented in exact integer arithmetic, and bit growth is equal to log2(filter_size).
-- Implementation goal was to minimize extra delay introduced by the filter.  In addition to the boxcar filter's group delay, there is only one extra clock cycle of delay.
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

entity adjustable_boxcar_filter_v2 is
	Generic(
		LOG2_MAXIMUM_SIZE : integer := 8;
		DATA_WIDTH : positive := 16
	);
	Port ( 
		rst : in  STD_LOGIC;
		clk : in  STD_LOGIC;
		
		-- Input port
		input_data : in std_logic_vector(DATA_WIDTH-1 downto 0);
		
		-- Configuration port.  A reset is necessary to update the filter length
		filter_size : in std_logic_vector(LOG2_MAXIMUM_SIZE-1 downto 0);
		
		-- Output port
		output_data : out std_logic_vector(DATA_WIDTH+LOG2_MAXIMUM_SIZE-1 downto 0)
	);
end adjustable_boxcar_filter_v2;

architecture Behavioral of adjustable_boxcar_filter_v2 is
	signal desired_delay_minus_one : std_logic_vector(12-1 downto 0) := (others => '0');
	signal delayed_data : std_logic_vector(input_data'range) := (others => '0');
	signal accumulator :  std_logic_vector(output_data'range) := (others => '0');
begin


   delay_inst: entity work.programmable_delay_line
	GENERIC MAP (
			MAXIMUM_DELAY => 2**LOG2_MAXIMUM_SIZE,
			DATA_BITS => DATA_WIDTH
	)
	PORT MAP (
			rst                     => rst,
			clk                     => clk,
			
			-- Input port
			input_clk_enable        => '1',
			data_in                 => input_data,
			
			-- Configuration port.  The actual delay will be desired_delay_minus_one_minus_one+1.
			desired_delay_minus_one => desired_delay_minus_one,
			
			-- Output port
			output_clk_enable       => open,
			data_out                => delayed_data
        );
	desired_delay_minus_one <= std_logic_vector(resize(unsigned(filter_size)-1, 12));
		  
	process (clk)
	begin
		if rising_edge(clk) then
			
			if rst = '1' then
				accumulator <= (others => '0');
			else
				-- Uses modulo arithmetic, 'accumulator' size should handle all the necessary bit growth
				accumulator <= std_logic_vector(signed(accumulator) + resize(signed(input_data), accumulator'length) - resize(signed(delayed_data), accumulator'length));
			end if;
			
		end if;
	end process;
	output_data <= accumulator;

end Behavioral;

