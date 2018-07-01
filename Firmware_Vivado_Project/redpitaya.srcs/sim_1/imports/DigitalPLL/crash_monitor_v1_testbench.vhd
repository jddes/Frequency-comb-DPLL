--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   20:58:49 02/15/2014
-- Design Name:   
-- Module Name:   D:/Projets_Xilinx/crash_monitor_v1/crash_monitor_v1_testbench.vhd
-- Project Name:  crash_monitor_v1
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: crash_monitor_v1
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
 
ENTITY crash_monitor_v1_testbench IS
END crash_monitor_v1_testbench;
 
ARCHITECTURE behavior OF crash_monitor_v1_testbench IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
    

   --Inputs
   signal clk : std_logic := '0';
   signal input1 : std_logic_vector(15 downto 0) := (others => '0');
   signal trigger_input, ready_for_dump : std_logic := '0';
   signal pretrigger_samples : std_logic_vector(8-1 downto 0) := std_logic_vector(to_unsigned(10, 8));

 	--Outputs
   signal output_to_logger : std_logic_vector(15 downto 0);
   signal output_to_logger_clk_enable : std_logic;

   -- Clock period definitions
   constant clk_period : time := 10 ns;
	
	signal rst : std_logic := '0';
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: entity work.crash_monitor_v1
	GENERIC MAP (
		N_BITS_DATA => 16,
		ADDRESS_BITS => 8
	
	)
	PORT MAP (
          clk => clk,
          input1 => input1,
          trigger_input => trigger_input,
			 ready_for_dump => ready_for_dump,
          pretrigger_samples => pretrigger_samples,
          output_to_logger => output_to_logger,
          output_to_logger_clk_enable => output_to_logger_clk_enable
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
			if rst = '1' then
				input1 <= (others => '0');
			else
				input1 <= std_logic_vector(unsigned(input1) + 1);
				if unsigned(input1) = 100 then
					trigger_input <= '1';
				else
					trigger_input <= '0';
				end if;
			end if;

		end if;
	end process;

   -- Stimulus process
   stim_proc: process
   begin		
      -- hold reset state for 100 ns.
			rst <= '1';
      wait for 100 ns;	

      wait for clk_period*100;
		wait until rising_edge(clk);
			rst <= '0';
		wait for clk_period*1000;
		wait until rising_edge(clk);
			ready_for_dump <= '1';
		wait until rising_edge(clk);
			ready_for_dump <= '0';
      -- insert stimulus here 

      wait;
   end process;

END;
