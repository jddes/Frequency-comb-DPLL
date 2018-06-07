--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   15:02:23 02/24/2014
-- Design Name:   
-- Module Name:   C:/_JD/FPGA_code/Daves_FPGA_box/SimplePI/boxcar_4_pts_filter_testbench.vhd
-- Project Name:  SuperLaserLand
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: boxcar_4_pts_filter
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
 
ENTITY boxcar_4_pts_filter_testbench IS
END boxcar_4_pts_filter_testbench;
 
ARCHITECTURE behavior OF boxcar_4_pts_filter_testbench IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT boxcar_4_pts_filter
    PORT(
         clk : IN  std_logic;
         data_input : IN  std_logic_vector(15 downto 0);
         data_output : OUT  std_logic_vector(17 downto 0);
         railed_positive : OUT  std_logic;
         railed_negative : OUT  std_logic
        );
    END COMPONENT;
    

   --Inputs
   signal clk : std_logic := '0';
   signal data_input : std_logic_vector(15 downto 0) := (others => '0');

 	--Outputs
   signal data_output : std_logic_vector(17 downto 0);
   signal railed_positive : std_logic;
   signal railed_negative : std_logic;

   -- Clock period definitions
   constant clk_period : time := 10 ns;
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: boxcar_4_pts_filter PORT MAP (
          clk => clk,
          data_input => data_input,
          data_output => data_output,
          railed_positive => railed_positive,
          railed_negative => railed_negative
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

      wait for clk_period*10;

      -- insert stimulus here 

      wait;
   end process;

END;
