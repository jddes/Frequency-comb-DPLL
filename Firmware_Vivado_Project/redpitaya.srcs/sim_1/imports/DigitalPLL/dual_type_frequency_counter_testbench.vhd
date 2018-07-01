--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   20:35:57 02/25/2014
-- Design Name:   
-- Module Name:   D:/Projets_Xilinx/triangular_frequency_counter/dual_type_frequency_counter_testbench.vhd
-- Project Name:  triangular_frequency_counter
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: dual_type_frequency_counter
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
 
ENTITY dual_type_frequency_counter_testbench IS
END dual_type_frequency_counter_testbench;
 
ARCHITECTURE behavior OF dual_type_frequency_counter_testbench IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    --COMPONENT dual_type_frequency_counter
    --PORT(
    --     clk : IN  std_logic;
    --     data_input : IN  std_logic_vector(9 downto 0);
    --     N_gate_time : IN  std_logic_vector(31 downto 0);
    --     N_times_faster_gate_time : IN  std_logic_vector(31 downto 0);
    --     triangular_mode : IN  std_logic;
    --     output_clk_enable_N_times_faster : OUT  std_logic;
    --     data_output : OUT  std_logic_vector(63 downto 0);
    --     output_clk_enable : OUT  std_logic
    --    );
    --END COMPONENT;
    

   --Inputs
   signal rst : std_logic := '0';
   signal clk : std_logic := '0';
   signal data_input : std_logic_vector(9 downto 0) := std_logic_vector(to_signed(0, 10));
   signal N_gate_time : std_logic_vector(31 downto 0) := std_logic_vector(to_signed(100, 32));
   signal N_times_faster_gate_time : std_logic_vector(31 downto 0) := std_logic_vector(to_signed(10, 32));
   signal triangular_mode : std_logic := '1';

 	--Outputs
   signal output_clk_enable_N_times_faster : std_logic;
   signal data_output : std_logic_vector(63 downto 0);
   signal output_clk_enable : std_logic;

   -- Clock period definitions
   constant clk_period : time := 10 ns;
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   dual_type_frequency_counter_inst: entity work.dual_type_frequency_counter PORT MAP (
        rst                              => rst,
        clk                              => clk,
        data_input                       => data_input,
        N_gate_time                      => N_gate_time,
        N_times_faster_gate_time         => N_times_faster_gate_time,
        triangular_mode                  => triangular_mode,
        output_clk_enable_N_times_faster => output_clk_enable_N_times_faster,
        data_output                      => data_output,
        output_clk_enable                => output_clk_enable
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

      wait for clk_period*10;

        -- Extract counter's step response and delay:
        wait for clk_period*100*10;
            wait until rising_edge(clk);
                data_input <= std_logic_vector(to_signed(1, 10));
        wait for clk_period*100*10;
            wait until rising_edge(clk);
                data_input <= std_logic_vector(to_signed(0, 10));
        wait for clk_period*100*10;

        -- Extract counter's weighing function using a sliding impulse wrt to the counter's averaging phase:
        for I in 0 to 1000-1 loop
            wait until rising_edge(clk);
                data_input <= std_logic_vector(to_signed(1, 10));
            wait until rising_edge(clk);
                data_input <= std_logic_vector(to_signed(0, 10));
            wait for clk_period*200;
        end loop;


        -- Test rectangular mode
			triangular_mode <= '0';
		wait until rising_edge(clk);
        -- Extract counter's weighing function using a sliding impulse wrt to the counter's averaging phase:
		while TRUE loop
            wait until rising_edge(clk);
                data_input <= std_logic_vector(to_signed(1, 10));
            wait until rising_edge(clk);
                data_input <= std_logic_vector(to_signed(0, 10));
            wait for clk_period*100;
		end loop;

      wait;
   end process;

   -- Stimulus process for reset signal (used to synchronize the counter's gate to a software event)
    stim_proc_rst: process
        begin        
        -- assert reset
        wait for 574.815 us-clk_period*1000;  
        wait until rising_edge(clk);
            rst <= '1';
        wait for clk_period*1000;
        wait until rising_edge(clk);
            rst <= '0';

        wait;
    end process;
END;
