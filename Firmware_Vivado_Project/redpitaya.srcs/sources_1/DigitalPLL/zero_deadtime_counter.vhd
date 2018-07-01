----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    12:04:43 11/30/2013 
-- Design Name: 
-- Module Name:    zero_deadtime_counter - Behavioral 
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
-- Description: Takes an instantaneous frequency input, applies a simple bandlimiting filter (boxcars with lengths of 2, 3 and 5 convolved),
-- Then integrates the result for ~10 ms (2^LOG2_N_CYCLES_INTEGRATION/fs) (configurable through the LOG2_N_CYCLES_INTEGRATION generic).
-- Output format is a single data word with a clock enable (intented to go to a FIFO).
-- To convert from the results given by the core to frequency, the equation is:
-- f = data_out * fs / 2^N_INPUT_BITS / 2^LOG2_N_CYCLES_INTEGRATION / 2 / 3 / 5
-- This assumes that the input instantaneous frequency is data_in = 2^N_INPUT_BITS * diff(phi)/(2*pi), where phi is the signal phase in radians
-- Bit growth due to the bandwidth liming filter is ceil(log2(2)) + ceil(log2(3)) + ceil(log2(5)) = 1+2+3
-- Bit growth due to the integrate and dump is LOG2_N_CYCLES_INTEGRATION, which makes:
-- Total bit growth: LOG2_N_CYCLES_INTEGRATION + 1+2+3
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

entity zero_deadtime_counter is
	Generic (
		N_INPUT_BITS : integer := 10;
		LOG2_N_CYCLES_INTEGRATION : integer := 5	-- Should give a ~100 Hz output rate for 100 MHz output rate
		);
    Port ( 
				rst : in std_logic;
				clk : in  STD_LOGIC;
           data_in : in  STD_LOGIC_VECTOR (N_INPUT_BITS-1 downto 0);
           data_out : out  STD_LOGIC_VECTOR (N_INPUT_BITS-1+1+2+3+LOG2_N_CYCLES_INTEGRATION downto 0);
           output_clk_enable : out  STD_LOGIC);
end zero_deadtime_counter;

architecture Behavioral of zero_deadtime_counter is
	signal data_in_reg1, data_in_reg2 : std_logic_vector(N_INPUT_BITS-1 downto 0) := (others => '0');
	signal filter1_out : std_logic_vector(N_INPUT_BITS-1+1 downto 0) := (others => '0');
	signal filter2_out_wide : std_logic_vector(N_INPUT_BITS-1+1+12 downto 0) := (others => '0');
	signal filter2_out : std_logic_vector(N_INPUT_BITS-1+1+2 downto 0) := (others => '0');
	
	signal filter3_out_wide : std_logic_vector(N_INPUT_BITS-1+1+2+12 downto 0) := (others => '0');
	signal filter3_out : std_logic_vector(N_INPUT_BITS-1+1+2+3 downto 0) := (others => '0');
begin
	-- First filter (two-points moving average): we do it by hand since it is so small:
	-- Produces ceil(log2(2)) = 1 of bit growth
	process (clk)
	begin
		if rising_edge(clk) then
			data_in_reg1 <= data_in;
			data_in_reg2 <= data_in_reg1;
			filter1_out <= std_logic_vector(resize(signed(data_in_reg1), filter1_out'length)
													+ resize(signed(data_in_reg2), filter1_out'length));
		end if;
	end process;
	
	-- second filter: 3-points moving average
	-- Produces ceil(log2(3)) = 2 of bit growth
   boxcar_filter_2_inst: entity work.adjustable_boxcar_filter
	Generic map (
		MAXIMUM_SIZE => 4,
		DATA_WIDTH => N_INPUT_BITS+1
	)
	PORT MAP (
          rst => rst,
          clk => clk,
          input_clk_enable => '1',
          input_data => filter1_out,
          filter_size => std_logic_vector(to_unsigned(3, 12)),
			 
          output_clk_enable => open,
          output_data => filter2_out_wide
        );
	filter2_out <= filter2_out_wide(filter2_out'range);
	
	-- third filter: 5-points moving average
	-- Produces ceil(log2(5)) = 3 of bit growth
   boxcar_filter_3_inst: entity work.adjustable_boxcar_filter
	Generic map (
		MAXIMUM_SIZE => 6,
		DATA_WIDTH => N_INPUT_BITS+1+2
	)
	PORT MAP (
          rst => rst,
          clk => clk,
          input_clk_enable => '1',
          input_data => filter2_out,
          filter_size => std_logic_vector(to_unsigned(5, 12)),
			 
          output_clk_enable => open,
          output_data => filter3_out_wide
        );
	filter3_out <= filter3_out_wide(filter3_out'range);
	
	-- Integrate and dump filter, N_CYCLES_INTEGRATION
   integrate_and_dump_inst: entity work.integrate_and_dump
	GENERIC MAP (
		N_BITS_CYCLES_COUNTER => LOG2_N_CYCLES_INTEGRATION,
		N_DATA_BITS => filter3_out'length
	)
	PORT MAP (
          rst => rst,
          clk => clk,
          data_in => filter3_out,
          data_output => data_out,
          output_clk_enable => output_clk_enable
        );
		  
end Behavioral;

