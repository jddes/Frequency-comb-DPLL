--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   10:29:54 12/12/2013
-- Design Name:   
-- Module Name:   C:/_JD/FPGA code/Daves FPGA box/SimplePI/resize_with_saturation_testbench.vhd
-- Project Name:  SuperLaserLand
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: resize_with_saturation
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
 
ENTITY resize_with_saturation_testbench IS
END resize_with_saturation_testbench;
 
ARCHITECTURE behavior OF resize_with_saturation_testbench IS 
 
   
   --Inputs
   signal clk : std_logic := '0';
   signal data_in : std_logic_vector(10-1 downto 0) := (others => '0');

 	--Outputs
   signal railed_positive : std_logic;
   signal railed_negative : std_logic;
   signal data_out : std_logic_vector(8-1 downto 0);

   -- Clock period definitions
   constant clk_period : time := 10 ns;
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: entity work.resize_with_saturation
	GENERIC MAP (
		N_INPUT => 10,
		N_OUTPUT => 8
	
	)
	PORT MAP (
          clk => clk,
          data_in => data_in,
          railed_positive => railed_positive,
          railed_negative => railed_negative,
          data_out => data_out
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
			data_in <= std_logic_vector(signed(data_in) + 1);
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
