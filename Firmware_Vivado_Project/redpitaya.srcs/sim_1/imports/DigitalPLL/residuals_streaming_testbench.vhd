--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   14:38:43 03/03/2014
-- Design Name:   
-- Module Name:   C:/_JD/FPGA_code/Daves_FPGA_box/SimplePI/residuals_streaming_testbench.vhd
-- Project Name:  SuperLaserLand
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: residuals_streaming
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
 
ENTITY residuals_streaming_testbench IS
END residuals_streaming_testbench;
 
ARCHITECTURE behavior OF residuals_streaming_testbench IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 

    

   --Inputs
   signal clk : std_logic := '0';
   signal rst : std_logic := '0';
   signal trigger_input : std_logic := '0';
   signal trigger_delay : std_logic_vector(31 downto 0) := std_logic_vector(to_unsigned(1, 32));
   signal boxcar_filter_size : std_logic_vector(4 downto 0) := std_logic_vector(to_unsigned(11, 5));
   signal phase_residuals : std_logic_vector(31 downto 0) := (others => '0');
	signal data_delay : std_logic_vector(8-1 downto 0) := std_logic_vector(to_unsigned(1, 8));
	
	signal freq_residuals : std_logic_vector(10-1 downto 0) := std_logic_vector(to_unsigned(511, 10));
	signal select_phase_or_freq : std_logic := '1';
	
	signal simulation_counter : unsigned (32-1 downto 0) := (others => '0');

 	--Outputs
   signal data_output_to_fifo : std_logic_vector(31 downto 0);
   signal output_clk_enable : std_logic;

   -- Clock period definitions
   constant clk_period : time := 10 ns;
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: entity work.residuals_streaming
	GENERIC MAP (
		N_BITS_DATA => 32,
		N_SAMPLES_HOLDOFF => 10
	
	) PORT MAP (
          clk => clk,
          rst => rst,
          trigger_input => trigger_input,
          trigger_delay => trigger_delay,	-- real trigger delay is trigger_delay+7, minimum value is trigger_delay=1
			 data_delay => data_delay,
          boxcar_filter_size => boxcar_filter_size,
          phase_residuals => phase_residuals,	-- this signal is filtered by a 'boxcar_filter_size'-long boxcar + delayed by one extra sample, and gets sampled trigger_delay+7 clock cycles after a transition on trigger_input.
			 select_phase_or_freq => select_phase_or_freq,
			 freq_residuals => freq_residuals,
			 
          data_output_to_fifo => data_output_to_fifo,
          output_clk_enable => output_clk_enable
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
			if rst = '1' then
				simulation_counter <= (others => '0');
			else
				simulation_counter <= simulation_counter + 1;
				if simulation_counter(2 downto 0) = 0 then
					trigger_input <= not trigger_input;
				end if;
				
				if simulation_counter(9 downto 0) = 0 then
					phase_residuals <= std_logic_vector(signed(phase_residuals) + 1);
--					phase_residuals <= std_logic_vector(to_signed(10, 32));
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
		wait for clk_period*1000;
			boxcar_filter_size <= std_logic_vector(to_unsigned(2, 5));
			rst <= '1';
		wait until rising_edge(clk);
		wait until rising_edge(clk);
			rst <= '0';
		
		wait for clk_period*1000;
		
			data_delay <= std_logic_vector(to_unsigned(57, 8));
			rst <= '1';
		wait until rising_edge(clk);
		wait until rising_edge(clk);
			rst <= '0';

		wait for clk_period*1000;
      -- insert stimulus here 

      wait;
   end process;

END;
