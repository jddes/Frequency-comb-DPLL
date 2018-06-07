--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   21:35:49 02/19/2014
-- Design Name:   
-- Module Name:   D:/Projets_Xilinx/Status_LED_driver/Status_LED_driver_testbench.vhd
-- Project Name:  Status_LED_driver
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: Status_LED_driver
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
 
ENTITY Status_LED_driver_testbench IS
END Status_LED_driver_testbench;
 
ARCHITECTURE behavior OF Status_LED_driver_testbench IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    

   --Inputs
   signal clk : std_logic := '0';
   signal lock_on : std_logic := '0';
   signal residuals_above_threshold : std_logic := '0';
   signal railed : std_logic := '0';

 	--Outputs
   signal red_LED : std_logic;
   signal green_LED : std_logic;

   -- Clock period definitions
   constant clk_period : time := 10 ns;
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: entity work.Status_LED_driver
	GENERIC MAP (
		N_BITS_COUNTER => 8
	) PORT MAP (
          clk => clk,
          lock_on => lock_on,
          residuals_above_threshold => residuals_above_threshold,
          railed => railed,
          red_LED => red_LED,
          green_LED => green_LED
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
      wait for 100 ns;	
			lock_on <= '1';
      wait for clk_period*10;
			lock_on <= '0';
      wait for clk_period*10;
			lock_on <= '1';
      wait for clk_period*10;
			railed <= '1';
      wait for clk_period*10;
			railed <= '0';
		wait for clk_period*1000;
			residuals_above_threshold <= '1';
		wait for clk_period*5;
			residuals_above_threshold <= '0';
		wait for clk_period*1000;
			lock_on <= '0';
		wait for clk_period*3;
		wait for clk_period*1000;
			railed <= '1';
		wait for clk_period*1000;
      -- insert stimulus here 

      wait;
   end process;

END;
