--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   12:11:23 02/19/2014
-- Design Name:   
-- Module Name:   C:/_JD/FPGA_code/Daves_FPGA_box/SimplePI/residuals_monitor_testbench.vhd
-- Project Name:  SuperLaserLand
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: residuals_monitor
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
 
ENTITY residuals_monitor_testbench IS
END residuals_monitor_testbench;
 
ARCHITECTURE behavior OF residuals_monitor_testbench IS 
 
    -- Component Declaration for the Unit Under Test (UUT)

    

   --Inputs
   signal clk : std_logic := '0';
   signal phase_residuals : std_logic_vector(8-1 downto 0) := (others => '0');
   signal residuals_threshold : std_logic_vector(8-1 downto 0) := std_logic_vector(to_unsigned(100, 8));

 	--Outputs
   signal residuals_are_above_threshold : std_logic;

   -- Clock period definitions
   constant clk_period : time := 10 ns;
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: entity work.residuals_monitor
	GENERIC MAP (
		N_BITS_DATA => 8
	)
	PORT MAP (
          clk => clk,
          phase_residuals => phase_residuals,
          residuals_threshold => residuals_threshold,
          residuals_are_above_threshold => residuals_are_above_threshold
        );

   -- Clock process definitions
   clk_process :process
   begin
		clk <= '0';
		wait for clk_period/2;
		clk <= '1';
		wait for clk_period/2;
   end process;
 
 	process (clk)
	begin
		if rising_edge(clk) then
			phase_residuals <= std_logic_vector(signed(phase_residuals) + 1);
		end if;
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
