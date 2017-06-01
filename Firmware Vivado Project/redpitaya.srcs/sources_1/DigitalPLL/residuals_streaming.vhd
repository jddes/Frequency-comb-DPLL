----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    14:11:26 03/03/2014 
-- Design Name: 
-- Module Name:    residuals_streaming - Behavioral 
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
-- Description: 
--
-- Dependencies: 
--
-- Revision: 
-- Revision 0.01 - File Created
-- Additional Comments: 
--
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity residuals_streaming is
	Generic (
		N_BITS_DATA : integer := 32;
		N_SAMPLES_HOLDOFF : integer := 3333	-- set at 100e6/3e3 * 0.1, which means 10 % of the nominal IGM period
	);
    Port ( clk : in  STD_LOGIC;
				rst : in std_logic;
           trigger_input : in  STD_LOGIC;
			  trigger_delay : in std_logic_vector(32-1 downto 0);	-- real trigger delay is trigger_delay+7, minimum value is trigger_delay=1
			  -- if trigger_delay could be set at -3, and boxcar_filter_size = 11, the internal delays would all be compensated so that a transition on phase_residuals would be sampled at the right time if the trigger_input was exactly aligned with it.
			  data_delay : in std_logic_vector(8-1 downto 0);
			  boxcar_filter_size : in std_logic_vector(5-1 downto 0);
           phase_residuals : in  STD_LOGIC_VECTOR (N_BITS_DATA-1 downto 0);
			  select_phase_or_freq : in std_logic;	-- 0 means phase_residuals, 1 means freq_residuals, which are internally integrated to 32 bits.
			  freq_residuals : in std_logic_vector(10-1 downto 0);
           data_output_to_fifo : out  STD_LOGIC_VECTOR (N_BITS_DATA-1 downto 0);
           output_clk_enable : out  STD_LOGIC);
end residuals_streaming;

architecture Behavioral of residuals_streaming is
	signal holdoff_counter : unsigned(32-1 downto 0) := (others => '0');
	signal delay_counter : unsigned(32-1 downto 0) := (others => '0');
	signal delay_counter_was_zero : std_logic := '0';
	
	signal trigger0, trigger1, trigger2, trigger3, trigger4 : std_logic := '0';
	signal internal_trigger, output_trigger_internal : std_logic := '0';
	signal internal_trigger_delayed : std_logic := '0';
	
	signal data_delayed : std_logic_vector(N_BITS_DATA-1 downto 0) := (others => '0');
	signal data_filtered : std_logic_vector(N_BITS_DATA-1 downto 0) := (others => '0');
	signal data_output_to_fifo_internal : std_logic_vector(N_BITS_DATA-1 downto 0) := (others => '0');
	
	-- these signals are for the integrated frequency residuals:
	signal filtered_freq_residuals : std_logic_vector(freq_residuals'length+7-1 downto 0);
	signal integrated_freq : std_logic_vector(N_BITS_DATA-1 downto 0) := (others => '0');
begin

	-- lowpass filter on the phase
	-- These filters have a DC gain equal to their lengths (they output boxcar_filter_size summed samples)
   boxcar_filter_inst: entity work.adjustable_boxcar_filter_v2
	Generic map (
		LOG2_MAXIMUM_SIZE => 5,	--2**5 = 32 points max (or maybe 31 - didnt test thoroughly near the max)
		DATA_WIDTH => phase_residuals'length-5
	)
	PORT MAP (
          rst => rst,
          clk => clk,
          --input_clk_enable => '1',
			 
          input_data => phase_residuals(phase_residuals'length-1-5 downto 0),
          filter_size => boxcar_filter_size(5-1 downto 0),
			 
          --output_clk_enable => open,
          output_data => data_filtered
        );
		  
	-- Add a programmable delay line to the residuals data:

	
   delay_inst: entity work.programmable_delay_line
	GENERIC MAP (
			MAXIMUM_DELAY => 255,
			DATA_BITS => 32
	)
	PORT MAP (
          rst => rst,
          clk => clk,
			 
			 -- Input port
          input_clk_enable => '1',
          data_in => data_filtered,
			 
				-- Configuration port.  The actual delay will be desired_delay_minus_one_minus_one+1.
				-- Reset must be asserted after changing the delay value in order for the change to take effect.
          desired_delay_minus_one => (b"0000" & data_delay),
			 
			 -- Output port
          data_out => data_delayed,
          output_clk_enable => open
        );
		  
--	data_filtered <= phase_residuals;	-- for debug: bypass input filter

	-- The trigger detection unit has holdoff (controlled by the generic N_SAMPLES_HOLDOFF)
	-- and triggers when the trigger_input has either a rising or a falling edge.
	-- there is also a 4-stage register stage de-glitching
	process (clk)
	begin
		if rising_edge(clk) then
		
			-- Input de-glitching register line:
			trigger0 <= trigger_input;
			trigger1 <= trigger0;
			trigger2 <= trigger1;
			trigger3 <= trigger2;
			trigger4 <= trigger3;
		
			-- Trigger detection logic
			if holdoff_counter > 0 then
				-- We are holding off
				holdoff_counter <= holdoff_counter - 1;
				internal_trigger <= '0';
			else
				-- We are ready to accept another trigger:
				if trigger3 = not trigger4 then
					holdoff_counter <= to_unsigned(N_SAMPLES_HOLDOFF, holdoff_counter'length);
					internal_trigger <= '1';
				else
					internal_trigger <= '0';
				end if;
				
			end if;
			

			
			-- Trigger delay
			-- This is not a real delay line, but rather a counter which resets when internal_trigger = '1',
			-- counts trigger_delay clock cycles, and then outputs a delayed, 1-cycle long trigger.
			if delay_counter > 0 then
				-- counting.
				delay_counter <= delay_counter - 1;
				internal_trigger_delayed <= '0';
				delay_counter_was_zero <= '0';
			else
				-- we output a '1' when the counter reaches 0.
				delay_counter_was_zero <= '1';
				if delay_counter_was_zero = '0' then
					-- we have just reached 0. output a pulse
					internal_trigger_delayed <= '1';
				else
					internal_trigger_delayed <= '0';
					
					-- start the counter if we need to:
					if internal_trigger = '1' then
						delay_counter <= unsigned(trigger_delay);
					end if;
				end if;
			end if;
			
		end if;
	end process;
	
	-- this integrates the freq_residuals to a 32-bits phase vector, but most importantly makes this integration modulo 32 bits.
	-- this is because the other input actually has saturation which means that we can't track an open-loop tone for as long as we want.
	-- we first put a 100-pts long filter to help averaged away some of the CORDIC's phase error (and wideband noise)
	boxcar_filter_100_pts_inst : entity work.adjustable_boxcar_filter_v2
	generic map (
		LOG2_MAXIMUM_SIZE => 7,
		DATA_WIDTH => freq_residuals'length
	) port map (
		rst => rst,
		clk => clk,
		
		input_data => freq_residuals,
		filter_size => std_logic_vector(to_unsigned(100, 7)),
		output_data => filtered_freq_residuals
	);
	-- the actual integrator
	process (clk)
	begin
		if rising_edge(clk) then
			integrated_freq <= std_logic_vector(signed(integrated_freq) + resize(signed(filtered_freq_residuals), integrated_freq'length));
		end if;
	end process;

	-- output register
	process (clk)
	begin
		if rising_edge(clk) then
			if internal_trigger_delayed = '1' then
				output_trigger_internal <= '1';
				if select_phase_or_freq = '0' then
					data_output_to_fifo_internal <= data_delayed;
				else
					data_output_to_fifo_internal <= integrated_freq;
				end if;
			else
				output_trigger_internal <= '0';
			end if;
			
		end if;
	end process;
	
	data_output_to_fifo	<= data_output_to_fifo_internal;
	output_clk_enable		<= output_trigger_internal;
	
end Behavioral;

