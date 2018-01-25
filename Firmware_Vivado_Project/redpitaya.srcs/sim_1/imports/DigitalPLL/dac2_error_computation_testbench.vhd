--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   12:56:11 02/09/2014
-- Design Name:   
-- Module Name:   C:/_JD/FPGA_code/Daves_FPGA_box/SimplePI/dac2_error_computation_testbench.vhd
-- Project Name:  SuperLaserLand
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: dac2_error_computation
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
 
ENTITY dac2_error_computation_testbench IS
END dac2_error_computation_testbench;
 
ARCHITECTURE behavior OF dac2_error_computation_testbench IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT dac2_error_computation
    PORT(
         clk : IN  std_logic;
         dac1_minimum : IN  std_logic_vector(15 downto 0);
         dac1_maximum : IN  std_logic_vector(15 downto 0);
         dac1_current : IN  std_logic_vector(15 downto 0);
         flip_error_sign : IN  std_logic;
         dac1_error : OUT  std_logic_vector(16 downto 0)
        );
    END COMPONENT;
    

   --Inputs
   signal clk : std_logic := '0';
   signal dac1_minimum : std_logic_vector(15 downto 0) := std_logic_vector(to_signed(2**15-3, 16));
   signal dac1_maximum : std_logic_vector(15 downto 0) := std_logic_vector(to_signed(2**15-1, 16));
   signal dac1_current : std_logic_vector(15 downto 0) := std_logic_vector(to_signed(-2**15, 16));
   signal flip_error_sign : std_logic := '0';

 	--Outputs
   signal dac1_error : std_logic_vector(16 downto 0);

   -- Clock period definitions
   constant clk_period : time := 10 ns;
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: dac2_error_computation PORT MAP (
          clk => clk,
          dac1_minimum => dac1_minimum,
          dac1_maximum => dac1_maximum,
          dac1_current => dac1_current,
          flip_error_sign => flip_error_sign,
          dac1_error => dac1_error
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

      wait for clk_period*10;	-- worst case
			dac1_minimum <= std_logic_vector(to_signed(2**15-3, 16));
			dac1_maximum <= std_logic_vector(to_signed(2**15-1, 16));
			dac1_current <= std_logic_vector(to_signed(-2**15, 16));
			flip_error_sign <= '0';
			
      wait for clk_period*10;	-- worst case
			dac1_minimum <= std_logic_vector(to_signed(2**15-3, 16));
			dac1_maximum <= std_logic_vector(to_signed(2**15-1, 16));
			dac1_current <= std_logic_vector(to_signed(-2**15, 16));
			flip_error_sign <= '0';
			
		wait for clk_period*10; -- more typical case
			dac1_minimum <= std_logic_vector(to_signed(0, 16));
			dac1_maximum <= std_logic_vector(to_signed(2**15-1, 16));
			dac1_current <= std_logic_vector(to_signed(0, 16));
			flip_error_sign <= '0';
			
		wait for clk_period*10; -- more typical case
			dac1_minimum <= std_logic_vector(to_signed(0, 16));
			dac1_maximum <= std_logic_vector(to_signed(2**15-1, 16));
			dac1_current <= std_logic_vector(to_signed(0, 16));
			flip_error_sign <= '1';
			
		wait for clk_period*10; -- more typical case
			dac1_minimum <= std_logic_vector(to_signed(0, 16));
			dac1_maximum <= std_logic_vector(to_signed(2**15-1, 16));
			dac1_current <= std_logic_vector(to_signed(2**15-1, 16));
			flip_error_sign <= '1';
			
      -- insert stimulus here 

      wait;
   end process;

END;
