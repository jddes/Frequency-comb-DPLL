--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   13:57:40 01/30/2014
-- Design Name:   
-- Module Name:   C:/_JD/FPGA_code/Daves_FPGA_box/SimplePI/fir_3tap_plus_2ndorder_boxcar_testbench.vhd
-- Project Name:  SuperLaserLand
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: fir_3tap_plus_2ndorder_boxcar
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
 
ENTITY fir_3tap_plus_2ndorder_boxcar_testbench IS
END fir_3tap_plus_2ndorder_boxcar_testbench;
 
ARCHITECTURE behavior OF fir_3tap_plus_2ndorder_boxcar_testbench IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT fir_3tap_plus_2ndorder_boxcar
    PORT(
         rst : IN  std_logic;
         clk : IN  std_logic;
         data_input : IN  std_logic_vector(15 downto 0);
         data_output : OUT  std_logic_vector(15 downto 0)
        );
    END COMPONENT;
    

   --Inputs
   signal rst : std_logic := '0';
   signal clk : std_logic := '0';
   signal data_input : std_logic_vector(15 downto 0) := (others => '0');
	
	signal read_address : unsigned(17-1 downto 0) := (others => '0');

 	--Outputs
   signal data_output : std_logic_vector(15 downto 0);

   -- Clock period definitions
   constant clk_period : time := 10 ns;
 
BEGIN
 

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
			rst <= '1';
      wait for 100 ns;	
			rst <= '0';

      wait;
   end process;
	
	

	-- Load the input data from a file
	--------------------------------------------------
	load_inst : entity work.load_data_from_file
	Generic map (
		ADDRESS_WIDTH => read_address'length,
		DATA_WIDTH =>  data_input'length,
		DATA_FILE => "MATLAB_testbench_toolbox\testbench_rom_data.txt"
	
	)
	Port map (
		clk => clk,
		read_address => std_logic_vector(read_address),
		data_out => data_input
	);
	
	process (clk)
	begin
		if rising_edge(clk) then
			read_address <= read_address + 1;
		end if;
	end process;
	
	-- User code goes here: do something useful with the data... 
	--------------------------------------------------
   uut: fir_3tap_plus_2ndorder_boxcar PORT MAP (
          rst => rst,
          clk => clk,
          data_input => data_input,
          data_output => data_output
        );
		  
	--------------------------------------------------
	
	-- Save the results from a file
	--------------------------------------------------
	save_inst : entity work.save_simulation_data
	Generic map (
		DATA_WIDTH =>  data_input'length + data_output'length,
		FILE_NAME => "data_output.txt"
	
	)
	Port map (
		clk => clk,
		write_enable => '1',
		data => (data_input & data_output)
	);
	


END;
