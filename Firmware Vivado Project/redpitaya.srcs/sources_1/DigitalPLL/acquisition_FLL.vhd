----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    12:06:10 10/23/2013 
-- Design Name: 
-- Module Name:    acquisition_FLL - Behavioral 
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
--use IEEE.NUMERIC_BIT.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity acquisition_FLL is
	GENERIC (
		FREQUENCY_WIDTH : positive := 16;
		OUTPUT_WIDTH : positive := 16;
		MAX_GAIN_IN_BITS : positive := 31
	
	);
    Port ( rst : in  STD_LOGIC;
           clk : in  STD_LOGIC;
			  
			  -- Inputs
			  hold : in std_logic;
           lock : in  STD_LOGIC;
           frequency_input : in  STD_LOGIC_VECTOR (FREQUENCY_WIDTH-1 downto 0);
           gain_right_shift_in_bits : in  STD_LOGIC_VECTOR (4 downto 0);
			  gain_left_shift_in_bits : in  STD_LOGIC_VECTOR (4 downto 0);
			  
			  -- Outputs
           data_output : out  STD_LOGIC_VECTOR (OUTPUT_WIDTH-1 downto 0);
           output_railed : out  STD_LOGIC
			  );
end acquisition_FLL;

architecture Behavioral of acquisition_FLL is
	signal accumulator : signed (FREQUENCY_WIDTH+MAX_GAIN_IN_BITS+OUTPUT_WIDTH-FREQUENCY_WIDTH-1 downto 0) := (others => '0');
	signal output_left_shift_register : signed(data_output'range) := (others => '0');
	signal output_right_shift_register : signed(data_output'range) := (others => '0');
	signal output_register : signed(data_output'range) := (others => '0');
	
	signal POSITIVE_LIMIT : signed(accumulator'range);
	signal NEGATIVE_LIMIT : signed(accumulator'range);
	
begin
	
	process (clk)
		variable frequency_input_sign : std_logic := '0';
		variable railed_positive : std_logic := '0';
		variable railed_negative : std_logic := '0';
		variable railed_both : std_logic_vector(1 downto 0) := b"00";
		
		variable right_shift_temp : signed(accumulator'range);
		variable left_shift_temp : signed(accumulator'range);
	begin
		if rising_edge(clk) then
			-- POSITIVE_LIMIT = (2^(OUTPUT_WIDTH-1)-1) * 2^(-gain_left_shift_in_bits +gain_right_shift_in_bits)
			POSITIVE_LIMIT <= shift_left(shift_right(to_signed(2**(OUTPUT_WIDTH-1)-1, POSITIVE_LIMIT'length), to_integer(unsigned(gain_left_shift_in_bits))), to_integer(unsigned(gain_right_shift_in_bits)));
			NEGATIVE_LIMIT <= -POSITIVE_LIMIT;
		
			if rst = '1' then
				accumulator <= (others => '0');
				output_left_shift_register			<= (others => '0');
				output_right_shift_register		<= (others => '0');
				output_register						<= (others => '0');
				output_railed							<= '0';
			else
				-- If we are in lock, we integrate the input
				-- If we are not in lock, ideally we would we slowly ramp back the accumulator to 0.
				-- Right now the output simply resets right away to 0.  If we want to use this block with an actual PLL,
				-- We will at least have to include something to hold the output steady once the PLL locks.
				if lock = '0' then
					-- TODO: Slowly ramp back to 0 (in approximately 1 second) instead of resetting right away
					accumulator <= (others => '0');
					output_railed <= '0';
					
					output_left_shift_register <= (others => '0');
					output_right_shift_register <= (others => '0');
					
				else
					-- We are in lock, integrate as long as we are not saturated
					
					-- Check the correct limit depending on the sign of the input:
					-- Note that frequency_input_sign is a variable and not a signal so it gets updated right away
					if signed(frequency_input) > 0 then
						frequency_input_sign := '1';
					else
						frequency_input_sign := '0';
					end if;
					
					if accumulator > POSITIVE_LIMIT then
						railed_positive := '1';
					else
						railed_positive := '0';
					end if;
					
					if accumulator < NEGATIVE_LIMIT then
						railed_negative := '1';
					else
						railed_negative := '0';
					end if;
					railed_both := railed_positive & railed_negative;
					output_railed <= railed_positive or railed_negative;
					
					-- Implement the accumulator with limits
					if (frequency_input_sign = '1' and railed_positive = '1') or (frequency_input_sign = '0' and railed_negative = '1') or (hold = '1') then
						-- Do nothing because we are railed and the error signal is in the wrong direction
					else
						-- Integrate
						accumulator <= accumulator + resize(signed(frequency_input), accumulator'length);
					end if;
					
					
					
					-- Apply a gain (left-shift or right-shift) between the accumulator and the output register
					-- Then assign the output using the appropriate range.
					-- There are three possibilities: we are railed positive, we are railed negative, or we are within bounds.
					if railed_positive = '0' and railed_negative = '0' then
						-- Within bounds
						-- Implement the left or right shift of the accumulator value
						left_shift_temp := shift_left(accumulator, to_integer(unsigned(gain_left_shift_in_bits)));
						right_shift_temp := shift_right(accumulator, to_integer(unsigned(gain_right_shift_in_bits)));
						
						-- Truncate the value
						output_left_shift_register <= left_shift_temp(output_left_shift_register'range);
						output_right_shift_register <= right_shift_temp(output_left_shift_register'range);
						
					elsif railed_positive = '1' then
						-- Railed positive
						output_left_shift_register <= to_signed(2**(OUTPUT_WIDTH-1)-1, OUTPUT_WIDTH);
						output_right_shift_register <= to_signed(2**(OUTPUT_WIDTH-1)-1, OUTPUT_WIDTH);
					else
						-- Railed negative
						output_left_shift_register <= to_signed(-2**(OUTPUT_WIDTH-1), OUTPUT_WIDTH);
						output_right_shift_register <= to_signed(-2**(OUTPUT_WIDTH-1), OUTPUT_WIDTH);
					end if;
					
					
					
				end if;
				
				-- Choose whether we use the left or right shift for the gain:
				if unsigned(gain_left_shift_in_bits) > 0 then
					output_register <= output_left_shift_register;
				else
					output_register <= output_right_shift_register;
				end if;
				
			end if;
		end if;
	end process;
	
	
	data_output <= std_logic_vector(output_register);

end Behavioral;

