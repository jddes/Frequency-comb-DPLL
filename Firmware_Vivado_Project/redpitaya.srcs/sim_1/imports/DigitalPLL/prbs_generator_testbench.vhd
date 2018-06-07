--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   13:50:53 05/05/2014
-- Design Name:   
-- Module Name:   C:/_JD/FPGA_code/ML605/data_packet_generator_1/prbs_generator_testbench.vhd
-- Project Name:  data_packet_generator_1
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: prbs_generator
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
 
ENTITY prbs_generator_testbench IS
END prbs_generator_testbench;
 
ARCHITECTURE behavior OF prbs_generator_testbench IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT prbs_generator
    PORT(
         clk : IN  std_logic;
         trigger : IN  std_logic;
         chip_duration : IN  std_logic_vector(15 downto 0);
         number_of_chips : IN  std_logic_vector(15 downto 0);
         bSequencePolarityInvert : IN  std_logic;
         prbs_out : OUT  std_logic
        );
    END COMPONENT;
    

   --Inputs
   signal clk : std_logic := '0';
   signal trigger : std_logic := '0';
   signal chip_duration : std_logic_vector(15 downto 0) := std_logic_vector(to_unsigned(10, 16));
   signal number_of_chips : std_logic_vector(15 downto 0) := std_logic_vector(to_unsigned(33, 16));
   signal bSequencePolarityInvert : std_logic := '0';

 	--Outputs
   signal prbs_out : std_logic;

   -- Clock period definitions
   constant clk_period : time := 10 ns;
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: prbs_generator PORT MAP (
          clk => clk,
          trigger => trigger,
          chip_duration => chip_duration,
          number_of_chips => number_of_chips,
          bSequencePolarityInvert => bSequencePolarityInvert,
          prbs_out => prbs_out
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

      wait for clk_period*100;
		wait until rising_edge(clk);
			trigger <= '1';
		wait for clk_period*10;
		wait until rising_edge(clk);
			trigger <= '0';
			
      wait for clk_period*10*100;
		wait until rising_edge(clk);
			trigger <= '1';
		wait for clk_period*10;
		wait until rising_edge(clk);
			trigger <= '0';
			
      wait for clk_period*10*100;
		wait until rising_edge(clk);
			number_of_chips <= std_logic_vector(to_unsigned(300, 16));
			trigger <= '1';
		wait for clk_period*10;
		wait until rising_edge(clk);
			trigger <= '0';
			
      wait for clk_period*10*350;
		wait until rising_edge(clk);
			number_of_chips <= std_logic_vector(to_unsigned(127, 16));
			trigger <= '1';
		wait for clk_period*10;
		wait until rising_edge(clk);
			trigger <= '0';
		
      -- insert stimulus here 

      wait;
   end process;

END;
