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
 
ENTITY PLL_loop_filters_testbench2 IS
END PLL_loop_filters_testbench2;
 
ARCHITECTURE behavior OF PLL_loop_filters_testbench2 IS 
 
    -- Component Declaration for the Unit Under Test (UUT)

    

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
	
	signal data_out_summed : signed(15 downto 0) := (others => '0');
	signal data_out_summed_last : signed(15 downto 0) := (others => '0');
	signal data_out_summed_diffed : signed(15 downto 0) := (others => '0');
	
	signal input_counter : unsigned(32-1 downto 0) := (others => '0');

   -- Clock period definitions
   constant clk_period : time := 10 ns;
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: entity work.PLL_loop_filters_with_saturation
	Generic map (
		N_DIVIDE_P => 11,
		N_DIVIDE_I => 24,
		N_DIVIDE_II => 24
	
	) PORT MAP (
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
			
			
			data_out_summed <= data_out_summed + signed(data_out) + to_signed(10, 16);
			data_out_summed_last <= data_out_summed;
			data_out_summed_diffed <= data_out_summed - data_out_summed_last;
--			data_in <= std_logic_vector(data_out_summed_diffed(data_in'range));


			if input_counter < 10e3 then
				input_counter <= input_counter + 1;
			else
				input_counter <= (others => '0');
			end if;
			
--			if input_counter < 5e3 then
--				data_in <= std_logic_vector( to_signed(511, data_in'length));
--				--gain_p  <= std_logic_vector(to_signed(20*2**24, 32));
--			else
--				data_in <= std_logic_vector( to_signed(-511, data_in'length));
--				--gain_p  <= std_logic_vector(to_signed(-20*2**24, 32));
--			end if;
			
		end if;
	end process;

   -- Stimulus process
   stim_proc: process
   begin		
      -- hold reset state for 100 ns.
      wait for 100 ns;	
		
		-- testing saturation behavior of the P branch:
      wait for clk_period*50;
			lock <= '1';
			data_in <= std_logic_vector(to_signed(511, data_in'length));
			gain_p  <= std_logic_vector(to_signed(2**(24-3), 32));
			gain_i  <= std_logic_vector(to_signed(0*2**(24-3), 32));
			gain_ii <= std_logic_vector(to_signed(0*2**13, 32));
			
      wait for clk_period*50;
			lock <= '1';
			data_in <= std_logic_vector(to_signed(511, data_in'length));
			gain_p  <= std_logic_vector(to_signed(2**(24-3), 32));
			gain_i  <= std_logic_vector(to_signed(0*2**(24-3), 32));
			gain_ii <= std_logic_vector(to_signed(0*2**13, 32));
			
		-- make the input LSB toggle for 20 cycles:
		wait for clk_period*50;
			gain_p  <= std_logic_vector(to_signed(2**(16+11), 32));
			gain_changed <= '1';
		wait for clk_period*2;
			gain_changed <= '0';
		
		for i in 0 to 20 loop
			wait until rising_edge(clk);
			if signed(data_in) = 0 then
				data_in <= b"0000_0000_01";
			else
				data_in <= (others => '0');
			end if;
		end loop;
			
		wait for clk_period*10;
			data_in <= std_logic_vector( to_signed(1, data_in'length));
		wait for clk_period*10;
			data_in <= std_logic_vector( to_signed(511, data_in'length));
		wait for clk_period*1000;
		
		-- testing saturation behavior of the I branch:
      wait for clk_period*50;
			lock <= '1';
			gain_changed <= '1';
			
			gain_i  <= b"00000000111111111111111111111111";	-- 2**31-1
			gain_ii <= std_logic_vector(to_signed(0*2**13, 32));
		wait for clk_period*2;
			gain_changed <= '0';
			
		-- to test integrator saturation behavior
		wait until rising_edge(clk);
      
			lock <= '1';
			data_in <= std_logic_vector( to_signed(511, data_in'length));
			gain_p  <= std_logic_vector(to_signed(0, 32));
			gain_i  <= std_logic_vector(to_signed(2**(24-3), 32));
			gain_ii <= std_logic_vector(to_signed(0*2**13, 32));
			gain_changed <= '1';
		
		wait until rising_edge(clk);
			gain_changed <= '0';
--		
--		wait for clk_period*50000;
--		
--		
--		
--		-- testing saturation behavior of the I^2 branch:
--      wait for clk_period*50;
--			lock <= '1';
--			gain_changed <= '1';
--			
--			gain_i  <= b"00000000000001111111111111111111";
--			gain_ii <= b"00000011111111111111111111111111";
--		wait for clk_period*2;
--			gain_changed <= '0';
			

		
		
		
		-- to test integrator startup behavior
--      wait for clk_period*50;
--			lock <= '1';
--			gain_p  <= std_logic_vector(to_signed(0, 32));
--			gain_i  <= std_logic_vector(to_signed(-2**(24-3), 32));
--			gain_ii <= std_logic_vector(to_signed(0*2**13, 32));
--			
--		wait for clk_period*1000;
--		
--		wait for clk_period*10;
--			gain_changed <= '1';
--			gain_p  <= std_logic_vector(to_signed(0, 32));
--			gain_i  <= std_logic_vector(to_signed(-2**(24-3), 32));
--			gain_ii <= std_logic_vector(to_signed(-2**(24-3-10), 32));
		
      wait;
   end process;

END;
