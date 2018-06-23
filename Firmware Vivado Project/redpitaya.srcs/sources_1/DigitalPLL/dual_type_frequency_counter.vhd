----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    08:02:42 02/25/2014 
-- Design Name: 
-- Module Name:    dual_type_frequency_counter - Behavioral 
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
-- Description: Controls the timing of the integrators in the blocks further down the hierarchy
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

entity dual_type_frequency_counter is
	GENERIC (
		N_BITS_INPUT : integer := 10					-- See comment for the gate time.
		);
    Port (
		rst                              : in  std_logic;
		clk                              : in  std_logic;
		data_input                       : in  std_logic_vector(N_BITS_INPUT-1 downto 0);
		
		
		-- Gate time must be an even number
		-- many of the internal signals are scaled appropriately for a gate time of 100e6 samples.  Using any other value than this will require careful verification of the arithmetic.
		N_gate_time                      : in  std_logic_vector(32-1 downto 0);
		-- this must be an integer divisor of N_GATE_TIME for the two counters to stay synced.
		N_times_faster_gate_time         : in  std_logic_vector(32-1 downto 0);
		triangular_mode                  : in  std_logic; -- if '1', output is a triangular averaging counter, if '0', output is a rectangular averaging counter
		
		
		output_clk_enable_N_times_faster : out std_logic;    -- used to drive another output pipe (the DAC output logger) at exactly N times the rate of the counter data
		data_output                      : out std_logic_vector(64-1 downto 0);
		output_clk_enable                : out std_logic
	 );
end dual_type_frequency_counter;

architecture Behavioral of dual_type_frequency_counter is
	-- cycles counters:
	signal master_counter                            : unsigned(32-1 downto 0) := (others => '0');
	signal N_times_faster_counter                    : unsigned(32-1 downto 0) := (others => '0');
	signal output_clk_enable_N_times_faster_internal : std_logic := '0';
	signal current_phase                             : unsigned(1 downto 0) := (others => '0');
	
	
	-- input register, to help with timing/fanout
	signal data_input_register1, data_input_register2			    : std_logic_vector(N_BITS_INPUT-1 downto 0) := (others => '0');
	
	
	-- signals used to interface to the integrators:
	-- control signals:
	signal rst_integration1, rst_integration2, integration_halfway1, integration_halfway2 : std_logic := '0';
	
	
	-- integrators output signals:
	signal data_output_rect1, data_output_rect2						: std_logic_vector(64-1 downto 0) := (others => '0');
	signal data_output_triangle1, data_output_triangle2				: std_logic_vector(64-1 downto 0) := (others => '0');
	signal output_clk_enable_rect1, output_clk_enable_rect2			: std_logic := '0';
	signal output_clk_enable_triangle1, output_clk_enable_triangle2	: std_logic := '0';
			
	-- part of the reset mecanism:
	signal ignore_next_output : std_logic := '0';
			
	-- output signals:
	signal output_clk_enable_internal : std_logic := '0';
	signal output_register : std_logic_vector(64-1 downto 0) := (others => '0');
begin

	process (clk)
	begin
		if rising_edge(clk) then
			-- input registers:
			data_input_register1 <= data_input;
			data_input_register2 <= data_input;
		end if;
	end process;
	
	-- Counters which orchestrate all the integrators' operation:
	process (clk)
	begin
		if rising_edge(clk) then
			if rst = '1' then
				master_counter         <= (others => '0');
				N_times_faster_counter <= (others => '0');
				current_phase          <= (others => '0');
				rst_integration1	   <= '1';
				rst_integration2	   <= '1';
				integration_halfway1   <= '0';
				integration_halfway2   <= '0';
				ignore_next_output     <= '1';
			else
				if master_counter = unsigned(N_gate_time)-1 then
					master_counter <= (others => '0');
					current_phase <= current_phase + 1;
					
					if current_phase = 0 then
						integration_halfway1		<= '1';
						rst_integration2			<= '1';
					elsif current_phase = 1 then
						rst_integration1			<= '1';
						integration_halfway2		<= '1';
						ignore_next_output          <= '0'; -- this is where we come out of the transient reset state
					elsif current_phase = 2 then
						integration_halfway1		<= '1';
						rst_integration2			<= '1';
					elsif current_phase = 3 then
						rst_integration1			<= '1';
						integration_halfway2		<= '1';
					end if;
					
					-- reset the faster counter every time the master counter resets to enforce phase sync
					N_times_faster_counter <= (others => '0');
					output_clk_enable_N_times_faster_internal <= '1';
				else
					master_counter <= master_counter + 1;
					rst_integration1			<= '0';
					rst_integration2			<= '0';
					integration_halfway1		<= '0';
					integration_halfway2		<= '0';
					
					
					if N_times_faster_counter = unsigned(N_times_faster_gate_time)-1 then
						N_times_faster_counter <= (others => '0');
						output_clk_enable_N_times_faster_internal <= '1';
					else
						N_times_faster_counter <= N_times_faster_counter + 1;
						output_clk_enable_N_times_faster_internal <= '0';
					end if;
					
				end if;


				---- clear 'ignore output' flag - we use this to avoid outputting an incorrect value when using the reset feature
				--if output_clk_enable_internal = '1' then
				--	ignore_next_output <= '0';
				--end if;

			end if;


		end if;
	end process;
	output_clk_enable_N_times_faster <= output_clk_enable_N_times_faster_internal;
	
	
	-- The actual blocks which contain the integrators (2 integrators each)
   triangular_frequency_counter_inst1: entity work.triangular_frequency_counter
	GENERIC MAP (
		N_BITS_INPUT => N_BITS_INPUT
	)
	PORT MAP (
		clk                        => clk,
		data_input                 => data_input_register1,
		rst_integration            => rst_integration1,
		integration_halfway        => integration_halfway1,
		
		data_output_rect           => data_output_rect1,
		output_clk_enable_rect     => output_clk_enable_rect1,
		data_output_triangle       => data_output_triangle1,
		output_clk_enable_triangle => output_clk_enable_triangle1
    );
		  
   triangular_frequency_counter_inst2: entity work.triangular_frequency_counter
	GENERIC MAP (
		N_BITS_INPUT => N_BITS_INPUT
	)
	PORT MAP (
		clk                        => clk,
		data_input                 => data_input_register2,
		rst_integration            => rst_integration2,
		integration_halfway        => integration_halfway2,
		
		data_output_rect           => data_output_rect2,
		output_clk_enable_rect     => output_clk_enable_rect2,
		data_output_triangle       => data_output_triangle2,
		output_clk_enable_triangle => output_clk_enable_triangle2
    );
		  
	-- output stage:
	-- chooses between the rectangular and triangle outputs depending on the chosen mode,
	-- and muxes the output of the two counters to a single output register with clock enable:
	process (clk)
	begin
		if rising_edge(clk) then
			if triangular_mode = '1' then
				-- triangular mode, mux between output 1 and 2
				if output_clk_enable_triangle1 = '1' then
					if ignore_next_output = '0' then
						output_register <= data_output_triangle1;
					end if;
					output_clk_enable_internal <= '1';
				elsif output_clk_enable_triangle2 = '1' then
					if ignore_next_output = '0' then
						output_register <= data_output_triangle2;
					end if;
					output_clk_enable_internal <= '1';
				else
					output_clk_enable_internal <= '0';
				end if;
			else
				-- rectangular mode,
				-- Fixed 2018-06-22 by JDD based on Connor Frederick's explanation of issue #6 on the Frequency-comb-DPLL GitHub page.
				-- we need to interleave both counters since they actually now count 
				-- using only counter 1 is sufficient ok since the integration runs for half as long (the triangle lasts 2N, while the rectangle lasts N)
				if output_clk_enable_rect1 = '1' then
					if ignore_next_output = '0' then
						output_register <= data_output_rect1;
					end if;
					output_clk_enable_internal <= '1';
				elsif output_clk_enable_rect2 = '1' then
					if ignore_next_output = '0' then
						output_register <= data_output_rect2;
					end if;
					output_clk_enable_internal <= '1';
				else
					output_clk_enable_internal <= '0';
				end if;
				
				
			end if;
		end if;
	end process;
	data_output				<= output_register;
	output_clk_enable		<= output_clk_enable_internal and (not ignore_next_output);
	
end Behavioral;

