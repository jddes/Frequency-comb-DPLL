--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   16:04:22 03/29/2014
-- Design Name:   
-- Module Name:   D:/Projets_Xilinx/first_order_filter/first_order_IIR_lowpass_filter_testbench.vhd
-- Project Name:  first_order_filter
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: first_order_IIR_lowpass_filter
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
 
ENTITY first_order_IIR_lowpass_filter_testbench IS
END first_order_IIR_lowpass_filter_testbench;
 
ARCHITECTURE behavior OF first_order_IIR_lowpass_filter_testbench IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT first_order_IIR_lowpass_filter
    PORT(
         clk : IN  std_logic;
         data_in : IN  std_logic_vector(15 downto 0);
         data_out : OUT  std_logic_vector(15 downto 0)
        );
    END COMPONENT;
    

   --Inputs
   signal clk : std_logic := '0';
   signal data_in : std_logic_vector(15 downto 0) := (others => '0');

 	--Outputs
   signal data_out : std_logic_vector(15 downto 0);

   -- Clock period definitions
   constant clk_period : time := 10 ns;
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   first_order_IIR_highpass_filter_inst: entity work.first_order_IIR_highpass_filter PORT MAP (
          clk => clk,
          data_in => data_in,
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
 

   -- Stimulus process
   stim_proc: process
   begin		
      -- hold reset state for 100 ns.
      wait for 100 ns;	

      wait for clk_period*10;
		wait for clk_period*100;
		wait until rising_edge(clk);
		data_in <= std_logic_vector(to_signed(1e3, data_in'length));

      -- insert stimulus here 

      wait;
   end process;

END;
