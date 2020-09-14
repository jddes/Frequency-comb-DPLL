library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- Used to make sure that we always a valid clock
-- Receives the user desire to use internal or external clock,
-- and only uses the external clock if the user requests it
-- AND there is a good clock present.
-- Also automatically switches back to internal clock mode
-- if loss of the external clock is detected
--
-- clk_int_or_ext_desired = '1' means internal clock
-- clk_int_or_ext_desired = '0' means external clock

entity clk_manager is
Generic (
    COUNTER_WIDTH : integer := 16
);
port (
    clk_stable             : in  std_logic;
    clk_ext                : in  std_logic;
    
    clk_int_or_ext_desired : in  std_logic;

    -- parameters for clk presence detection
    minimum_cycles_of_clk_under_test : in  std_logic_vector(COUNTER_WIDTH-1 downto 0);
    cycles_of_clk_stable             : in  std_logic_vector(COUNTER_WIDTH-1 downto 0);
    
    clk_ext_good           : out std_logic;
    clk_int_or_ext_actual  : out std_logic

    );
end entity;

architecture Behavioral of clk_manager is

    type state_type is (STATE_INT, STATE_EXT, STATE_EXT_DESIRED_BUT_INT_ACTUAL);
    signal FSM_state : state_type := STATE_INT;

    signal clk_good   : std_logic := '0';
    signal clk_actual : std_logic := '0';

    -- CDC registers for clk_int_or_ext_desired:
    signal clk_int_or_ext_desired_reg1, clk_int_or_ext_desired_reg2 : std_logic := '0';

    attribute ASYNC_REG : string;
    attribute ASYNC_REG of clk_int_or_ext_desired_reg1 : signal is "TRUE";
    attribute ASYNC_REG of clk_int_or_ext_desired_reg2 : signal is "TRUE";

begin

    process(clk_stable)
    begin
        if rising_edge(clk_stable) then
            clk_int_or_ext_desired_reg1 <= clk_int_or_ext_desired;
            clk_int_or_ext_desired_reg2 <= clk_int_or_ext_desired_reg1;
        end if;
    end process;

    clock_presence_detector_inst : entity work.clock_presence_detector
    generic map (
        COUNTER_WIDTH => COUNTER_WIDTH
    ) port map (
        clk_stable                       => clk_stable,
        clk_under_test                   => clk_ext,
        minimum_cycles_of_clk_under_test => minimum_cycles_of_clk_under_test,
        cycles_of_clk_stable             => cycles_of_clk_stable,
        clk_good                         => clk_good
    );

    -- FSM process
    -- an FSM is pretty overkill here, but writing it this way makes it easy to follow all the decisions
    process (clk_stable)
    begin
        if rising_edge(clk_stable) then
            case FSM_state is
                when STATE_INT =>
                    clk_actual <= '1'; -- internal clock
                    if clk_int_or_ext_desired_reg2 = '0' then
                        -- ext clk is requested, decide what to do based on the clk_good signal:
                        if clk_good = '1' then
                            FSM_state <= STATE_EXT;
                        else
                            FSM_state <= STATE_EXT_DESIRED_BUT_INT_ACTUAL;
                        end if;
                    end if;

                when STATE_EXT =>
                    clk_actual <= '0'; -- external clock
                    if clk_good = '0' then
                        FSM_state <= STATE_EXT_DESIRED_BUT_INT_ACTUAL;
                    end if;
                    if clk_int_or_ext_desired_reg2 = '1' then
                        FSM_state <= STATE_INT;
                    end if;

                when STATE_EXT_DESIRED_BUT_INT_ACTUAL =>
                    clk_actual <= '1'; -- internal clock
                    if clk_int_or_ext_desired_reg2 = '1' then
                        FSM_state <= STATE_INT;
                    end if;
                    if clk_good = '1' then
                        FSM_state <= STATE_EXT;
                    end if;
                when others =>
                    FSM_state <= STATE_INT;
            end case;
        end if;
    end process;

    clk_ext_good          <= clk_good;
    clk_int_or_ext_actual <= clk_actual;
end;
