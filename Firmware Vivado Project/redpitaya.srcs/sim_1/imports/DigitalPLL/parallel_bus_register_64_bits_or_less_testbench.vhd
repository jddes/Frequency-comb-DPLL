--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   13:38:53 02/27/2014
-- Design Name:   
-- Module Name:   C:/_JD/FPGA_code/Daves_FPGA_box/SimplePI/parallel_bus_register_64_bits_or_less_testbench.vhd
-- Project Name:  SuperLaserLand
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: parallel_bus_register_64_bits_or_less
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
 
ENTITY parallel_bus_register_64_bits_or_less_testbench IS
END parallel_bus_register_64_bits_or_less_testbench;
 
ARCHITECTURE behavior OF parallel_bus_register_64_bits_or_less_testbench IS 
 
    -- Component Declaration for the Unit Under Test (UUT)

    

   --Inputs
   signal clk : std_logic := '0';
   signal bus_strobe : std_logic := '0';
   signal bus_address : std_logic_vector(15 downto 0) := (others => '0');
   signal bus_data : std_logic_vector(32-1 downto 0) := (others => '0');

 	--Outputs
   signal register_output : std_logic_vector(120-1 downto 0);
   signal update_flag : std_logic;

   -- Clock period definitions
   constant clk_period : time := 10 ns;
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: entity work.parallel_bus_register_128_bits_or_less
	GENERIC MAP (
		REGISTER_SIZE => 120,
		ADDRESS => 8000
	
	) PORT MAP (
          clk => clk,
          bus_strobe => bus_strobe,
          bus_address => bus_address,
          bus_data => bus_data,
          register_output => register_output,
          update_flag => update_flag
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
		
		
		-- update the LSBs, shouldn't change the output
			bus_address			<= std_logic_vector(to_unsigned(8000, 16));
			bus_data				<= x"1234_5678";
		wait until rising_edge(clk);
			bus_strobe <= '1';
		wait until rising_edge(clk);
			bus_strobe <= '0';
		
      wait for clk_period*10;
		
		-- update the LSBs, shouldn't change the output
			bus_address			<= std_logic_vector(to_unsigned(8001, 16));
			bus_data				<= x"AAAA_BBBB";
		wait until rising_edge(clk);
			bus_strobe <= '1';
		wait until rising_edge(clk);
			bus_strobe <= '0';
		
      wait for clk_period*10;
		
		-- update the LSBs, shouldn't change the output
			bus_address			<= std_logic_vector(to_unsigned(8002, 16));
			bus_data				<= x"CCCC_DDDD";
		wait until rising_edge(clk);
			bus_strobe <= '1';
		wait until rising_edge(clk);
			bus_strobe <= '0';
		
      wait for clk_period*10;

		-- update the MSBs, should update the full output word simultaneously
			bus_address			<= std_logic_vector(to_unsigned(8003, 16));
			bus_data				<= x"EEEE_FFFF";
		wait until rising_edge(clk);
			bus_strobe <= '1';
		wait until rising_edge(clk);
			bus_strobe <= '0';

      wait;
   end process;

END;
