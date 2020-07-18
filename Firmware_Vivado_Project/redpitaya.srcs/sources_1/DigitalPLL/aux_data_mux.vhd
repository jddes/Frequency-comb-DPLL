library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

-- Adds a small header composed of a single 64-bits free-running counter value
-- to data going to the logger
-- 1 cycle latency when in passthrough mode (FSM_LOGGING)

entity aux_data_mux is
	Generic (
		OUTPUT_WIDTH : integer := 16 -- can't really change this without changing the implementation inside
	); Port (
		clk              : in  std_logic;
		write_mode       : in  std_logic;
		clk_enable_in    : in  std_logic;
		sync_in          : in  std_logic; -- used to ensure that we start logging on the right value of a struct, for example always start logging IQ data at I
		data_in          : in  std_logic_vector(OUTPUT_WIDTH-1 downto 0);

		clk_enable_out   : out std_logic;
		data_out         : out std_logic_vector(OUTPUT_WIDTH-1 downto 0)
	);
end aux_data_mux;

architecture Behavioral of aux_data_mux is
	signal write_mode_last   : std_logic := '0';
	signal timestamp_counter : unsigned(64-1 downto 0) := (others => '0');
	signal timestamp_reg     :   std_logic_vector(64-1 downto 0) := (others => '0');
	
	type FSM_state_type is (FSM_IDLE, FSM_TS1, FSM_TS2, FSM_TS3, FSM_TS4, FSM_WAIT_FOR_SYNC, FSM_LOGGING);
	signal fsm_state : FSM_state_type;
	
	signal clk_enable_int : std_logic := '0';
	signal data_int       : std_logic_vector(data_out'length-1 downto 0) := (others => '0');
begin

	-- counter and one register to save said counter on rising edges of write_mode
	process(clk)
	begin
	    if rising_edge(clk) then
	        timestamp_counter <= timestamp_counter + 1;

	        -- save timestamp on start of write mode
			write_mode_last <= write_mode;
	        if write_mode='1' and write_mode_last='0' then
	        	timestamp_reg <= std_logic_vector(timestamp_counter);
	        end if;
	    end if;
	end process;

	process (clk)
	begin
		if rising_edge(clk) then
			clk_enable_int <= '0';
		
			case fsm_state is
				when FSM_IDLE =>
					clk_enable_int <= '0';
					data_int <= (others => '0');
					if write_mode = '1' then
						fsm_state <= FSM_TS1;
					end if;
					
				when FSM_TS1 =>
					clk_enable_int <= '1';
                    data_int <= std_logic_vector(timestamp_reg(OUTPUT_WIDTH-1 downto 0));
                    fsm_state <= FSM_TS2;
				when FSM_TS2 =>
					clk_enable_int <= '1';
                    data_int <= std_logic_vector(timestamp_reg(OUTPUT_WIDTH-1+OUTPUT_WIDTH*1 downto OUTPUT_WIDTH*1));
                    fsm_state <= FSM_TS3;
				when FSM_TS3 =>
					clk_enable_int <= '1';
                    data_int <= std_logic_vector(timestamp_reg(OUTPUT_WIDTH-1+OUTPUT_WIDTH*2 downto OUTPUT_WIDTH*2));
                    fsm_state <= FSM_TS4;
				when FSM_TS4 =>
					clk_enable_int <= '1';
                    data_int <= std_logic_vector(timestamp_reg(OUTPUT_WIDTH-1+OUTPUT_WIDTH*3 downto OUTPUT_WIDTH*3));
                    fsm_state <= FSM_WAIT_FOR_SYNC;
				when FSM_WAIT_FOR_SYNC =>
                    if sync_in='1' then
						clk_enable_int <= clk_enable_in;
						data_int       <= data_in;
						fsm_state <= FSM_LOGGING;
                    else
						clk_enable_int <= '0';
						data_int       <= (others => '0');
                    end if;
                when FSM_LOGGING =>
                    -- stay here until the logging stops (handled outside of the case statement to cover all cases)
                    -- module is now just a passthrough with 1 register stage
					clk_enable_int <= clk_enable_in;
					data_int       <= data_in;

				when others =>
					fsm_state <= FSM_IDLE;
			end case;

			-- this will force the state back to idle regardless of the current state
			if write_mode = '0' then
				fsm_state <= FSM_IDLE;
			end if;
		end if;
	end process;

	clk_enable_out <= clk_enable_int;
	data_out <= data_int;

end Behavioral;

