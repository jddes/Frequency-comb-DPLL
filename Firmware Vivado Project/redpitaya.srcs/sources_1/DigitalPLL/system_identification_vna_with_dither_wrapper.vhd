----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    09:53:12 11/06/2013 
-- Design Name: 
-- Module Name:    system_identification_vna_with_dither_wrapper - Behavioral 
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

entity system_identification_vna_with_dither_wrapper is
    Port (
		rst                         : in  std_logic;
		clk                         : in  std_logic;
		
		-- Cmd bus to program the different variables
		cmd_addr                    : in  std_logic_vector (15 downto 0);
		cmd_data1                   : in  std_logic_vector (15 downto 0);
		cmd_data2                   : in  std_logic_vector (15 downto 0);
		cmd_trig                    : in  std_logic;
		led_debug                   : out std_logic_vector(5 downto 0);
		
		-- A rising edge here triggers the identification process
		trigger_identification      : in  std_logic;
		
		-- Data inputs from the output of the systems to be identified
		data_in1                    : in  std_logic_vector (15 downto 0);
		data_in2                    : in  std_logic_vector (15 downto 0);
		data_in3                    : in  std_logic_vector (15 downto 0);
		data_in4                    : in  std_logic_vector (15 downto 0);
		
		-- Modulation outputs to dacs
		modulation_output_to_dac0   : out std_logic_vector (15 downto 0);
		modulation_output_to_dac1   : out std_logic_vector (15 downto 0);
		modulation_output_to_dac2   : out std_logic_vector (15 downto 0);
		
		-- Sync outputs, used for the dither functionality (another module takes care of lock-in detection of the dither signal and sends the results to the PC through a faster port than the one used by the VNA
		dither_sync_I               : out std_logic;
		dither_sync_Q               : out std_logic;
		
		-- Output port which goes to the data logger which contains the identification results
		output_to_logger            : out std_logic_vector (15 downto 0);
		output_to_logger_clk_enable : out std_logic
			  
	);
end system_identification_vna_with_dither_wrapper;

architecture Behavioral of system_identification_vna_with_dither_wrapper is
	--  Configuration registers:
   signal number_of_cycles_integration : std_logic_vector(31 downto 0) := std_logic_vector(to_unsigned(150, 32));
   signal first_modulation_frequency : std_logic_vector(47 downto 0) := b"000000101000111101011100001010001111010111000010";	-- 1/100
   signal modulation_frequency_step : std_logic_vector(47 downto 0) := b"000001010001111010111000010100011110101110000101";	-- 1/50
   signal number_of_frequencies : std_logic_vector(15 downto 0) := std_logic_vector(to_unsigned(9, 16));
   signal output_gain : std_logic_vector(17 downto 0) := std_logic_vector(to_unsigned(2**15, 18));
	-- Mode control registers
	signal trigger_dither 		:  std_logic := '0';	-- a '1' on this signal sets the module to 'dither' mode: output a constant frequency tone
	signal stop 					: std_logic := '0';	-- a '1' on this signal stop the identification process
	signal bSquareWave 			: std_logic := '0';	-- a '1' on this signal makes the output tone a square wave (intended to be used with the dither mode), while a '0' means that the output will be sinusoidal.



	signal trigger_last : std_logic := '0';
	

			  
	-- signals for the input/output multiplexer:
	signal input_and_output_mux_selector : std_logic_vector(3 downto 0) := b"0000";
	signal selected_input : std_logic_vector(data_in1'range);
	signal selected_output : std_logic_vector(modulation_output_to_dac1'range);
	
	-- signals for the results of the identification
	-- and the parallel-to-serial mux:
	signal integrator_real_output, integrator_imag_output : std_logic_vector(63 downto 0);
	signal integrator_accumulated_samples : std_logic_vector(32-1 downto 0);
	signal integrator_clk_output_enable : std_logic := '0';
	type FSM_state_type is (FSM_IDLE, FSM_R1, FSM_R2, FSM_R3, FSM_R4, FSM_I1, FSM_I2, FSM_I3, FSM_I4, FSM_S1, FSM_S2, FSM_FILLING);
	signal fsm_state_output_serializer : FSM_state_type;
	-- See the comment below in the state machine about this counter
	signal counter_filling : unsigned(31 downto 0) := (others => '0');
	constant FILLING_DATA_WORDS : integer := 2048;
	
begin



-- System Identification vector network analyzer (VNA):
   system_identification_vna_inst: entity work.system_identification_with_dither2
	GENERIC MAP (
		INPUT_WIDTH => 16,
		FREQUENCY_WIDTH => 48,
		MODULATION_OUTPUT_WIDTH => 16
	)
	PORT MAP (
		rst                            => rst,
		clk                            => clk,
		
		-- Configuration of the system identification
		number_of_cycles_integration   => number_of_cycles_integration,
		first_modulation_frequency     => first_modulation_frequency,
		modulation_frequency_step      => modulation_frequency_step,
		number_of_frequencies          => number_of_frequencies,
		output_gain                    => output_gain,
		
		-- Mode control signals
		trigger_identification         => trigger_identification,
		trigger_dither                 => trigger_dither,
		stop                           => stop,
		bSquareWave                    => bSquareWave,
		
		-- System output (from the ADC, through any processing desired)
		data_in                        => selected_input,
		
		-- Modulation output - goes to the DAC
		modulation_output              => selected_output,
		
		-- Results of the system identification - will be serialized to 16 bits packets and sent to the DDR2 data logger
		integrator_real_output         => integrator_real_output,
		integrator_imag_output         => integrator_imag_output,
		integrator_accumulated_samples => integrator_accumulated_samples,
		integrator_clk_output_enable   => integrator_clk_output_enable,
		debug_current_state            => open,
		
		-- Sync outputs, used for the dither functionality (another module takes care of lock-in detection of the dither signal and sends the results to the PC through a faster port than the one used by the VNA
		dither_sync_I                  => dither_sync_I,
		dither_sync_Q                  => dither_sync_Q
        );

	-- Process which multiplexes the two inputs and two outputs to the VNA:
	process (clk)
	begin
		if rising_edge(clk) then
			--input_and_output_mux_selector
			case input_and_output_mux_selector(1 downto 0) is
				when b"00" =>
					selected_input <= data_in1;
				when b"01" =>
					selected_input <= data_in2;
				when b"10" =>
					selected_input <= data_in3;
				when b"11" =>
					selected_input <= data_in4;
				when others =>
					selected_input <= data_in1;
			end case;
			
			case input_and_output_mux_selector(3 downto 2) is
				when b"00" =>
					modulation_output_to_dac0 <= selected_output;
					modulation_output_to_dac1 <= (others => '0');
					modulation_output_to_dac2 <= (others => '0');
				when b"01" =>
					modulation_output_to_dac0 <= (others => '0');
					modulation_output_to_dac1 <= selected_output;
					modulation_output_to_dac2 <= (others => '0');
				when b"10" =>
					modulation_output_to_dac0 <= (others => '0');
					modulation_output_to_dac1 <= (others => '0');
					modulation_output_to_dac2 <= selected_output;
				when others =>
					modulation_output_to_dac0 <= (others => '0');
					modulation_output_to_dac1 <= (others => '0');
					modulation_output_to_dac2 <= (others => '0');
			end case;
		end if;
	end process;

	-- Process which decodes the commands on the cmd bus and assigns the configuration variables:
	process (clk)
	begin
		if rising_edge(clk) then
			trigger_last <= cmd_trig;

			-- Detect rising edge on cmd_trig:
			if trigger_last = '0' and cmd_trig = '1' and cmd_addr(15 downto 15-4+1) = x"5" then
				-- Address decoder:
				case cmd_addr(3 downto 0) is
					when x"0" =>
						-- Load number_of_cycles_integration (32 bits)
						number_of_cycles_integration <= cmd_data2 & cmd_data1;
						
					when x"1" =>
						-- Load first_modulation_frequency (first 32 LSBs of 48 total bits)
						first_modulation_frequency(31 downto 0) <= cmd_data2 & cmd_data1;
						
					when x"2" =>
						-- Load first_modulation_frequency (last 16 MSBs of 48 total bits)
						first_modulation_frequency(47 downto 32) <= cmd_data1;
						
					when x"3" =>
						-- Load modulation_frequency_step (first 32 LSBs of 48 total bits)
						modulation_frequency_step(31 downto 0) <= cmd_data2 & cmd_data1;
						
					when x"4" =>
						-- Load first_modulation_frequency (last 16 MSBs of 48 total bits)
						modulation_frequency_step(47 downto 32) <= cmd_data1;
						
					when x"5" =>
						-- Load number_of_frequencies (16 bits)
						number_of_frequencies <= cmd_data1(15 downto 0);
						led_debug <= cmd_data1(5 downto 0);
						
					when x"6" =>
						-- Load output_gain (18 bits)
						output_gain <= cmd_data2(1 downto 0) & cmd_data1;
						
					when x"7" =>
						-- Load input_and_output_mux_selector (4 bits)
						input_and_output_mux_selector <= cmd_data1(input_and_output_mux_selector'range);
						
					when x"8" =>
						-- Load mode control binary signals (3 bits)
						stop <= cmd_data1(0);
						trigger_dither <= cmd_data1(1);
						bSquareWave <= cmd_data1(2);
						
						
						
						
					when others =>
						-- do nothing
				end case;
			end if;

		end if;
	end process;
	
	-- State machine which takes the wide, parallel output from the VNA identification module and serializes it to 16 bits words:
	-- This state machine has only one condition transition (integrator_clk_output_enable = '1'), which makes the machine go through all of its states
	-- and come back to idle.
	process (clk)
	begin
		if rising_edge(clk) then
			case fsm_state_output_serializer is
				when FSM_IDLE =>
					output_to_logger_clk_enable <= '0';
					if integrator_clk_output_enable = '1' then
						fsm_state_output_serializer <= FSM_R1;
					end if;
					
					
				when FSM_R1 =>
					output_to_logger_clk_enable <= '1';
					output_to_logger <= integrator_real_output(15 downto 0);
					fsm_state_output_serializer <= FSM_R2;
					
				when FSM_R2 =>
					output_to_logger_clk_enable <= '1';
					output_to_logger <= integrator_real_output(31 downto 15+1);
					fsm_state_output_serializer <= FSM_R3;
					
				when FSM_R3 =>
					output_to_logger_clk_enable <= '1';
					output_to_logger <= integrator_real_output(48-1 downto 32);
					fsm_state_output_serializer <= FSM_R4;
					
				when FSM_R4 =>
					output_to_logger_clk_enable <= '1';
					output_to_logger <= integrator_real_output(64-1 downto 48);
					fsm_state_output_serializer <= FSM_I1;
					
				when FSM_I1 =>
					output_to_logger_clk_enable <= '1';
					output_to_logger <= integrator_imag_output(15 downto 0);
					fsm_state_output_serializer <= FSM_I2;
					
				when FSM_I2 =>
					output_to_logger_clk_enable <= '1';
					output_to_logger <= integrator_imag_output(31 downto 15+1);
					fsm_state_output_serializer <= FSM_I3;
					
				when FSM_I3 =>
					output_to_logger_clk_enable <= '1';
					output_to_logger <= integrator_imag_output(48-1 downto 32);
					fsm_state_output_serializer <= FSM_I4;
					
				when FSM_I4 =>
					output_to_logger_clk_enable <= '1';
					output_to_logger <= integrator_imag_output(64-1 downto 48);
					fsm_state_output_serializer <= FSM_S1;
					
				when FSM_S1 =>
					output_to_logger_clk_enable <= '1';
					output_to_logger <= integrator_accumulated_samples(15 downto 0);
					fsm_state_output_serializer <= FSM_S2;
					
				when FSM_S2 =>
					output_to_logger_clk_enable <= '1';
					output_to_logger <= integrator_accumulated_samples(31 downto 15+1);
					fsm_state_output_serializer <= FSM_IDLE;
					counter_filling <= (others => '0');
					
				when FSM_FILLING =>	-- This state is to make up for the fact that data written to the DDR2Logger doesn't all get committed to the DDR2 if it doesn't fit onto certain boundaries.
											-- Instead of figuring out exactly how big the packets have to be, we simply add a lot of padding at the end to make sure all
											-- the valid data actually gets written.
					output_to_logger_clk_enable <= '1';
					output_to_logger <= (others => '0');
					
					counter_filling <= counter_filling + 1;
					if counter_filling = FILLING_DATA_WORDS then
						fsm_state_output_serializer <= FSM_IDLE;
					end if;

					
					
				when others =>
					fsm_state_output_serializer <= FSM_IDLE;
			end case;


		end if;
	end process;

end Behavioral;

