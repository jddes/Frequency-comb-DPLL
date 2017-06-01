--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   17:31:25 02/09/2014
-- Design Name:   
-- Module Name:   C:/_JD/FPGA_code/Daves_FPGA_box/SimplePI/quadrature_dither_generator_testbench.vhd
-- Project Name:  SuperLaserLand
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: quadrature_dither_generator
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
 
ENTITY quadrature_dither_generator_testbench IS
END quadrature_dither_generator_testbench;
 
ARCHITECTURE behavior OF quadrature_dither_generator_testbench IS 
 
    -- Component Declaration for the Unit Under Test (UUT)

    

   --Inputs
   signal clk : std_logic := '0';
   signal modulation_period_divided_by_4_minus_one : std_logic_vector(27-1 downto 0) := std_logic_vector(to_unsigned(99, 27));
   signal modulation_amplitude : std_logic_vector(15 downto 0) := std_logic_vector(to_unsigned(1001, 16));
   signal bOutputEnable : std_logic := '1';

 	--Outputs
   signal output_to_dac : std_logic_vector(15 downto 0);
   signal sync_I : std_logic;
   signal sync_Q : std_logic;

   -- Clock period definitions
   constant clk_period : time := 10 ns;
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   quadrature_dither_generator_inst: entity work.quadrature_dither_generator PORT MAP (
          clk => clk,
          modulation_period_divided_by_4_minus_one => modulation_period_divided_by_4_minus_one,
          modulation_amplitude => modulation_amplitude,
          bOutputEnable => bOutputEnable,
          output_to_dac => output_to_dac,
          sync_I => sync_I,
          sync_Q => sync_Q
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
		wait for clk_period*1000;
			bOutputEnable <= '0';
		wait for clk_period*100;
			bOutputEnable <= '1';
      -- insert stimulus here 

      wait;
   end process;

END;
