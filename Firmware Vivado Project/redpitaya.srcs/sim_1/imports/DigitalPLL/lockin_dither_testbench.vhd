--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   18:31:25 02/09/2014
-- Design Name:   
-- Module Name:   C:/_JD/FPGA_code/Daves_FPGA_box/SimplePI/lockin_dither_testbench.vhd
-- Project Name:  SuperLaserLand
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: dither_lockin
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
 
ENTITY lockin_dither_testbench IS
END lockin_dither_testbench;
 
ARCHITECTURE behavior OF lockin_dither_testbench IS 
 
    -- Component Declaration for the Unit Under Test (UUT)

    

   --Inputs
   signal clk : std_logic := '0';
   signal data_input : std_logic_vector(9 downto 0) := (others => '0');
   
	
   signal modulation_period_divided_by_4_minus_one : std_logic_vector(27-1 downto 0) := std_logic_vector(to_unsigned(99, 27));
   signal modulation_amplitude : std_logic_vector(15 downto 0) := std_logic_vector(to_unsigned(2*2**6, 16));
   signal bOutputEnable : std_logic := '1';
	
   signal N_periods_integration_minus_one : std_logic_vector(26 downto 0) := std_logic_vector(to_unsigned(3, 27));
	


 	--Outputs
   signal output_to_dac : std_logic_vector(15 downto 0);
   signal result_I : std_logic_vector(47 downto 0);
   signal result_Q : std_logic_vector(47 downto 0);
   signal output_clk_enable : std_logic;

   -- Clock period definitions
   constant clk_period : time := 10 ns;
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: entity work.dither_lockin
	GENERIC MAP (
		SYNC_DELAY => 1
	
	)
	PORT MAP (
          clk => clk,
          data_input => data_input,
          bOutputEnable => bOutputEnable,
          N_periods_integration_minus_one => N_periods_integration_minus_one,
          modulation_period_divided_by_4_minus_one => modulation_period_divided_by_4_minus_one,
          modulation_amplitude => modulation_amplitude,
          output_to_dac => output_to_dac,
          result_I => result_I,
          result_Q => result_Q,
          output_clk_enable => output_clk_enable
        );
	process (clk)
	begin
		if rising_edge(clk) then
			data_input <= output_to_dac(output_to_dac'left downto output_to_dac'left-data_input'length+1);
		end if;
	end process;
	

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

      -- insert stimulus here 

      wait;
   end process;

END;
