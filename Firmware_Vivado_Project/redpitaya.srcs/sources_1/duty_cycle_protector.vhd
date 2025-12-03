library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- this checks to make sure that clk_under_test never stays high for more than
-- MAX_CYCLES_ON consecutively.
-- As long as clk_under_test never does, the module outputs clk_gated <= clk_under_test;
-- If clk_under_test does stay on for longer than MAX_CYCLES_ON,
-- the clk_gated will stay low for at least a pre-determined timeout duration,
-- 
entity duty_cycle_protector is
Generic (
    MAX_CYCLES_ON       : integer := 1000;
    TIMEOUT_CYCLES_LOG2 : integer := 18;
    COUNTER_WIDTH       : integer := 24
);
port (
    -- this must be a stable clock
    clk            : in  std_logic;

    clk_under_test : in  std_logic; -- this should be a much slower-toggling signal than clk
    clk_gated      : out std_logic

    );
end entity;

architecture Behavioral of duty_cycle_protector is

    -- CDC for clk_under_test:
    signal clk_under_test_d1 : std_logic := '0';
    signal clk_under_test_d2 : std_logic := '0';
    signal clk_under_test_d3 : std_logic := '0';

    type state_type is (STATE_OK, STATE_TIMED_OUT);
    signal FSM_state      : state_type := STATE_OK;

    signal count_high_cycles : unsigned(COUNTER_WIDTH-1 downto 0) := (others => '0');
    signal timeout_counter : unsigned(COUNTER_WIDTH-1 downto 0) := (others => '0');

    constant TIMEOUT_CYCLES : unsigned(COUNTER_WIDTH-1 downto 0) := shift_left(to_unsigned(1, COUNTER_WIDTH), TIMEOUT_CYCLES_LOG2);


    signal too_many_highs : std_logic := '0';
    signal timeout_done   : std_logic := '0';
    signal gate           : std_logic := '0';


    attribute MARK_DEBUG : string;
    attribute MARK_DEBUG of FSM_state         : signal is "TRUE";
    attribute MARK_DEBUG of count_high_cycles : signal is "TRUE";
    attribute MARK_DEBUG of timeout_counter   : signal is "TRUE";
    attribute MARK_DEBUG of too_many_highs    : signal is "TRUE";
    attribute MARK_DEBUG of timeout_done      : signal is "TRUE";
    attribute MARK_DEBUG of gate              : signal is "TRUE";

begin

    -- CDC for clk_under_test:
    process(clk)
    begin
        if rising_edge(clk) then
            clk_under_test_d1 <= clk_under_test;
            clk_under_test_d2 <= clk_under_test_d1;
            clk_under_test_d3 <= clk_under_test_d2;
        end if;
    end process;

    -- count_high_cycles process; also generates too_many_highs
    process( clk )
    begin
        if rising_edge(clk) then
            too_many_highs <= '0';

            if clk_under_test_d3 = '1' then
                if count_high_cycles < MAX_CYCLES_ON-1 then
                    count_high_cycles <= count_high_cycles + 1;
                else
                    too_many_highs <= '1';
                    count_high_cycles <= (others => '0');
                end if;
            else
                count_high_cycles <= (others => '0');
            end if;
        end if;
    end process;


    -- timeout_counter process; also generates timeout_done
    process( clk )
    begin
        if rising_edge(clk) then
            timeout_done <= '0';

            if too_many_highs = '1' then
                timeout_counter <= TIMEOUT_CYCLES;
            else
                if timeout_counter > 0 then
                    timeout_counter <= timeout_counter - 1;
                else
                    timeout_done <= '1';
                end if;
            end if;
        end if;
    end process;


    -- FSM process
    process (clk)
    begin
        if rising_edge(clk) then
            gate <= '1'; -- default

            case FSM_state is
                when STATE_OK =>
                    gate <= '1';
                    if too_many_highs = '1' then
                        FSM_state <= STATE_TIMED_OUT;
                    end if;
                when STATE_TIMED_OUT =>
                    gate <= '0';
                    if timeout_done = '1' then
                        FSM_state <= STATE_OK;
                    end if;
                when others =>
                    FSM_state <= STATE_OK;
            end case;
        end if;
    end process;


    clk_gated <= '1' when (clk_under_test = '1' and gate = '1') else
                 '0';
end;
