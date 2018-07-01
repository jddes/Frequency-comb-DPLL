--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   14:02:34 10/23/2013
-- Design Name:   
-- Module Name:   C:/Xilinx_Projects/PLL_2013_test1_ML605/acquisition_FLL_testbench.vhd
-- Project Name:  PLL_2013_test1_ML605
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: acquisition_FLL
-- 
-- Dependencies:
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
--
-- Notes: 
-- This testbench has been automatically generated using types std_logic and
-- std_logic_vector for the ports of the unit under test.  Xilinx recommends
-- that these types always be used for the top-level I/O of a design in order
-- to guarantee that the testbench will bind correctly to the post-implementation 
-- simulation model.
--------------------------------------------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
 
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
USE ieee.numeric_std.ALL;
 
ENTITY acquisition_FLL_testbench IS
END acquisition_FLL_testbench;
 
ARCHITECTURE behavior OF acquisition_FLL_testbench IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
--    COMPONENT acquisition_FLL
--    PORT(
--         rst : IN  std_logic;
--         clk : IN  std_logic;
--         lock : IN  std_logic;
--         frequency_input : IN  std_logic_vector(16 downto 0);
--         gain_right_shift_in_bits : IN  std_logic_vector(4 downto 0);
--         gain_left_shift_in_bits : IN  std_logic_vector(4 downto 0);
--         output : OUT  std_logic_vector(15 downto 0);
--         output_railed : OUT  std_logic
--        );
--    END COMPONENT;
    

   --Inputs
   signal rst : std_logic := '0';
   signal clk : std_logic := '0';
   signal lock, hold : std_logic := '0';
   signal frequency_input : std_logic_vector(10 downto 0) := (others => '0');
   signal gain_right_shift_in_bits : std_logic_vector(4 downto 0) := (others => '0');
   signal gain_left_shift_in_bits : std_logic_vector(4 downto 0) := (others => '0');

 	--Outputs
   signal output : std_logic_vector(19 downto 0);
   signal output_railed : std_logic;

   -- Clock period definitions
   constant clk_period : time := 10 ns;
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: entity work.acquisition_FLL
	GENERIC MAP (
		FREQUENCY_WIDTH => 11,
		OUTPUT_WIDTH => 20
	)
	PORT MAP (
          rst => rst,
          clk => clk,
			 hold => hold,
          lock => lock,
          frequency_input => frequency_input,
          gain_right_shift_in_bits => gain_right_shift_in_bits,
          gain_left_shift_in_bits => gain_left_shift_in_bits,
          data_output => output,
          output_railed => output_railed
        );

   -- Clock process definitions
   clk_process :process
   begin
		clk <= '0';
		wait for clk_period/2;
		clk <= '1';
		wait for clk_period/2;
   end process;
 

   -- Stimulus process
   stim_proc: process
   begin		
      -- hold reset state for 100 ns.
			rst <= '1';
      wait for 100 ns;	
			rst <= '0';
      wait for clk_period*100;
			frequency_input <= std_logic_vector(to_signed(1, frequency_input'length));
      wait for clk_period*100;
			lock <= '1';
      wait for clk_period*100;
			frequency_input <= std_logic_vector(to_signed(0, frequency_input'length));
      wait for clk_period*100;
			frequency_input <= std_logic_vector(to_signed(1, frequency_input'length));
			gain_left_shift_in_bits <= std_logic_vector(to_unsigned(1, gain_left_shift_in_bits'length));
      wait for clk_period*100;
			gain_left_shift_in_bits <= std_logic_vector(to_unsigned(10, gain_left_shift_in_bits'length));
      wait for clk_period*100;
			gain_left_shift_in_bits <= std_logic_vector(to_unsigned(0, gain_left_shift_in_bits'length));
			gain_right_shift_in_bits <= std_logic_vector(to_unsigned(15, gain_left_shift_in_bits'length));

			
      wait for clk_period*100;
			frequency_input <= std_logic_vector(to_signed(2**(frequency_input'length-1)-1, frequency_input'length));
		wait for clk_period*1000;	
		
		-- hold for 1000 clock cycles
		wait until rising_edge(clk);
			hold <= '1';
      wait for clk_period*1000;
		wait until rising_edge(clk);
			hold <= '0';
			
			
			
      wait for clk_period*100;
			gain_left_shift_in_bits <= std_logic_vector(to_unsigned(0, gain_left_shift_in_bits'length));
			gain_right_shift_in_bits <= std_logic_vector(to_unsigned(31, gain_left_shift_in_bits'length));
		wait for clk_period*1000;
			frequency_input <= std_logic_vector(to_signed(-2**(frequency_input'length-1), frequency_input'length));		
		wait for clk_period*100;
			lock <= '0';
			
		wait for clk_period*1000;
			frequency_input <= std_logic_vector(to_signed(-2**(frequency_input'length-1), frequency_input'length));		
			gain_right_shift_in_bits <= std_logic_vector(to_unsigned(22, gain_left_shift_in_bits'length));
			lock <= '1';
		wait for clk_period*100;
			
		wait for clk_period*1000;
			frequency_input <= std_logic_vector(to_signed(-2**(frequency_input'length-1), frequency_input'length));		
			gain_right_shift_in_bits <= std_logic_vector(to_unsigned(0, gain_left_shift_in_bits'length));
			lock <= '1';
		wait for clk_period*100;
		
		wait for clk_period*1000;
			frequency_input <= std_logic_vector(to_signed(2**(frequency_input'length-1)-1, frequency_input'length));		
			gain_right_shift_in_bits <= std_logic_vector(to_unsigned(0, gain_left_shift_in_bits'length));
			lock <= '1';
		wait for clk_period*100;
			
      wait;
		
   end process;

END;
