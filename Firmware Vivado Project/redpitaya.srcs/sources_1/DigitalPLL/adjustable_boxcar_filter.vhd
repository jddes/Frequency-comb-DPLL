----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    13:06:54 04/11/2012 
-- Design Name: 
-- Module Name:    adjustable_boxcar_filter - Behavioral 
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

entity adjustable_boxcar_filter is
	Generic(
		MAXIMUM_SIZE : positive := 256;
		DATA_WIDTH : positive := 16
	);
	Port ( 

		rst : in  STD_LOGIC;
		clk : in  STD_LOGIC;
		
		-- Input port
		input_clk_enable : in std_logic;
		input_data : in std_logic_vector(DATA_WIDTH-1 downto 0);
		
		-- Configuration port.  Note that the reset must be asserted after the size is changed.
		filter_size : in std_logic_vector(11 downto 0);
		
		-- Output port
		output_clk_enable : out std_logic;
		output_data : out std_logic_vector(DATA_WIDTH+12-1 downto 0)
	);
end adjustable_boxcar_filter;

architecture Behavioral of adjustable_boxcar_filter is

	COMPONENT programmable_delay_line
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
	END COMPONENT;
	
	signal input_clk_enable_register : std_logic;
	signal input_register : std_logic_vector(input_data'range);

	signal second_clk_enable_register : std_logic;
	signal second_register : std_logic_vector(input_data'range);
	
	signal delay_line_clk_enable : std_logic;
	signal delayed_data : std_logic_vector(input_data'range);
	
	signal diff_clk_enable : std_logic;
	signal diffed_data : signed(input_data'left+1 downto 0);
	
	signal accum_clk_enable : std_logic;
	signal accumulator_data : signed(input_data'length+12-1 downto 0);

begin


   delay_inst: programmable_delay_line
	GENERIC MAP (
			MAXIMUM_DELAY => MAXIMUM_SIZE,
			DATA_BITS => DATA_WIDTH
	)
	PORT MAP (
          rst => rst,
          clk => clk,
			 
			 -- Input port
          input_clk_enable => input_clk_enable_register,
          data_in => input_register,
			 
				-- Configuration port.  The actual delay will be desired_delay_minus_one_minus_one+1.
				-- Reset must be asserted after changing the delay value in order for the change to take effect.
          desired_delay_minus_one => filter_size,
			 
			 -- Output port
          data_out => delayed_data,
          output_clk_enable => delay_line_clk_enable
        );
		  
		  
	process (clk)
	begin
		if rising_edge(clk) then
			if rst = '1' then
				input_register <= (others => '0');
				
				input_clk_enable_register <= '0';
				second_clk_enable_register <= '0';
				diff_clk_enable <= '0';
				accum_clk_enable <= '0';
				output_clk_enable <= '0';
				
				
				accumulator_data <= (others => '0');
				output_data <= (others => '0');
			else
				
			
				-- Input register
				input_clk_enable_register <= input_clk_enable;
				if input_clk_enable = '1' then
					input_register <= input_data;
				end if;
				
				-- Second register, to match the latency from the delay line (in terms of clock cycles, NOT _enabled_ clock cycles)
				second_clk_enable_register <= input_clk_enable_register;
				if input_clk_enable_register = '1' then
					second_register <= input_register;
				end if;

				
				-- Diff
				diff_clk_enable <= delay_line_clk_enable;
				if delay_line_clk_enable = '1' then
					diffed_data <= resize(signed(second_register), input_register'length+1) - resize(signed(delayed_data), input_register'length+1);
				end if;
				
				-- Accumulator
				accum_clk_enable <= diff_clk_enable;
				if diff_clk_enable = '1' then
					accumulator_data <= accumulator_data + resize(diffed_data, accumulator_data'length);
				end if;
				
				-- Output register
				output_clk_enable <= accum_clk_enable;
				if accum_clk_enable = '1' then
					output_data <= std_logic_vector(accumulator_data);
				end if;
				
			end if;
		end if;
	end process;

end Behavioral;

