--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   18:08:55 10/23/2013
-- Design Name:   
-- Module Name:   C:/Xilinx_Projects/PLL_2013_test1_ML605/system_identification_testbench.vhd
-- Project Name:  PLL_2013_test1_ML605
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: system_identification
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
 
ENTITY system_identification_testbench IS
END system_identification_testbench;
 
ARCHITECTURE behavior OF system_identification_testbench IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT system_identification
    PORT(
         rst : IN  std_logic;
         clk : IN  std_logic;
         number_of_cycles_integration : IN  std_logic_vector(31 downto 0);
         first_modulation_frequency : IN  std_logic_vector(47 downto 0);
         modulation_frequency_step : IN  std_logic_vector(47 downto 0);
         number_of_frequencies : IN  std_logic_vector(15 downto 0);
         output_gain : IN  std_logic_vector(17 downto 0);
         trigger_identification : IN  std_logic;
         data_in : IN  std_logic_vector(9 downto 0);
         modulation_output : OUT  std_logic_vector(15 downto 0);
         integrator_real_output : OUT  std_logic_vector(32 downto 0);
         integrator_imag_output : OUT  std_logic_vector(32 downto 0);
         integrator_clk_output_enable : OUT  std_logic;
         debug_current_state : OUT  std_logic_vector(7 downto 0)
        );
    END COMPONENT;
    

   --Inputs
   signal rst : std_logic := '0';
   signal clk : std_logic := '0';
   signal number_of_cycles_integration : std_logic_vector(31 downto 0) := (others => '0');
   signal first_modulation_frequency : std_logic_vector(47 downto 0) := (others => '0');
   signal modulation_frequency_step : std_logic_vector(47 downto 0) := (others => '0');
   signal number_of_frequencies : std_logic_vector(15 downto 0) := (others => '0');
   signal output_gain : std_logic_vector(17 downto 0) := (others => '0');
   signal trigger_identification : std_logic := '0';
   signal data_in : std_logic_vector(9 downto 0) := (others => '0');
	
	-- Filters the output and feeds it back to itself:
	signal data_in_wide : std_logic_vector(16-1+12 downto 0) := (others => '0');
	signal step_vector : std_logic_vector(15 downto 0) := (others => '0');

 	--Outputs
   signal modulation_output : std_logic_vector(15 downto 0);
   signal integrator_real_output : std_logic_vector(32 downto 0);
   signal integrator_imag_output : std_logic_vector(32 downto 0);
   signal integrator_clk_output_enable : std_logic;
   signal debug_current_state : std_logic_vector(7 downto 0);

   -- Clock period definitions
   constant clk_period : time := 10 ns;
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: system_identification PORT MAP (
          rst => rst,
          clk => clk,
          number_of_cycles_integration => number_of_cycles_integration,
          first_modulation_frequency => first_modulation_frequency,
          modulation_frequency_step => modulation_frequency_step,
          number_of_frequencies => number_of_frequencies,
          output_gain => output_gain,
          trigger_identification => trigger_identification,
          data_in => data_in,
          modulation_output => modulation_output,
          integrator_real_output => integrator_real_output,
          integrator_imag_output => integrator_imag_output,
          integrator_clk_output_enable => integrator_clk_output_enable,
          debug_current_state => debug_current_state
        );
		  
	-- Constant inputs:
	number_of_cycles_integration <= std_logic_vector(to_unsigned(1000, number_of_cycles_integration'length));
	
	number_of_frequencies <= std_logic_vector(to_unsigned(9, number_of_frequencies'length));
	output_gain <= std_logic_vector(to_signed(2**9-1, 18));
	
	-- loop back the output to the input:
	with rst select
	data_in <=		data_in_wide(4+10-1 downto 4) when '0',	--modulation_output(9 downto 0) when '0',
						
						(others => '0') when '1';
	
	-- Input the data, low-pass filtered back to itself
	--data_in <= data_in_wide(9+10-1 downto 9);
	
	
	
	
   boxcar_filter_I_inst: entity work.adjustable_boxcar_filter
	Generic map (
		MAXIMUM_SIZE => 24,
		DATA_WIDTH => 16
	)
	PORT MAP (
          rst => rst,
          clk => clk,
          input_clk_enable => '1',
          input_data => modulation_output,
			 --input_data => step_vector,
          filter_size => std_logic_vector(to_unsigned(10, 12)),
			 
          output_clk_enable => open,
          output_data => data_in_wide
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
			first_modulation_frequency <= b"000000101000111101011100001010001111010111000010";	-- 1/100
			modulation_frequency_step <= b"000001010001111010111000010100011110101110000101";	-- 1/50
			
      wait for clk_period*100;
			trigger_identification <= '1';
		wait for clk_period*2;	
			trigger_identification <= '0';
			step_vector <= std_logic_vector(to_unsigned(2**15-1, step_vector'length));
		wait for clk_period*100;

      -- insert stimulus here 

      wait;
   end process;

END;
