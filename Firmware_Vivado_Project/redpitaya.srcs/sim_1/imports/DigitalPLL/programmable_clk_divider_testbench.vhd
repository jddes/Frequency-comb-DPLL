--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   17:16:49 02/25/2014
-- Design Name:   
-- Module Name:   C:/_JD/FPGA_code/Daves_FPGA_box/SimplePI/programmable_clk_divider_testbench.vhd
-- Project Name:  SuperLaserLand
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: programmable_clk_divider
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
 
ENTITY programmable_clk_divider_testbench IS
END programmable_clk_divider_testbench;
 
ARCHITECTURE behavior OF programmable_clk_divider_testbench IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT programmable_clk_divider
    PORT(
         clk : IN  std_logic;
         clk_divider_mode : IN  std_logic_vector(1 downto 0);
         clk_divider_modulus : IN  std_logic_vector(29 downto 0);
			phase_increment : IN  std_logic_vector(29 downto 0);
         data_output : OUT  std_logic
        );
    END COMPONENT;
    

   --Inputs
   signal clk : std_logic := '0';
   signal clk_divider_mode : std_logic_vector(1 downto 0) := b"01";
   signal clk_divider_modulus : std_logic_vector(29 downto 0) := std_logic_vector(to_unsigned(100, 30));
	signal phase_increment : std_logic_vector(29 downto 0) := std_logic_vector(to_unsigned(0, 30));
	signal phase_increment2 : std_logic_vector(29 downto 0) := std_logic_vector(to_unsigned(0, 30));
	
 	--Outputs
   signal data_output, data_output2 : std_logic;

   -- Clock period definitions
   constant clk_period : time := 5 ns;
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: programmable_clk_divider PORT MAP (
          clk => clk,
          clk_divider_mode => clk_divider_mode,
          clk_divider_modulus => clk_divider_modulus,
			 phase_increment => phase_increment,
          data_output => data_output
        );
   uut2: programmable_clk_divider PORT MAP (
          clk => clk,
          clk_divider_mode => clk_divider_mode,
          clk_divider_modulus => clk_divider_modulus,
			 phase_increment => phase_increment2,
          data_output => data_output2
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

      wait for clk_period*1e3;
		wait until rising_edge(clk);
			phase_increment <= std_logic_vector(to_unsigned(2, 30));
		wait for clk_period*1e3;
		wait until rising_edge(clk);
			phase_increment <= std_logic_vector(to_unsigned(0, 30));
			
      wait for clk_period*1e3;
		wait until rising_edge(clk);
			phase_increment <= std_logic_vector(to_unsigned(20, 30));
		wait for clk_period*1e3;
		wait until rising_edge(clk);
			phase_increment <= std_logic_vector(to_unsigned(0, 30));
		
      -- insert stimulus here 

      wait;
   end process;

END;
