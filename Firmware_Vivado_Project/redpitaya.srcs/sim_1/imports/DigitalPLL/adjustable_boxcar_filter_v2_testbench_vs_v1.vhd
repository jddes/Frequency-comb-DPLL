--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   14:31:30 02/04/2014
-- Design Name:   
-- Module Name:   C:/_JD/FPGA_code/Daves_FPGA_box/SimplePI/adjustable_boxcar_filter_v2_testbench_vs_v1.vhd
-- Project Name:  SuperLaserLand
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: adjustable_boxcar_filter_v2
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
 
ENTITY adjustable_boxcar_filter_v2_testbench_vs_v1 IS
END adjustable_boxcar_filter_v2_testbench_vs_v1;
 
ARCHITECTURE behavior OF adjustable_boxcar_filter_v2_testbench_vs_v1 IS 
 
    -- Component Declaration for the Unit Under Test (UUT)

    

   --Inputs
   signal rst : std_logic := '0';
   signal clk : std_logic := '0';
   signal input_data : std_logic_vector(15 downto 0) := (others => '0');
   signal filter_size : std_logic_vector(7 downto 0) := std_logic_vector(to_unsigned(10, 8));
	signal filter_size2 : std_logic_vector(11 downto 0) := std_logic_vector(to_unsigned(10, 12));

	signal data_counter : unsigned(6-1 downto 0) := (others => '0');
 	--Outputs
   signal output_data : std_logic_vector(input_data'length-1+8 downto 0);
	signal output_data2 : std_logic_vector(input_data'length-1+12 downto 0);

   -- Clock period definitions
   constant clk_period : time := 10 ns;
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: entity work.adjustable_boxcar_filter_v2
	Generic map(
		LOG2_MAXIMUM_SIZE => 8,
		DATA_WIDTH => 16
	)
	
	PORT MAP (
          rst => rst,
          clk => clk,
          input_data => input_data,
          filter_size => filter_size,
          output_data => output_data
        );
		  
   uut2: entity work.adjustable_boxcar_filter
	Generic map (
		MAXIMUM_SIZE => 256,
		DATA_WIDTH => 16
	)
	
	PORT MAP (
          rst => rst,
          clk => clk,
			 input_clk_enable => '1',
          input_data => input_data,
          filter_size => filter_size2,
          output_data => output_data2
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
			data_counter <= data_counter + 1;
			if data_counter = 0 then
				input_data <= std_logic_vector(to_signed(1, input_data'length));
			else
				input_data <= std_logic_vector(to_signed(2, input_data'length));
			end if;
		end if;
	end process;
 

   -- Stimulus process
   stim_proc: process
   begin		
      -- hold reset state for 100 ns.
		rst <= '1';
      wait for clk_period*4;
		rst <= '0';
      wait for clk_period*10;

      -- insert stimulus here 

      wait;
   end process;

END;
