--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   13:25:21 04/11/2012
-- Design Name:   
-- Module Name:   C:/Xilinx_Projects/test_fmcw_angle_unwrap_2nd_diff/adjustable_boxcar_filter_testbench.vhd
-- Project Name:  test_fmcw_angle_unwrap_2nd_diff
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: adjustable_boxcar_filter
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
--USE ieee.numeric_std.ALL;
 
ENTITY adjustable_boxcar_filter_testbench IS
END adjustable_boxcar_filter_testbench;
 
ARCHITECTURE behavior OF adjustable_boxcar_filter_testbench IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT adjustable_boxcar_filter
    PORT(
         rst : IN  std_logic;
         clk : IN  std_logic;
         input_clk_enable : IN  std_logic;
         input_data : IN  std_logic_vector(15 downto 0);
         filter_size : IN  std_logic_vector(11 downto 0);
         output_clk_enable : OUT  std_logic;
         output_data : OUT  std_logic_vector(27 downto 0)
        );
    END COMPONENT;
    

   --Inputs
   signal rst : std_logic := '0';
   signal clk : std_logic := '0';
   signal input_clk_enable : std_logic := '0';
   signal input_data : std_logic_vector(15 downto 0) := (others => '0');
   signal filter_size : std_logic_vector(11 downto 0) := (others => '0');

 	--Outputs
   signal output_clk_enable : std_logic;
   signal output_data : std_logic_vector(27 downto 0);
	signal output_data_v2 : std_logic_vector(16-1+8 downto 0);
	

   -- Clock period definitions
   constant clk_period : time := 10 ns;
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: adjustable_boxcar_filter PORT MAP (
          rst => rst,
          clk => clk,
          input_clk_enable => input_clk_enable,
          input_data => input_data,
          filter_size => filter_size,
          output_clk_enable => output_clk_enable,
          output_data => output_data
        );
		  
   uut2: entity work.adjustable_boxcar_filter_v2
	port map (
          rst => rst,
          clk => clk,
          input_data => input_data,
          filter_size => filter_size(7 downto 0),
          output_data => output_data_v2
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
			input_data <= b"0000000000000001";			-- 2^14
			filter_size <= "000000000111";	-- 7, so that filter length = 8
			input_clk_enable <= '1';
      wait for 100 ns;	
			rst <= '0';
      wait for clk_period*50;
			input_data <= b"0000000000000010";			-- 2^13
      wait for clk_period*50;
		
			-- Latency and group delay test, with clk_enable strobe
			input_data <= b"0000000000000001";			-- 2^12
			input_clk_enable <= '0';
		wait for clk_period*10;
			input_clk_enable <= '1';
		wait for clk_period*25;
		
			-- Latency and group delay test, with clk_enable always high
			input_data <= b"0000000000000010";			-- 2^14
		wait for clk_period*25;
			-- Latency and group delay test, with clk_enable always high
			input_data <= b"0000000000000001";			-- 2^12
		wait for clk_period*25;
			-- Latency and group delay test, with clk_enable always high
			input_data <= b"0000000000000010";			-- 2^14
		wait for clk_period*25;
			
      -- Test a filter size change:
		wait for clk_period*50;
			filter_size <= "000000001000";	-- 8, so that filter length = 9
			rst <= '1';
		wait for clk_period;
			rst <= '0';
			
      wait for clk_period*50;
			input_data <= b"0000000000000001";			-- 2^14
			
			-- Latency and group delay test
			input_data <= b"0000000000000010";			-- 2^12
			input_clk_enable <= '0';
		wait for clk_period;
			input_clk_enable <= '1';
		wait for clk_period*25;
			
			-- Latency and group delay test, with clk_enable always high
			input_data <= b"0000000000000001";			-- 2^14
		wait for clk_period*25;
			
      -- Test a filter size change:
		wait for clk_period*50;
			filter_size <= "000000000010";	-- 2, so that filter length = 2
			rst <= '1';
		wait for clk_period;
			rst <= '0';

      wait for clk_period*50;
			input_data <= b"0000000000000010";			-- 2^13
			
			-- Latency and group delay test
			input_data <= b"0000000000000001";			-- 2^12
			input_clk_enable <= '0';
		wait for clk_period;
			input_clk_enable <= '1';
		wait for clk_period*25;
			
			-- Latency and group delay test, with clk_enable always high
			input_data <= b"0000000000000010";			-- 2^14
		wait for clk_period*25;
			
		wait for clk_period*50;
		
		
		
      wait;
   end process;

END;
