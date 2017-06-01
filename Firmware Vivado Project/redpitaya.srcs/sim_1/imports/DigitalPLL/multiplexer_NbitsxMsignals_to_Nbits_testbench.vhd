--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   10:23:36 11/07/2013
-- Design Name:   
-- Module Name:   C:/_JD/Leibrants FPGA locks/DigitalServo/Firmware/SimplePI/multiplexer_NbitsxMsignals_to_Nbits_testbench.vhd
-- Project Name:  SuperLaserLand
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: multiplexer_NbitsxMsignals_to_Nbits
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
 
ENTITY multiplexer_NbitsxMsignals_to_Nbits_testbench IS
END multiplexer_NbitsxMsignals_to_Nbits_testbench;
 
ARCHITECTURE behavior OF multiplexer_NbitsxMsignals_to_Nbits_testbench IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    
	constant N_bits_per_signal : integer := 4;
   --Inputs
   signal rst : std_logic := '0';
   signal clk : std_logic := '0';
   signal in0 : std_logic_vector(N_bits_per_signal-1 downto 0) := x"1";
   signal in1 : std_logic_vector(N_bits_per_signal-1 downto 0) := x"2";
   signal in2 : std_logic_vector(N_bits_per_signal-1 downto 0) := x"3";
   signal in3 : std_logic_vector(N_bits_per_signal-1 downto 0) := x"4";
   signal in4 : std_logic_vector(N_bits_per_signal-1 downto 0) := x"5";
   signal in5 : std_logic_vector(N_bits_per_signal-1 downto 0) := x"6";
   signal in6 : std_logic_vector(N_bits_per_signal-1 downto 0) := x"7";
   signal in7 : std_logic_vector(N_bits_per_signal-1 downto 0) := x"8";
   signal selector : std_logic_vector(2 downto 0) := (others => '0');

 	--Outputs
   signal output : std_logic_vector(N_bits_per_signal-1 downto 0);

   -- Clock period definitions
   constant clk_period : time := 10 ns;
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: entity work.multiplexer_NbitsxMsignals_to_Nbits
	GENERIC MAP(
		N_bits_per_signal => N_bits_per_signal
	)
	PORT MAP (
          rst => rst,
          clk => clk,
          in0 => in0,
          in1 => in1,
          in2 => in2,
          in3 => in3,
          in4 => in4,
          in5 => in5,
          in6 => in6,
          in7 => in7,
          selector => selector,
          output => output
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
		--rst <= '1';  -- this module has no internal reset state
      wait for 100 ns;	
		--rst <= '0';
      wait for clk_period*10;
		selector <= std_logic_vector(unsigned(selector)+1);
      wait for clk_period*10;
		selector <= std_logic_vector(unsigned(selector)+1);
      wait for clk_period*10;
		selector <= std_logic_vector(unsigned(selector)+1);
      wait for clk_period*10;
		selector <= std_logic_vector(unsigned(selector)+1);
      wait for clk_period*10;
		selector <= std_logic_vector(unsigned(selector)+1);
      wait for clk_period*10;
		selector <= std_logic_vector(unsigned(selector)+1);
      wait for clk_period*10;
		selector <= std_logic_vector(unsigned(selector)+1);
      wait for clk_period*10;
		selector <= std_logic_vector(unsigned(selector)+1);
      wait for clk_period*10;
		selector <= std_logic_vector(unsigned(selector)+1);
      wait for clk_period*10;
		selector <= std_logic_vector(unsigned(selector)+1);
      wait for clk_period*10;
		selector <= std_logic_vector(unsigned(selector)+1);
      wait for clk_period*10;
		selector <= std_logic_vector(unsigned(selector)+1);
      -- insert stimulus here 

      wait;
   end process;

END;
