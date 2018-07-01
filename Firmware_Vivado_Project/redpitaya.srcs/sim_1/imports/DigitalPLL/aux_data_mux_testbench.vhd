--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   17:24:06 02/14/2014
-- Design Name:   
-- Module Name:   C:/_JD/FPGA_code/Daves_FPGA_box/SimplePI/aux_data_mux_testbench.vhd
-- Project Name:  SuperLaserLand
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: aux_data_mux
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
 
ENTITY aux_data_mux_testbench IS
END aux_data_mux_testbench;
 
ARCHITECTURE behavior OF aux_data_mux_testbench IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT aux_data_mux
    PORT(
         clk : IN  std_logic;
         write_mode : IN  std_logic;
         ADC0 : IN  std_logic_vector(15 downto 0);
         ADC1 : IN  std_logic_vector(15 downto 0);
         ref_cosine_0 : IN  std_logic_vector(15 downto 0);
         ref_sine_0 : IN  std_logic_vector(15 downto 0);
         ref_cosine_1 : IN  std_logic_vector(15 downto 0);
         ref_sine_1 : IN  std_logic_vector(15 downto 0);
         ADC0_multiplexed : OUT  std_logic_vector(15 downto 0);
         ADC1_multiplexed : OUT  std_logic_vector(15 downto 0)
        );
    END COMPONENT;
    

   --Inputs
   signal clk : std_logic := '0';
   signal write_mode : std_logic := '0';
   signal ADC0 : std_logic_vector(15 downto 0) := std_logic_vector(to_signed(0, 16));
   signal ADC1 : std_logic_vector(15 downto 0) := std_logic_vector(to_signed(10, 16));
   signal ref_cosine_0 : std_logic_vector(15 downto 0) := (others => '0');
   signal ref_sine_0 : std_logic_vector(15 downto 0) := (others => '1');
   signal ref_cosine_1 : std_logic_vector(15 downto 0) := (others => '1');
   signal ref_sine_1 : std_logic_vector(15 downto 0) := (others => '0');

 	--Outputs
   signal ADC0_multiplexed : std_logic_vector(15 downto 0);
   signal ADC1_multiplexed : std_logic_vector(15 downto 0);

   -- Clock period definitions
   constant clk_period : time := 10 ns;
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: aux_data_mux PORT MAP (
          clk => clk,
          write_mode => write_mode,
          ADC0 => ADC0,
          ADC1 => ADC1,
          ref_cosine_0 => ref_cosine_0,
          ref_sine_0 => ref_sine_0,
          ref_cosine_1 => ref_cosine_1,
          ref_sine_1 => ref_sine_1,
          ADC0_multiplexed => ADC0_multiplexed,
          ADC1_multiplexed => ADC1_multiplexed
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
			ADC0 <= std_logic_vector(signed(ADC0) + 1);
			ADC1 <= std_logic_vector(signed(ADC1) + 1);
			
			if signed(ADC0) = 500 then
				write_mode <= '1';
			else
				write_mode <= '0';
			end if;
		end if;
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
