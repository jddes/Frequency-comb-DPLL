--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   22:18:35 11/22/2013
-- Design Name:   
-- Module Name:   C:/_JD/FPGA code/Daves FPGA box/SimplePI/output_summing_testbench.vhd
-- Project Name:  SuperLaserLand
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: output_summing
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
 
ENTITY output_summing_testbench IS
END output_summing_testbench;
 
ARCHITECTURE behavior OF output_summing_testbench IS 


   --Inputs
   signal clk : std_logic := '0';
   signal in0 : std_logic_vector(8-1 downto 0) := (others => '0');
   signal in1 : std_logic_vector(8-1 downto 0) := (others => '0');
   signal in2 : std_logic_vector(8-1 downto 0) := (others => '0');
   signal in3 : std_logic_vector(8-1 downto 0) := (others => '0');

 	--Outputs
   signal output : std_logic_vector(5-1 downto 0);
   signal railed_positive : std_logic;
   signal railed_negative : std_logic;

   -- Clock period definitions
   constant clk_period : time := 10 ns;
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: entity work.output_summing
	Generic map (
		INPUT_SIZE => 8,
		OUTPUT_SIZE => 5
	)
	PORT MAP (
          clk => clk,
          in0 => in0,
          in1 => in1,
          in2 => in2,
          in3 => in3,
          output => output,
          railed_positive => railed_positive,
          railed_negative => railed_negative
        );
		  
	process (clk)
	begin
		if rising_edge(clk) then
			in3 <= std_logic_vector((signed(in3) + 1));
		end if;
	end process;

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
