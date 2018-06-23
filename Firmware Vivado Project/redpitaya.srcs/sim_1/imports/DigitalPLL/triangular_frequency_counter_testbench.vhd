--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   20:58:55 02/24/2014
-- Design Name:   
-- Module Name:   D:/Projets_Xilinx/triangular_frequency_counter/triangular_frequency_counter_testbench.vhd
-- Project Name:  triangular_frequency_counter
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: triangular_frequency_counter
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
 
ENTITY triangular_frequency_counter_testbench IS
END triangular_frequency_counter_testbench;
 
ARCHITECTURE behavior OF triangular_frequency_counter_testbench IS 
 
    -- Component Declaration for the Unit Under Test (UUT)


   --Inputs
   signal clk : std_logic := '0';
   signal data_input : std_logic_vector(9 downto 0) := std_logic_vector(to_signed(1, 10));

 	--Outputs
   signal data_output : std_logic_vector(63 downto 0);
   signal output_clk_enable : std_logic;
   signal output_clk_enable_N_times_faster : std_logic;

   -- Clock period definitions
   constant clk_period : time := 10 ns;
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   triangular_frequency_counter_inst: entity work.triangular_frequency_counter
	GENERIC MAP (
		N_GATE_TIME => 8,
		N_TIMES_FASTER_GATE_TIME => 4,
		N_BITS_INPUT => 10
	)
	PORT MAP (
          clk => clk,
          data_input => data_input,
          data_output => data_output,
          output_clk_enable => output_clk_enable,
          output_clk_enable_N_times_faster => output_clk_enable_N_times_faster
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



        wait until rising_edge(clk);

        wait for clk_period*1000;
        wait until rising_edge(clk);
            while TRUE loop
                wait for clk_period*8;
                wait until rising_edge(clk);
                data_input <= std_logic_vector(to_signed(1, 10));
                wait until rising_edge(clk);
                data_input <= std_logic_vector(to_signed(0, 10));
            end loop;

        wait;
    end process;

END;
