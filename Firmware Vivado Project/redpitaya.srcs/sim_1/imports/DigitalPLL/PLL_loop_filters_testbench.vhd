--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   12:22:49 11/29/2013
-- Design Name:   
-- Module Name:   C:/_JD/FPGA code/Daves FPGA box/SimplePI/PLL_loop_filters_testbench.vhd
-- Project Name:  SuperLaserLand
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: PLL_loop_filters
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
 
ENTITY PLL_loop_filters_testbench IS
END PLL_loop_filters_testbench;
 
ARCHITECTURE behavior OF PLL_loop_filters_testbench IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT PLL_loop_filters
    PORT(
         clk : IN  std_logic;
         lock : IN  std_logic;
         gain_changed : IN  std_logic;
         data_in : IN  std_logic_vector(9 downto 0);
         gain_p : IN  std_logic_vector(31 downto 0);
         gain_i : IN  std_logic_vector(31 downto 0);
			gain_ii : IN  std_logic_vector(31 downto 0);
         data_out : OUT  std_logic_vector(15 downto 0)
        );
    END COMPONENT;
    

   --Inputs
   signal clk : std_logic := '0';
   signal lock : std_logic := '0';
   signal gain_changed : std_logic := '0';
   signal data_in : std_logic_vector(9 downto 0) := (others => '0');
   signal gain_p : std_logic_vector(31 downto 0) := std_logic_vector(to_signed(2 * 2**16, 32));
   signal gain_i : std_logic_vector(31 downto 0) := std_logic_vector(to_signed(4 * 2**16, 32));
	signal gain_ii : std_logic_vector(31 downto 0) := std_logic_vector(to_signed(0, 32));

 	--Outputs
   signal data_out : std_logic_vector(15 downto 0);
	
	-- to help debug second integrator: we compute the second diff of the output:
	signal data_out_last : std_logic_vector(15 downto 0) := (others => '0');
	signal data_out_diff : std_logic_vector(15 downto 0) := (others => '0');
	signal data_out_diff_last : std_logic_vector(15 downto 0) := (others => '0');
	signal data_out_diff2 : std_logic_vector(15 downto 0) := (others => '0');

   -- Clock period definitions
   constant clk_period : time := 10 ns;
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: PLL_loop_filters PORT MAP (
          clk => clk,
          lock => lock,
          gain_changed => gain_changed,
          data_in => data_in,
          gain_p => gain_p,
          gain_i => gain_i,
			 gain_ii => gain_ii,
          data_out => data_out
        );

   -- Clock process definitions
   clk_process :process
   begin
		clk <= '0';
		wait for clk_period/2;
		clk <= '1';
		wait for clk_period/2;
   end process;

	-- Computes the second diff of the data:
	process (clk)
	begin
		if rising_edge(clk) then
			data_out_last <= data_out;
			data_out_diff_last <= data_out_diff;
		
			data_out_diff <= std_logic_vector(signed(data_out) - signed(data_out_last));
			data_out_diff2 <= std_logic_vector(signed(data_out_diff) - signed(data_out_diff_last));
		end if;
	
	end process;

   -- Stimulus process
   stim_proc: process
   begin		
      -- hold reset state for 100 ns.
      wait for 100 ns;	
      wait for clk_period*10;
			lock <= '1';
		wait for clk_period*10;
			data_in <= std_logic_vector(to_signed(0, 10));
			gain_p <= std_logic_vector(to_signed(2 * 2**16, 32));
			gain_i <= std_logic_vector(to_signed(4 * 2**16, 32));
		wait for clk_period*100;
			data_in <= std_logic_vector(to_signed(1, 10));
		wait for clk_period*100;

			gain_p <= std_logic_vector(to_signed(2 * 2**16, 32));
			gain_i <= std_logic_vector(to_signed(0, 32));
		wait for clk_period*100;
			gain_p <= std_logic_vector(to_signed(0, 32));
			gain_i <= std_logic_vector(to_signed(4 * 2**16, 32));
		wait for clk_period*100;
			gain_changed <= '1';
			gain_p <= std_logic_vector(to_signed(0, 32));
			gain_i <= std_logic_vector(to_signed(4 * 2**16, 32));
		wait for clk_period*2;
			gain_changed <= '0';
			
		wait for clk_period*100;
			data_in <= std_logic_vector(to_signed(1, 10));
			
		wait for clk_period*1000;
			gain_p <= std_logic_vector(to_signed(0, 32));
			gain_i <= std_logic_vector(to_signed(0, 32));
			gain_ii <= std_logic_vector(to_signed(1 * 2**25, 32));
			gain_changed <= '1';
		wait for clk_period*2;
			gain_changed <= '0';
			
			data_in <= std_logic_vector(to_signed(1, 10));
		wait for clk_period*5000;
			-- test saturation behavior
			data_in <= std_logic_vector(to_signed(2**9-1, 10));
		wait for clk_period*20000;
			-- test saturation behavior
			data_in <= std_logic_vector(to_signed(-2**9, 10));
		wait for clk_period*20000;

			lock <= '0';
			
		wait for clk_period*10;
			data_in <= std_logic_vector(to_signed(0, 10));
			lock <= '1';
			
      -- insert stimulus here 

      wait;
   end process;

END;
