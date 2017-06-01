--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   12:34:01 11/30/2013
-- Design Name:   
-- Module Name:   C:/_JD/FPGA code/Daves FPGA box/SimplePI/zero_deadtime_counter_testbench.vhd
-- Project Name:  SuperLaserLand
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: zero_deadtime_counter
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
 
ENTITY zero_deadtime_counter_testbench IS
END zero_deadtime_counter_testbench;
 
ARCHITECTURE behavior OF zero_deadtime_counter_testbench IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    

   --Inputs
   signal rst : std_logic := '0';
   signal clk : std_logic := '0';
   signal data_in : std_logic_vector(9 downto 0) := (others => '0');

 	--Outputs
   signal data_out : std_logic_vector(10+5+1+2+3-1 downto 0);
   signal output_clk_enable : std_logic;

   -- Clock period definitions
   constant clk_period : time := 10 ns;
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: entity work.zero_deadtime_counter PORT MAP (
          rst => rst,
          clk => clk,
          data_in => data_in,
          data_out => data_out,
          output_clk_enable => output_clk_enable
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
      wait for clk_period*10;
			data_in <= std_logic_vector(to_signed(5, data_in'length));
      -- insert stimulus here 

      wait;
   end process;

END;
