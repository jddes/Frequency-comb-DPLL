----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    16:34:44 10/23/2013 
-- Design Name: 
-- Module Name:    system_identification_with_dither2 - Behavioral 
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
-- Modification 2/8/2014: Added "Dither" mode, where we output a single tone of constant amplitude continuously.
-- There is also an extra flag which can make us output a square wave instead of a tone.
-- Also changed the state machine to start identification as soon as trigger_input = '1' instead of requiring a rising edge on this signal.
-- Modification 3/14/2014: Added synchronization of the start and stop of the integration time to zero crossing of the reference phase, so that the 
-- 	overall integration period is always a multiple of periods.  This will drastically improve the accuracy of this module, especially at lower frequencies.
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

entity system_identification_with_dither2 is
	Generic (
		INPUT_WIDTH : integer := 10;
		FREQUENCY_WIDTH : integer := 48;
		MODULATION_OUTPUT_WIDTH : integer := 16	-- cannot be changed, linked to a coregen core
	);
	Port (
		rst                            : in  std_logic;
		clk                            : in  std_logic;
		
		
		-- Configuration of the system identification
		number_of_cycles_integration   : in  std_logic_vector(31 downto 0);
		first_modulation_frequency     : in  std_logic_vector(FREQUENCY_WIDTH-1 downto 0);
		modulation_frequency_step      : in  std_logic_vector(FREQUENCY_WIDTH-1 downto 0);
		number_of_frequencies          : in  std_logic_vector(15 downto 0);
		output_gain                    : in  std_logic_vector(17 downto 0);
		
		-- Mode control signals
		trigger_identification         : in  std_logic;    -- a '1' on this signal triggers the identification process
		trigger_dither                 : in  std_logic;    -- a '1' on this signal sets the module to 'dither' mode: output a constant frequency tone
		stop                           : in  std_logic;    -- a '1' on this signal stop the identification process
		bSquareWave                    : in  std_logic;    -- a '1' on this signal makes the output tone a square wave (intended to be used with the dither mode), while a '0' means that the output will be sinusoidal.
		
		-- System output (from the ADC, through any processing desired)
		data_in                        : in  std_logic_vector(INPUT_WIDTH-1 downto 0);
		
		-- Modulation output - goes to the DAC
		modulation_output              : out std_logic_vector(MODULATION_OUTPUT_WIDTH-1 downto 0);
		
		-- Results of the system identification
		integrator_real_output         : out std_logic_vector(64-1 downto 0);
		integrator_imag_output         : out std_logic_vector(64-1 downto 0);
		integrator_accumulated_samples : out std_logic_vector(32-1 downto 0);
		integrator_clk_output_enable   : out std_logic;
		
		-- Sync outputs, used for the dither functionality (another module takes care of lock-in detection of the dither signal and sends the results to the PC through a faster port than the one used by the VNA
		dither_sync_I                  : out std_logic;
		dither_sync_Q                  : out std_logic;
		debug_current_state            : out std_logic_vector(7 downto 0)

	);
end system_identification_with_dither2;

architecture Behavioral of system_identification_with_dither2 is

	--Coregen declarations
	-----------------------------------------------------------------------
	-- The Core which generates sine and cosine
    component LO_DDS
        port (
        aclk : IN STD_LOGIC;
        s_axis_phase_tvalid : IN STD_LOGIC;
        s_axis_phase_tdata : IN STD_LOGIC_VECTOR(47 DOWNTO 0);  -- phase increments
        m_axis_data_tvalid : OUT STD_LOGIC;
        m_axis_data_tdata : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);  -- cos and sine (16 bits signed each)
        m_axis_phase_tvalid : OUT STD_LOGIC;
        m_axis_phase_tdata : OUT STD_LOGIC_VECTOR(47 DOWNTO 0)  -- output phase
        );
	end component;
	signal lo_dds_m_axis_data_tdata : std_logic_vector(31 DOWNTO 0);
	
	--COMPONENT system_identification_macc
	--  PORT (
	--	 clk : IN STD_LOGIC;
	--	 ce : IN STD_LOGIC;
	--	 sclr : IN STD_LOGIC;
	--	 a : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
	--	 b : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
	--	 s : OUT STD_LOGIC_VECTOR(64-1 DOWNTO 0)
	--  );
	--END COMPONENT;
	
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
	signal disable_modulation_output                               : std_logic := '0';
	signal current_modulation_frequency                            : std_logic_vector(47 downto 0) := (others => '0');
	signal current_modulation_phase                                : std_logic_vector(47 downto 0) := (others => '0');
	signal last_modulation_phase                                   : std_logic_vector(47 downto 0) := (others => '0');
	signal modulation_phase_zerocrossing                           : std_logic := '0';
	signal modulation_phase_zerocrossing_srl                       : std_logic_vector(3 downto 0) := (others => '0');
	signal DDS_cosine                                              : std_logic_vector(16-1 downto 0);
	signal DDS_sine                                                : std_logic_vector(16-1 downto 0);
	
	-- Signals for the output:
	signal modulation_output_post_mult, modulation_output_internal : std_logic_vector(16-1 downto 0) := (others => '0');
	-- dither sync
	signal dither_sync_I_srl, dither_sync_Q_srl                    : std_logic_vector(3-1 downto 0) := (others => '0');
	signal dither_sync_I_internal, dither_sync_Q_internal          : std_logic := '0';
	
	-- Multiply-Accumulate signals 
	signal macc_clear                                              : std_logic := '1';
	signal real_accumulator_wide                                   : std_logic_vector(64-1 downto 0);
	signal imag_accumulator_wide                                   : std_logic_vector(64-1 downto 0);
	signal real_accumulator_register                               : std_logic_vector(64-1 downto 0);
	signal imag_accumulator_register                               : std_logic_vector(64-1 downto 0);
	signal samples_accumulator_register                            : std_logic_vector(32-1 downto 0);
	signal integrator_clk_output_enable_register                   : std_logic := '0';
	signal actual_integration_time_counter                         : unsigned(number_of_cycles_integration'range) := (others => '0');
	signal macc_clear_srl                                          : std_logic_vector(3-1 downto 0) := (others => '0');
	
	-- Signals for the FSM which controls the start and stop of the integration and the output of the tone:
	type FSM_state_type is (FSM_STATE_IDLE, FSM_STATE_DITHER, FSM_STATE_WAIT_STEADY_STATE, FSM_STATE_START_INTEGRATING, FSM_STATE_INTEGRATING);
	signal FSM_state : FSM_state_type;
	signal fsm_wait_counter : unsigned(number_of_cycles_integration'range) := (others => '0');
	signal trigger_identification_last : std_logic := '0';
	signal modulation_frequency_index : unsigned(number_of_frequencies'range) := (others => '0');
	
begin

	-- Compute cos() and sin()
	LO_DDS_inst : LO_DDS
	port map (
            aclk                    => clk,
            s_axis_phase_tvalid     => '1',
            s_axis_phase_tdata      => current_modulation_frequency,
            m_axis_data_tvalid      => open,
            m_axis_data_tdata       => lo_dds_m_axis_data_tdata,
            m_axis_phase_tvalid     => open,
            m_axis_phase_tdata      => current_modulation_phase
    );
    DDS_cosine  <= lo_dds_m_axis_data_tdata(15 downto 0);
    DDS_sine    <= lo_dds_m_axis_data_tdata(31 downto 16);
				
--	-- Multply the input signal by cos() and integrate:
	system_identification_macc_cos_inst : entity work.system_identification_macc_behav
	port map (
		clk => clk,
		synchronous_clear => macc_clear,
		a => data_in,
		b => DDS_cosine,
		s => real_accumulator_wide
	);

	system_identification_macc_sin_inst : entity work.system_identification_macc_behav
	port map (
		clk => clk,
		synchronous_clear => macc_clear,
		a => data_in,
		b => DDS_sine,
		-- we use these simple inputs to accurately measure the integration time
		--a => b"0000000000000001",
		--b => b"0000000000000001",
		s => imag_accumulator_wide
	);

	-- Legacy: we were using an IP core to perform the multiply-accumulate operation
--	system_identification_macc_cos_inst : system_identification_macc
--	  PORT MAP (
--		 clk => clk,
--		 ce => '1',
--		 sclr => macc_clear,
--		 a => data_in,
--		 b => DDS_cosine,
--		 s => real_accumulator_wide
--	  );
	  
--	-- Multply the input signal by sin() and integrate:
--	system_identification_macc_sin_inst : system_identification_macc
--	  PORT MAP (
--		 clk => clk,
--		 ce => '1',
--		 sclr => macc_clear,
--		 a => data_in,
--		 b => DDS_sine,
----		 a => b"0000000000000001",
----		 b => b"0000000000000001",
--		 s => imag_accumulator_wide
--	  );
	  
	  
	-- Multiply the cos() signal by the output gain and output:
	-- computes:
	-- modulation_output_post_mult = floor(DDS_cosine * output_gain / 2^15)
	-- software takes care of putting at most output_gain = 2^15
	output_mult_inst : system_identification_outputgain_mult
	  PORT MAP (
		 clk => clk,
		 a => DDS_cosine,
		 b => output_gain,
		 sclr => disable_modulation_output,
		 p => modulation_output_post_mult
	  );
	  
	-- This process counts the actual number of integrated samples, based on the macc_clear signal:
	process (clk)
	begin
		if rising_edge(clk) then
			macc_clear_srl <= (macc_clear_srl(macc_clear_srl'left-1 downto 0) & macc_clear);
			if macc_clear_srl(macc_clear_srl'left-1) = '1' then
				-- reset counter
				actual_integration_time_counter <= (others => '0');
			else
				-- count samples
				actual_integration_time_counter <= actual_integration_time_counter + 1;
			end if;
		end if;
	end process;

	-- Process which takes modulation_output_post_mult, and changes it to a square wave if bSquareWave = '1'
	-- Adds one cycle of delay to the block.
	process (clk)
	begin
		if rising_edge(clk) then
			if bSquareWave = '1' and disable_modulation_output = '0' then
				if signed(modulation_output_post_mult) < 0 then
					-- negative output
					modulation_output_internal <= std_logic_vector(resize(-signed(output_gain), 16));
				else
					-- positive output
					modulation_output_internal <= std_logic_vector(resize( signed(output_gain), 16));
				end if;
			else
				modulation_output_internal <= modulation_output_post_mult;
			end if;
		end if;
	end process;
	modulation_output <= modulation_output_internal;
	
	-- Process which drives the dither_sync_I and dither_sync_Q outputs:
	-- also aligns those outputs with the delayed modulation output due to the amplitude multiplier
	process (clk)
	begin
		if rising_edge(clk) then
			if signed(DDS_cosine) < 0 then
				-- negative output
				dither_sync_I_srl <= (dither_sync_I_srl(dither_sync_I_srl'left-1 downto 0) & '0');
			else
				-- positive output
				dither_sync_I_srl <= (dither_sync_I_srl(dither_sync_I_srl'left-1 downto 0) & '1');
			end if;
			
			if signed(DDS_sine) < 0 then
				-- negative output
				dither_sync_Q_srl <= (dither_sync_Q_srl(dither_sync_Q_srl'left-1 downto 0) & '0');
			else
				-- positive output
				dither_sync_Q_srl <= (dither_sync_Q_srl(dither_sync_Q_srl'left-1 downto 0) & '1');
			end if;
			
			dither_sync_I_internal <= dither_sync_I_srl(dither_sync_I_srl'left);
			dither_sync_Q_internal <= dither_sync_Q_srl(dither_sync_Q_srl'left);
		end if;
	end process;
	dither_sync_I <= dither_sync_I_internal;
	dither_sync_Q <= dither_sync_Q_internal;
	
	-- Process which detects the phase zero-crossings, to synchronize the integration period to a multiple of the modulation period
	process (clk)
	begin
		if rising_edge(clk) then
			last_modulation_phase <= current_modulation_phase;
			if signed(last_modulation_phase) < 0 and signed(current_modulation_phase) >= 0 then
				modulation_phase_zerocrossing <= '1';
			else
				modulation_phase_zerocrossing <= '0';
			end if;
			modulation_phase_zerocrossing_srl <= (modulation_phase_zerocrossing_srl(modulation_phase_zerocrossing_srl'left-1 downto 0) & modulation_phase_zerocrossing);
		end if;
	end process;

	
	  
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
						if trigger_identification = '1' then
							-- Wait for the system to reach steady state
							FSM_state <= FSM_STATE_WAIT_STEADY_STATE;
							fsm_wait_counter <= (others => '0');
							
						elsif trigger_dither = '1' then
							-- Enter the dither state until stop = '1'
							FSM_state <= FSM_STATE_DITHER;
						end if;
						
					when FSM_STATE_DITHER =>
						-- Most of the work is done by the second process (which simply involves setting disable_modulation_output <= '0')
						if stop = '1' then
							FSM_state <= FSM_STATE_IDLE;
						end if;
						
					when FSM_STATE_WAIT_STEADY_STATE =>
					
						integrator_clk_output_enable_register <= '0';
						
						if stop = '1' then
							FSM_state <= FSM_STATE_IDLE;
						else
						
							if fsm_wait_counter = unsigned(number_of_cycles_integration) then
								-- We are done waiting. Start integrating on a phase zero-crossing:
								if modulation_phase_zerocrossing = '1' then
									FSM_state <= FSM_STATE_START_INTEGRATING;
									fsm_wait_counter <= (others => '0');
								end if;
								
							else
								-- Keep waiting
								fsm_wait_counter <= fsm_wait_counter + 1;
								
							end if;
						end if;
						
					when FSM_STATE_START_INTEGRATING =>
						-- This state exists because the MACC that we are using has a 5 cycles delay between the de-assertion of sclr and the real start of its integration.
						-- by waiting 4 extra cycles because of this state, we are making sure that we integrate for exactly the desired period.
						if stop = '1' then
							FSM_state <= FSM_STATE_IDLE;
						else
							if fsm_wait_counter = to_unsigned(3, fsm_wait_counter'length) then
								FSM_state <= FSM_STATE_INTEGRATING;
								fsm_wait_counter <= (others => '0');
							else
								fsm_wait_counter <= fsm_wait_counter + 1;
							end if;
						end if;
						
					when FSM_STATE_INTEGRATING =>
						
						if stop = '1' then
							FSM_state <= FSM_STATE_IDLE;
						else
						
							if fsm_wait_counter = unsigned(number_of_cycles_integration) then
								if modulation_phase_zerocrossing_srl(modulation_phase_zerocrossing_srl'left) = '1' then
									fsm_wait_counter <= (others => '0');
									-- The integration is finished. save the results:
									-- Note that this USED TO include a division by 2^15, which should cancel the gain
									-- due to the cosine and sine amplitude
									real_accumulator_register <= real_accumulator_wide;--real_accumulator_wide(48-1 downto 15);
									imag_accumulator_register <= imag_accumulator_wide;--imag_accumulator_wide(48-1 downto 15);
									samples_accumulator_register <= std_logic_vector(actual_integration_time_counter);
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
								end if;
							else
								-- Keep integrating
								fsm_wait_counter <= fsm_wait_counter + 1;
							end if;
						
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
						
					when FSM_STATE_DITHER =>
						debug_current_state <= b"0000_1000";
						macc_clear <= '1';
						disable_modulation_output <= '0';
						
					when FSM_STATE_WAIT_STEADY_STATE =>
					
						debug_current_state <= b"0000_0010";
						macc_clear <= '1';
						disable_modulation_output <= '0';
						

					when FSM_STATE_START_INTEGRATING =>
					
						debug_current_state <= b"0000_0100";
						macc_clear <= '0';
						disable_modulation_output <= '0';

					when FSM_STATE_INTEGRATING =>
					
						debug_current_state <= b"0000_1000";
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
	integrator_accumulated_samples <= samples_accumulator_register;
	integrator_clk_output_enable <= integrator_clk_output_enable_register;
	
	
end Behavioral;

