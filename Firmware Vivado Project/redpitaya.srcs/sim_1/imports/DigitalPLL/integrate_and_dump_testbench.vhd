--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   10:35:13 10/23/2013
-- Design Name:   
-- Module Name:   C:/Xilinx_Projects/PLL_2013_test1_ML605/integrate_and_dump_testbench.vhd
-- Project Name:  PLL_2013_test1_ML605
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: integrate_and_dump
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
 
ENTITY integrate_and_dump_testbench IS
END integrate_and_dump_testbench;
 
ARCHITECTURE behavior OF integrate_and_dump_testbench IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT integrate_and_dump
    PORT(
         rst : IN  std_logic;
         clk : IN  std_logic;
         data_in : IN  std_logic_vector(7 downto 0);
         data_output : OUT  std_logic_vector(11 downto 0);
         output_clk_enable : OUT  std_logic
        );
    END COMPONENT;
    

   --Inputs
   signal rst : std_logic := '0';
   signal clk : std_logic := '0';
   signal data_in : std_logic_vector(7 downto 0) := (others => '0');

 	--Outputs
   signal data_output : std_logic_vector(11 downto 0);
   signal output_clk_enable : std_logic;

   -- Clock period definitions
   constant clk_period : time := 10 ns;
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: integrate_and_dump PORT MAP (
          rst => rst,
          clk => clk,
          data_in => data_in,
          data_output => data_output,
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
      wait for clk_period*100;
			data_in <= std_logic_vector(to_signed(0 , 8));
      wait for clk_period*100;
			data_in <= std_logic_vector(to_signed(1 , 8));
      wait for clk_period*100;
			data_in <= std_logic_vector(to_signed(0 , 8));
      wait for clk_period*100;
			data_in <= std_logic_vector(to_signed(2**7-1 , 8));
      wait for clk_period*100;
			data_in <= std_logic_vector(to_signed(-2**7 , 8));
      wait for clk_period*100;
			data_in <= std_logic_vector(to_signed(0 , 8));

      -- insert stimulus here 

      wait;
   end process;

END;
