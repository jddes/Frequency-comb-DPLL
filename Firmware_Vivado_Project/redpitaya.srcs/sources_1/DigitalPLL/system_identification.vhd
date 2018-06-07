----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    16:34:44 10/23/2013 
-- Design Name: 
-- Module Name:    system_identification - Behavioral 
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
-- Description: This module outputs a sequence of modulation tones to a DAC, and measures the transfer function
-- from the output to its input.  The tones frequencies are configured by setting the signals:
-- first_modulation_frequency	: The frequency of the first tone
--	modulation_frequency_step	: The step between each modulation frequency
-- number_of_frequencies	: Number of frequencies that will be outputed.
-- output_gain		: The output tone will have an amplitude equal to 2^(DDS_bits) * output_gain/2^15
-- The actual output frequencies will be equal to:
-- f = (first_modulation_frequency + k*modulation_frequency_step) * fs/2^FREQUENCY_WIDTH.
-- where fs is the clock frequency and k is an integer from 0 to number_of_frequencies-1.
--
-- The rest of the inputs are:
--			  -- System output (from the ADC, through any processing desired)
--			  data_in : in  STD_LOGIC_VECTOR (INPUT_WIDTH-1 downto 0);
--			  
--			  -- Modulation output - goes to the DAC
--           modulation_output : out  STD_LOGIC_VECTOR (MODULATION_OUTPUT_WIDTH-1 downto 0);
--			  
--			  -- Results of the system identification
--           integrator_real_output : out  STD_LOGIC_VECTOR (0 downto 0);
--           integrator_imag_output : out  STD_LOGIC_VECTOR (0 downto 0);
--           integrator_clk_output_enable : out  STD_LOGIC;
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

entity system_identification is
	Generic (
		INPUT_WIDTH : integer := 10;
		FREQUENCY_WIDTH : integer := 48;
		MODULATION_OUTPUT_WIDTH : integer := 16	-- cannot be changed, linked to a coregen core
	);
    Port ( rst : in  STD_LOGIC;
           clk : in  STD_LOGIC;
			  
			  
           -- Configuration of the system identification
			  number_of_cycles_integration : in std_logic_vector(31 downto 0);
           first_modulation_frequency : in  STD_LOGIC_VECTOR (FREQUENCY_WIDTH-1 downto 0);
           modulation_frequency_step : in  STD_LOGIC_VECTOR (FREQUENCY_WIDTH-1 downto 0);
           number_of_frequencies : in  STD_LOGIC_VECTOR (15 downto 0);
           output_gain : in  STD_LOGIC_VECTOR (17 downto 0);
			  trigger_identification : in std_logic;	-- a rising edge on this signal triggers the identification process
			  
			  -- System output (from the ADC, through any processing desired)
			  data_in : in  STD_LOGIC_VECTOR (INPUT_WIDTH-1 downto 0);
			  
			  -- Modulation output - goes to the DAC
           modulation_output : out  STD_LOGIC_VECTOR (MODULATION_OUTPUT_WIDTH-1 downto 0);
			  
			  -- Results of the system identification
           integrator_real_output : out  STD_LOGIC_VECTOR (64-1 downto 0);
           integrator_imag_output : out  STD_LOGIC_VECTOR (64-1 downto 0);
           integrator_clk_output_enable : out  STD_LOGIC;
			  
			  
           debug_current_state : out  STD_LOGIC_VECTOR (7 downto 0)
			  
			  
			  );
end system_identification;

architecture Behavioral of system_identification is

	--Coregen declarations
	-----------------------------------------------------------------------
	-- The Core which generates sine and cosine
	component LO_DDS
		port (
		clk: in std_logic;
		pinc_in: in std_logic_vector(47 downto 0);
		cosine: out std_logic_vector(15 downto 0);
		sine: out std_logic_vector(15 downto 0);
		phase_out: out std_logic_vector(47 downto 0));
	end component;
	
	COMPONENT system_identification_macc
	  PORT (
		 clk : IN STD_LOGIC;
		 ce : IN STD_LOGIC;
		 sclr : IN STD_LOGIC;
		 a : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
		 b : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
		 s : OUT STD_LOGIC_VECTOR(64-1 DOWNTO 0)
	  );
	END COMPONENT;
	
	COMPONENT system_identification_outputgain_mult
	  PORT (
		 clk : IN STD_LOGIC;
		 a : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
		 b : IN STD_LOGIC_VECTOR(17 DOWNTO 0);
		 sclr : IN STD_LOGIC;
		 p : OUT STD_LOGIC_VECTOR(15 DOWNTO 0)
	  );
	END COMPONENT;

	-- Signals for the DDS which generates the modulation tone
	signal disable_modulation_output		: std_logic;
	signal current_modulation_frequency : std_logic_vector(47 downto 0) := (others => '0');
	signal DDS_cosine			: std_logic_vector(16-1 downto 0);
	signal DDS_sine			: std_logic_vector(16-1 downto 0);
	
	-- Multiply-Accumulate signals 
	signal macc_clear					: std_logic := '1';
	signal real_accumulator_wide	: std_logic_vector(64-1 downto 0);
	signal imag_accumulator_wide	: std_logic_vector(64-1 downto 0);
	signal real_accumulator_register	: std_logic_vector(64-1 downto 0);
	signal imag_accumulator_register	: std_logic_vector(64-1 downto 0);
	signal integrator_clk_output_enable_register : std_logic := '0';
	
	-- Signals for the FSM which controls the start and stop of the integration and the output of the tone:
	type FSM_state_type is (FSM_STATE_IDLE, FSM_STATE_WAIT_STEADY_STATE, FSM_STATE_INTEGRATING);
	signal FSM_state : FSM_state_type;
	signal fsm_wait_counter : unsigned(number_of_cycles_integration'range) := (others => '0');
	signal trigger_identification_last : std_logic := '0';
	signal modulation_frequency_index : unsigned(number_of_frequencies'range) := (others => '0');
	
begin

	-- Compute cos() and sin()
	LO_DDS_inst : LO_DDS
			port map (
				clk => clk,
				pinc_in => current_modulation_frequency,
				cosine => DDS_cosine,
				sine => DDS_sine,
				phase_out => open);
				
	-- Multply the input signal by cos() and integrate:
	system_identification_macc_cos_inst : system_identification_macc
	  PORT MAP (
		 clk => clk,
		 ce => '1',
		 sclr => macc_clear,
		 a => data_in,
		 b => DDS_cosine,
		 s => real_accumulator_wide
	  );
	  
	-- Multply the input signal by sin() and integrate:
	system_identification_macc_sin_inst : system_identification_macc
	  PORT MAP (
		 clk => clk,
		 ce => '1',
		 sclr => macc_clear,
		 a => data_in,
		 b => DDS_sine,
		 s => imag_accumulator_wide
	  );
	  
	  
	-- Multiply the cos() signal by the output gain and output:

	output_mult_inst : system_identification_outputgain_mult
	  PORT MAP (
		 clk => clk,
		 a => DDS_cosine,
		 b => output_gain,
		 sclr => disable_modulation_output,
		 p => modulation_output
	  );
	
	  
	-- FSM which controls the whole module.  The process drives the outputs which change on transitions of the FSM, and implements the state change equations.
	-- Drives trigger_identification_last, FSM_state, modulation_frequency_index
	-- real_accumulator_register, imag_accumulator_register, 
	process (clk)
	begin
		if rising_edge(clk) then
			if rst = '1' then
				FSM_state <= FSM_STATE_IDLE;
				
				trigger_identification_last <= '0';
				modulation_frequency_index <= (others => '0');
				
				integrator_clk_output_enable_register <= '0';
				real_accumulator_register <= (others => '0');
				imag_accumulator_register <= (others => '0');
				
				--number_of_cycles_integration
				--first_modulation_frequency
				--modulation_frequency_step
				--number_of_frequencies
				--trigger_identification
			else
				trigger_identification_last <= trigger_identification;
				
				case FSM_state is
				
					when FSM_STATE_IDLE =>

						current_modulation_frequency <= first_modulation_frequency;
						integrator_clk_output_enable_register <= '0';
						
						-- Detect rising edge on the trigger input
						if trigger_identification_last = '0' and trigger_identification = '1' then
							-- Wait for the system to reach steady state
							FSM_state <= FSM_STATE_WAIT_STEADY_STATE;
							fsm_wait_counter <= (others => '0');
							
						end if;
						
						
						
					when FSM_STATE_WAIT_STEADY_STATE =>
					
						integrator_clk_output_enable_register <= '0';
						
						if fsm_wait_counter = unsigned(number_of_cycles_integration) then
							-- We are done waiting. Start integrating:
							FSM_state <= FSM_STATE_INTEGRATING;
							fsm_wait_counter <= (others => '0');
						else
							-- Keep waiting
							fsm_wait_counter <= fsm_wait_counter + 1;
							
						end if;
						
					when FSM_STATE_INTEGRATING =>
						
						if fsm_wait_counter = unsigned(number_of_cycles_integration) then
							fsm_wait_counter <= (others => '0');
							-- The integration is finished. save the results:
							-- Note that this USED TO include a division by 2^15, which should cancel the gain
							-- due to the cosine and sine amplitude
							real_accumulator_register <= real_accumulator_wide;--real_accumulator_wide(48-1 downto 15);
							imag_accumulator_register <= imag_accumulator_wide;--imag_accumulator_wide(48-1 downto 15);
							integrator_clk_output_enable_register <= '1';
							
							
							-- Go to the appropriate state
							if modulation_frequency_index < unsigned(number_of_frequencies) then
								-- We are not done. increment the frequency and wait for steady state:
								modulation_frequency_index <= modulation_frequency_index + 1;
								current_modulation_frequency <= std_logic_vector(unsigned(current_modulation_frequency) + unsigned(modulation_frequency_step));
								FSM_state <= FSM_STATE_WAIT_STEADY_STATE;
								
							else
								-- We are done.  Go back to idling.
								modulation_frequency_index <= (others => '0');
								FSM_state <= FSM_STATE_IDLE;
							end if;
						else
							-- Keep integrating
							fsm_wait_counter <= fsm_wait_counter + 1;
						end if;
						

						
					when others =>
						FSM_state <= FSM_STATE_IDLE;
					
				end case;
				
			end if;
		end if;
	end process;
	
	
	-- This process drives the outputs that only depend on the FSM state:
	-- Drives macc_clear, disable_modulation_output, debug_current_state
	process (clk)
	begin
		if rising_edge(clk) then
			if rst = '1' then
				debug_current_state <= b"0000_0001";
				macc_clear <= '1';
				disable_modulation_output <= '1';
				
			else
				case FSM_state is
				
				
					when FSM_STATE_IDLE =>
						debug_current_state <= b"0000_0001";
						macc_clear <= '1';
						disable_modulation_output <= '1';
						
						
					when FSM_STATE_WAIT_STEADY_STATE =>
					
						debug_current_state <= b"0000_0010";
						macc_clear <= '1';
						disable_modulation_output <= '0';

					when FSM_STATE_INTEGRATING =>
					
						debug_current_state <= b"0000_0100";
						macc_clear <= '0';
						disable_modulation_output <= '0';
						
					when others =>
						debug_current_state <= b"0000_0001";
						macc_clear <= '1';
						disable_modulation_output <= '1';
					
				end case;
				
			end if;
		end if;
	end process;
	
	
	
	integrator_real_output <= real_accumulator_register;
	integrator_imag_output <= imag_accumulator_register;
	integrator_clk_output_enable <= integrator_clk_output_enable_register;
	
	
end Behavioral;

