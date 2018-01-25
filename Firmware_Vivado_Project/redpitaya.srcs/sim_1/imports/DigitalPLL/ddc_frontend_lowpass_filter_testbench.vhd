--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   15:10:47 02/24/2014
-- Design Name:   
-- Module Name:   C:/_JD/FPGA_code/Daves_FPGA_box/SimplePI/ddc_frontend_lowpass_filter_testbench.vhd
-- Project Name:  SuperLaserLand
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- 
-- VHDL Test Bench Created by ISE for module: ddc_frontend_lowpass_filter
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
 
ENTITY ddc_frontend_lowpass_filter_testbench IS
END ddc_frontend_lowpass_filter_testbench;
 
ARCHITECTURE behavior OF ddc_frontend_lowpass_filter_testbench IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 

    

   --Inputs
   signal clk, rst : std_logic := '1';
   signal clk_times_N : std_logic := '1';
   signal data_input : std_logic_vector(15 downto 0) := (others => '0');
	signal filter_select : std_logic_vector(1 downto 0) := b"00";
   signal data_output : std_logic_vector(15 downto 0) := (others => '0');

   -- Clock period definitions
   constant clk_period : time := 10 ns;
   constant clk_times_N_period : time := 5 ns;
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: entity work.ddc_frontend_lowpass_filter PORT MAP (
			 rst => rst,
          clk => clk,
          clk_times_N => clk_times_N,
          data_input => data_input,
			 filter_select => filter_select,
          data_output => data_output
        );

   -- Clock process definitions
   clk_process :process
   begin
		clk <= '0';
		wait for clk_period/2;
		clk <= '1';
		wait for clk_period/2;
   end process;
   
   clk_times_N_process :process
   begin
        clk_times_N <= '0';
        wait for clk_times_N_period/2;
        clk_times_N <= '1';
        wait for clk_times_N_period/2;
   end process;
 

   -- Stimulus process
   stim_proc: process
   begin		
      -- hold reset state for 100 ns.
			rst <= '1';
      wait for 100 ns;	
			rst <= '0';
      wait for clk_period*10;
		wait until rising_edge(clk);
			data_input <= std_logic_vector(to_signed(1000, data_input'length));
		wait until rising_edge(clk);
			data_input <= std_logic_vector(to_signed(0, data_input'length));		
		wait for clk_period*100;
		wait until rising_edge(clk);
			data_input <= std_logic_vector(to_signed(1e3, data_input'length));
		wait for clk_period*100;
		wait until rising_edge(clk);
			data_input <= std_logic_vector(to_signed(0, data_input'length));	
		wait for clk_period*100;
		wait until rising_edge(clk);
			data_input <= std_logic_vector(to_signed(123456, data_input'length));
        
         wait for clk_period*100;
            filter_select <= "01";
         wait for clk_period*10;
           wait until rising_edge(clk);
               data_input <= std_logic_vector(to_signed(1000, data_input'length));
           wait until rising_edge(clk);
               data_input <= std_logic_vector(to_signed(0, data_input'length));        
           wait for clk_period*100;
           wait until rising_edge(clk);
               data_input <= std_logic_vector(to_signed(1e3, data_input'length));
           wait for clk_period*100;
           wait until rising_edge(clk);
               data_input <= std_logic_vector(to_signed(0, data_input'length));    
           wait for clk_period*100;
           wait until rising_edge(clk);
               data_input <= std_logic_vector(to_signed(123456, data_input'length));
               
               
           wait for clk_period*100;
               filter_select <= "10";
            wait for clk_period*10;
              wait until rising_edge(clk);
                  data_input <= std_logic_vector(to_signed(1000, data_input'length));
              wait until rising_edge(clk);
                  data_input <= std_logic_vector(to_signed(0, data_input'length));        
              wait for clk_period*100;
              wait until rising_edge(clk);
                  data_input <= std_logic_vector(to_signed(1e3, data_input'length));
              wait for clk_period*100;
              wait until rising_edge(clk);
                  data_input <= std_logic_vector(to_signed(0, data_input'length));    
              wait for clk_period*100;
              wait until rising_edge(clk);
                  data_input <= std_logic_vector(to_signed(123456, data_input'length));
      -- insert stimulus here 

      wait;
   end process;

END;
