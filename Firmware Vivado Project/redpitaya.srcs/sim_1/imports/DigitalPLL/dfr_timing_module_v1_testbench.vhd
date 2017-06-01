--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   09:38:52 04/29/2014
-- Design Name:   
-- Module Name:   C:/_JD/FPGA_code/Daves_FPGA_box/SimplePI/dfr_timing_module_v1_testbench.vhd
-- Project Name:  SuperLaserLand
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: dfr_timing_module_v1
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
 
ENTITY dfr_timing_module_v1_testbench IS
END dfr_timing_module_v1_testbench;
 
ARCHITECTURE behavior OF dfr_timing_module_v1_testbench IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT dfr_timing_module_v1
    PORT(
         clk : IN  std_logic;
         phase_modulus : IN  std_logic_vector(63 downto 0);
         delta_fr : IN  std_logic_vector(64-1 downto 0);
         phase_adjust : IN  std_logic_vector(63 downto 0);
         trigger_output : OUT  std_logic
        );
    END COMPONENT;
    

   --Inputs
   signal clk : std_logic := '0';
   signal phase_modulus : std_logic_vector(63 downto 0) := std_logic_vector(to_signed(1000, 64));
   signal delta_fr : std_logic_vector(64-1 downto 0) := std_logic_vector(to_signed(10, 64));
   signal phase_adjust : std_logic_vector(63 downto 0) := std_logic_vector(to_signed(0, 64));

 	--Outputs
   signal trigger_output : std_logic;

   -- Clock period definitions
   constant clk_period : time := 10 ns;
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: dfr_timing_module_v1 PORT MAP (
          clk => clk,
          phase_modulus => phase_modulus,
          delta_fr => delta_fr,
          phase_adjust => phase_adjust,
          trigger_output => trigger_output
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

      wait for clk_period*1e2;

      -- insert stimulus here 
		wait until rising_edge(clk);
			phase_adjust <= std_logic_vector(to_signed(0, 64));
		wait for clk_period*1e2;
		
      wait;
   end process;

END;
