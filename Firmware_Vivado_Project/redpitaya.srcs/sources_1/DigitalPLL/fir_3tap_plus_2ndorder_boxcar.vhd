----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    09:38:09 01/30/2014 
-- Design Name: 
-- Module Name:    fir_3tap_plus_2ndorder_boxcar - Behavioral 
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

entity fir_3tap_plus_2ndorder_boxcar is
	Generic (
		N_BITS_DATA : integer := 16;
		N_BITS_COEFFS : integer := 18

	
	);
    Port ( rst : in  STD_LOGIC;
           clk : in  STD_LOGIC;
			  
			  data_input : in std_logic_vector(N_BITS_DATA-1 downto 0);
			  
			  -- TODO: Add register interface to enable programming of the filter coefficients
			  data_output : out std_logic_vector(N_BITS_DATA-1 downto 0)
			  
			  
			  );
end fir_3tap_plus_2ndorder_boxcar;

architecture Behavioral of fir_3tap_plus_2ndorder_boxcar is
	-- Data delay line for the implementation of the FIR:
	signal data0, data1, data2 : signed(N_BITS_DATA-1 downto 0) := (others => '0');

	signal coeff0, coeff1, coeff2 : signed(N_BITS_COEFFS-1 downto 0) := to_signed(1, N_BITS_COEFFS);
	signal fir_3tap_sum : signed(N_BITS_COEFFS+N_BITS_DATA+2-1 downto 0) := (others => '0');
	signal fir_3tap_before_boxcars : std_logic_vector(N_BITS_COEFFS+N_BITS_DATA+2-1 downto 0) := (others => '0');
	
	signal bBypass : std_logic := '0';	-- bBypass = '1' means that the output is directly equal to the input, with a single clock cycle of delay
	
	constant LOG2_MAXIMUM_SIZE : integer := 5;	-- should be equal to ceil(BOXCAR_FILTER_SIZE)
	constant BOXCAR_FILTER_SIZE : std_logic_vector(LOG2_MAXIMUM_SIZE-1 downto 0) := std_logic_vector(to_unsigned(20, LOG2_MAXIMUM_SIZE));	-- 20 samples, to yield a first zero at fs/20 = 5 MHz
	signal boxcar1_output : std_logic_vector(fir_3tap_before_boxcars'length+LOG2_MAXIMUM_SIZE-1 downto 0) := (others => '0');
	signal boxcar2_output : std_logic_vector(fir_3tap_before_boxcars'length+LOG2_MAXIMUM_SIZE+LOG2_MAXIMUM_SIZE-1 downto 0) := (others => '0');
	
	-- the output is equal to the output of the FIR, divided by N_DIVIDE_OUTPUT.
	-- This is to try to match the overall DC gain of this block to be as close to 1 as possible.
	-- Currently, FIR_GAIN is set to 8.  This is design parameter in the MATLAB file which is used to generate the filter's coefficients.
	constant N_DIVIDE_OUTPUT : integer := 11; -- this is 2^11, which is close to the actual DC gain of FIR_GAIN*20*20 = 2^(8.6) * 2^(
	signal data_output_scaled : signed(boxcar2_output'length-1 downto 0) := (others => '0');
	constant OUTPUT_MAX : signed(data_output_scaled'length-1 downto 0) := shift_left(to_signed(1, data_output_scaled'length), data_output_scaled'length-1)-1;	-- (2^(N-1)-1)
	constant OUTPUT_MIN : signed(data_output_scaled'length-1 downto 0) := shift_left(to_signed(-1, data_output_scaled'length), data_output_scaled'length-1);	-- (-2**(N-1))
	signal data_output_internal : signed(N_BITS_DATA-1 downto 0) := (others => '0');
	
begin
	-- for debug: hardcode the filter's coefficients to compensate for a 14 dB PZT resonance at 600 kHz:
	coeff0 <= to_signed(4283, N_BITS_COEFFS);
	coeff1 <= to_signed(-8527, N_BITS_COEFFS);
	coeff2 <= to_signed(4250, N_BITS_COEFFS);


	-- Three-taps FIR filter:
	process (clk)
	begin
		if rising_edge(clk) then
			-- tapped delay line:
			data0 <= signed(data_input);
			data1 <= data0;
			data2 <= data1;
		
			-- full-precision multiply-accumulate:
			fir_3tap_sum <= 		resize(coeff0*data0, fir_3tap_sum'length)
										+ resize(coeff1*data1, fir_3tap_sum'length)
										+ resize(coeff2*data2, fir_3tap_sum'length);
			
		end if;
	end process;
	fir_3tap_before_boxcars <= std_logic_vector(fir_3tap_sum);	-- conversion to std_logic_vector for interfacing purposes
	
	
	-- Two cascaded boxcar filters:
	-- These filters have a DC gain equal to their lengths (they output boxcar_filter_size summed samples)
   boxcar_filter1_inst: entity work.adjustable_boxcar_filter_v2
	Generic map (
		LOG2_MAXIMUM_SIZE => LOG2_MAXIMUM_SIZE,	--2**LOG2_MAXIMUM_SIZE maximum points (or maybe 2**LOG2_MAXIMUM_SIZE - didnt test thoroughly near the max)
		DATA_WIDTH => fir_3tap_before_boxcars'length
	)
	PORT MAP (
          rst => rst,
          clk => clk,
          input_data => fir_3tap_before_boxcars,
          filter_size => BOXCAR_FILTER_SIZE,
			 
          output_data => boxcar1_output
        );
		  
   boxcar_filter2_inst: entity work.adjustable_boxcar_filter_v2
	Generic map (
		LOG2_MAXIMUM_SIZE => LOG2_MAXIMUM_SIZE,	--2**LOG2_MAXIMUM_SIZE maximum points (or maybe 2**LOG2_MAXIMUM_SIZE - didnt test thoroughly near the max)
		DATA_WIDTH => boxcar1_output'length
	)
	PORT MAP (
          rst => rst,
          clk => clk,
          input_data => boxcar1_output,
          filter_size => BOXCAR_FILTER_SIZE,
			 
          output_data => boxcar2_output
        );
	
	-- output driver:
	-- Also implements the division by 2^N_DIVIDE_OUTPUT and the saturation of the result to the output range
	process (clk)
	begin
		if rising_edge(clk) then
			if bBypass = '1' then
				data_output_internal <= signed(data_input);
			else
				-- Divide boxcar filters' output by 2^N_DIVIDE_OUTPUT to bring DC gain close to 0
				data_output_scaled <= shift_right(signed(boxcar2_output), N_DIVIDE_OUTPUT);
				
				-- Assign output with saturation:
				if data_output_scaled > OUTPUT_MAX then
					-- railed positive
					data_output_internal <= OUTPUT_MAX(data_output_internal'range);
				elsif data_output_scaled < OUTPUT_MIN then
					-- railed negative
					data_output_internal <= OUTPUT_MIN(data_output_internal'range);
				else
					-- linear range
					data_output_internal <= data_output_scaled(data_output_internal'range);
				end if;
--				data_output_internal <= data_output_scaled;
			end if;
		end if;
	end process;
	data_output <= std_logic_vector(data_output_internal);

end Behavioral;

