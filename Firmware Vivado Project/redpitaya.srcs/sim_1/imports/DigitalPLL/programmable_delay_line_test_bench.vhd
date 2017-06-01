--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   14:28:36 03/25/2012
-- Design Name:   
-- Module Name:   D:/Projets_Xilinx/test_multiple_clocks2/programmable_delay_line_test_bench.vhd
-- Project Name:  test_multiple_clocks2
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: programmable_delay_line
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
--use ieee.std_logic_unsigned.all;
 
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
USE ieee.numeric_std.ALL;
 
ENTITY programmable_delay_line_test_bench IS
END programmable_delay_line_test_bench;
 
ARCHITECTURE behavior OF programmable_delay_line_test_bench IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
	COMPONENT programmable_delay_line
	Generic (
				MAXIMUM_DELAY	: positive := 16;		-- maximum supported value is 2048, since the addresses are 12 bits.
				DATA_BITS		: positive := 16
	);
	Port (
				rst : in  STD_LOGIC;
				clk : in  STD_LOGIC;
				
				-- Input port
				input_clk_enable : in  STD_LOGIC;
				data_in : in  STD_LOGIC_VECTOR (DATA_BITS-1 downto 0);
				
				-- Configuration port.  The actual delay will be desired_delay_minus_one_minus_one+1.
				-- Reset must be asserted after changing the delay value in order for the change to take effect.
				desired_delay_minus_one : in  STD_LOGIC_VECTOR (11 downto 0);
				
				-- Output port
				data_out : out  STD_LOGIC_VECTOR (DATA_BITS-1 downto 0);
				output_clk_enable : out  STD_LOGIC

	);
	END COMPONENT;
    

   --Inputs
   signal rst : std_logic := '0';
   signal clk : std_logic := '0';
   signal input_clk_enable : std_logic := '0';
   signal data_in : std_logic_vector(15 downto 0) := (others => '0');
   signal desired_delay_minus_one : std_logic_vector(11 downto 0) := (others => '0');

 	--Outputs
   signal data_out : std_logic_vector(15 downto 0);
	signal data_out_v2 : std_logic_vector(15 downto 0);
	
   signal output_clk_enable : std_logic;

   -- Clock period definitions
   constant clk_period : time := 10 ns;
	
	signal clk_counter : unsigned(15 downto 0) := (others => '0');
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: programmable_delay_line
	GENERIC MAP (
			MAXIMUM_DELAY => 36,
			DATA_BITS => 16
	)
	PORT MAP (
          rst => rst,
          clk => clk,
			 
			 -- Input port
          input_clk_enable => input_clk_enable,
          data_in => data_in,
			 
				-- Configuration port.  The actual delay will be desired_delay_minus_one_minus_one+1.
				-- Reset must be asserted after changing the delay value in order for the change to take effect.
          desired_delay_minus_one => desired_delay_minus_one,
			 
			 -- Output port
          data_out => data_out,
          output_clk_enable => output_clk_enable
        );
		  
   uut2: entity work.programmable_delay_line_v2
	GENERIC MAP (
			ADDRESS_BITS => 5,
			DATA_BITS => 16
	)
	PORT MAP (
          clk => clk,
			 
			 -- Input port
          data_in => data_in,
			 
				-- Configuration port.  The actual delay will be desired_delay_minus_one_minus_one+1.
				-- Reset must be asserted after changing the delay value in order for the change to take effect.
          desired_delay_minus_one => desired_delay_minus_one(4 downto 0),
			 
			 -- Output port
          data_out => data_out_v2
        );

   -- Clock process definitions
   clk_process :process
   begin
		clk <= '0';
		wait for clk_period/2;
		clk <= '1';
		wait for clk_period/2;
   end process;
	
	ramp_process : process (clk)
	begin
		if rising_edge(clk) then
			if rst = '1' then
				clk_counter <= (others => '0');
			else
				clk_counter <= clk_counter + 1;
			
			end if;
			data_in <= std_logic_vector(clk_counter);
		end if;
	end process;
 

   -- Stimulus process
   stim_proc: process
   begin		
      -- hold reset state for 100 ns.
		rst <= '1';
		desired_delay_minus_one <= std_logic_vector(to_unsigned(5, desired_delay_minus_one'length));
		input_clk_enable <= '1';
      wait for 100 ns;	
		rst <= '0';
		wait until rising_edge(clk);
      wait for clk_period*10;
			
      -- insert stimulus here 
		wait for clk_period*1000;
			desired_delay_minus_one <= std_logic_vector(to_unsigned(21, desired_delay_minus_one'length));
			rst <= '1';
		wait for clk_period;
			rst <= '0';
		wait for clk_period*1000;
		
      wait;
   end process;

END;
