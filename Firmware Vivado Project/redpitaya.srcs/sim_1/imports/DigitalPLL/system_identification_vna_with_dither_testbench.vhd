--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   15:42:48 11/06/2013
-- Design Name:   
-- Module Name:   C:/_JD/Leibrants FPGA locks/DigitalServo/Firmware/SimplePI/system_identification_vna_with_dither_testbench.vhd
-- Project Name:  SuperLaserLand
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: system_identification_vna_wrapper
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
 
ENTITY system_identification_vna_with_dither_testbench IS
END system_identification_vna_with_dither_testbench;
 
ARCHITECTURE behavior OF system_identification_vna_with_dither_testbench IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
--    COMPONENT system_identification_vna_wrapper
--    PORT(
--         rst : IN  std_logic;
--         clk : IN  std_logic;
--         cmd_addr : IN  std_logic_vector(15 downto 0);
--         cmd_data1 : IN  std_logic_vector(15 downto 0);
--         cmd_data2 : IN  std_logic_vector(15 downto 0);
--         cmd_trig : IN  std_logic;
--         led_debug : OUT  std_logic_vector(5 downto 0);
--         trigger_identification : IN  std_logic;
--         data_in1 : IN  std_logic_vector(15 downto 0);
--         data_in2 : IN  std_logic_vector(15 downto 0);
--         modulation_output_to_dac1 : OUT  std_logic_vector(15 downto 0);
--         modulation_output_to_dac2 : OUT  std_logic_vector(15 downto 0);
--         output_to_logger : OUT  std_logic_vector(15 downto 0);
--         output_to_logger_clk_enable : OUT  std_logic
--        );
--    END COMPONENT;
    

	--Inputs
	signal rst                               : std_logic := '0';
	signal clk                               : std_logic := '0';
	signal cmd_addr                          : std_logic_vector(15 downto 0) := (others => '0');
	signal cmd_data1                         : std_logic_vector(15 downto 0) := (others => '0');
	signal cmd_data2                         : std_logic_vector(15 downto 0) := (others => '0');
	signal cmd_trig                          : std_logic := '0';
	signal trigger_identification            : std_logic := '0';
	signal data_in1                          : std_logic_vector(15 downto 0) := (others => '0');
	signal data_in2                          : std_logic_vector(15 downto 0) := (others => '0');
	
	signal trigger_dither, stop, bSquareWave : std_logic := '0';
	
	--Outputs
	signal led_debug                         : std_logic_vector(5 downto 0);
	signal modulation_output_to_dac0         : std_logic_vector(15 downto 0);
	signal modulation_output_to_dac1         : std_logic_vector(15 downto 0);
	signal modulation_output_to_dac2         : std_logic_vector(15 downto 0);
	signal output_to_logger                  : std_logic_vector(15 downto 0);
	signal output_to_logger_clk_enable       : std_logic;
	
	signal dither_sync_I, dither_sync_Q      : std_logic;

	-- Clock period definitions
	constant clk_period : time := 10 ns;

	signal samples_counter : unsigned(31 downto 0) := (others => '0');
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: entity work.system_identification_vna_with_dither_wrapper PORT MAP (
		rst => rst,
		clk => clk,
		cmd_addr => cmd_addr,
		cmd_data1 => cmd_data1,
		cmd_data2 => cmd_data2,
		cmd_trig => cmd_trig,
		led_debug => led_debug,

		trigger_identification => trigger_identification,

		data_in1 => data_in1,
		data_in2 => data_in2,
		data_in3 => (others => '0'),
		data_in4 => (others => '0'),
		modulation_output_to_dac0 => modulation_output_to_dac0,
		modulation_output_to_dac1 => modulation_output_to_dac1,
		modulation_output_to_dac2 => modulation_output_to_dac2,
		output_to_logger => output_to_logger,
		output_to_logger_clk_enable => output_to_logger_clk_enable,

		dither_sync_I => dither_sync_I,
		dither_sync_Q => dither_sync_Q
        );
	cmd_data1(2 downto 0) <= (bSquareWave, trigger_dither, stop);
	cmd_addr <= x"5008"; 
		  
--	data_in1 <= modulation_output_to_dac0;
	data_in1 <= std_logic_vector(to_signed(10e3, data_in1'length));
	data_in2 <= modulation_output_to_dac2;

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
				samples_counter <= (others => '0');
			else
				if output_to_logger_clk_enable = '1' then
					samples_counter <= samples_counter + 1;
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
			rst <= '0';
      wait for clk_period*10;
		wait for clk_period*100;
		wait until rising_edge(clk);
			trigger_identification <= '1';
		wait for clk_period*2;
		wait until rising_edge(clk);
			trigger_identification <= '0';
		wait for clk_period*30000;
			
      -- Stop identification midway
		wait for clk_period*100;
		wait until rising_edge(clk);
			trigger_identification <= '1';
		wait for clk_period*2;
		wait until rising_edge(clk);
			trigger_identification <= '0';
		wait for clk_period*100;
		wait until rising_edge(clk);
			cmd_trig <= '1';
			stop <= '1';
		wait until rising_edge(clk);
			stop <= '0';
			cmd_trig <= '0';
			
		wait for clk_period*3000;
			
			
      -- Set to dither mode for 6000 clock cycles
		wait for clk_period*100;
		wait until rising_edge(clk);
			trigger_dither <= '1';
			cmd_trig <= '1';
		wait until rising_edge(clk);
			cmd_trig <= '0';
		wait for clk_period*2;
		wait until rising_edge(clk);
			trigger_dither <= '0';
			cmd_trig <= '1';
		wait until rising_edge(clk);
			cmd_trig <= '0';
		wait for clk_period*6000;
		wait until rising_edge(clk);
			stop <= '1';
			cmd_trig <= '1';
		wait until rising_edge(clk);
			cmd_trig <= '0';
		wait until rising_edge(clk);
			stop <= '0';
			cmd_trig <= '1';
		wait until rising_edge(clk);
			cmd_trig <= '0';
		
		wait for clk_period*3000;
			
      -- Set to dither mode, square wave for 100 clock cycles
		wait for clk_period*100;
		wait until rising_edge(clk);
			trigger_dither <= '1';
			bSquareWave <= '1';
			cmd_trig <= '1';
		wait until rising_edge(clk);
			cmd_trig <= '0';
		wait for clk_period*2;
		wait until rising_edge(clk);
			trigger_dither <= '0';
			cmd_trig <= '1';
		wait until rising_edge(clk);
			cmd_trig <= '0';
		wait for clk_period*100;
		wait until rising_edge(clk);
			stop <= '1';
			bSquareWave <= '0';
			cmd_trig <= '1';
		wait until rising_edge(clk);
			cmd_trig <= '0';
		wait until rising_edge(clk);
			stop <= '0';
			cmd_trig <= '1';
		wait until rising_edge(clk);
			cmd_trig <= '0';
			
		wait for clk_period*3000;

      wait;
   end process;

END;
