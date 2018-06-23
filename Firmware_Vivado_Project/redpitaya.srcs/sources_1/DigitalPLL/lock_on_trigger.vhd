library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- When lock_on_next_trigger goes high, we start waiting for a rising edge on trigger_in.
-- when that happens, we wait for (delay_before_lock+5) clock cycles, then turn the lock on.
-- When lock_on_next_trigger goes low, we de-activate the lock from this mecanism
-- The actual lock is just this process' lock command ORed with bLock_manual, which is intended to simply be a register.
entity lock_on_trigger is
Generic (
    COUNTER_BITS    : integer := 32
);
port (
    clk : in  std_logic;

    trigger_in : in  std_logic;

    lock_on_next_trigger : in  std_logic;
    delay_before_lock    : in  std_logic_vector(COUNTER_BITS-1 downto 0);

    bLock_manual         : in  std_logic;

    lock_output          : out std_logic

    );
end entity;

architecture Behavioral of lock_on_trigger is

    type state_type is (STATE_IDLE, STATE_WAIT_FOR_TRIGGER, STATE_WAIT_FOR_DELAY, STATE_LOCKED);
    signal FSM_state      : state_type := STATE_IDLE;


    signal lock_on_next_trigger_d1 : std_logic := '0';
    signal wait_counter : unsigned(COUNTER_BITS-1 downto 0) := (others => '0');
    signal bCounterFinished : std_logic := '0';
    signal bCounterLoad : std_logic := '0';

    signal trigger_in_d1, trigger_in_d2 : std_logic := '0';

    signal bLockFromTriggeringFSM : std_logic := '0';
begin

    process (clk)
    begin
        if rising_edge(clk) then
            -- avoid metastability
            trigger_in_d1 <= trigger_in;
            trigger_in_d2 <= trigger_in_d1;
        end if;
    end process;

    -- FSM process
    process (clk)
    begin
        if rising_edge(clk) then
            -- default
            bCounterLoad <= '0';
            bLockFromTriggeringFSM <= '0';
            -- for rising edge detection:
            lock_on_next_trigger_d1 <= lock_on_next_trigger;


            case FSM_state is
                when STATE_IDLE =>
                    if lock_on_next_trigger = '1' and lock_on_next_trigger_d1 = '0' then    -- rising edge detection
                        FSM_state <= STATE_WAIT_FOR_TRIGGER;
                        bCounterLoad <= '1';
                    end if;


                when STATE_WAIT_FOR_TRIGGER =>
                    bCounterLoad <= '1';
                    if trigger_in_d2 = '1' then
                        FSM_state <= STATE_WAIT_FOR_DELAY;
                        
                    end if;
                    if lock_on_next_trigger = '0' then  -- allow escaping when user demands it
                        FSM_state <= STATE_IDLE;
                    end if;

                when STATE_WAIT_FOR_DELAY =>
                    if bCounterFinished = '1' then
                        FSM_state <= STATE_LOCKED;
                    end if;
                    if lock_on_next_trigger = '0' then  -- allow escaping when user demands it
                        FSM_state <= STATE_IDLE;
                    end if;

                when STATE_LOCKED =>
                    if lock_on_next_trigger = '0' then  -- allow escaping when user demands it
                        FSM_state <= STATE_IDLE;
                    end if;
                    bLockFromTriggeringFSM <= '1';

                when others =>
                    FSM_state <= STATE_IDLE;
            end case;
        end if;
    end process;

    
    -- wait counter
    process (clk)
    begin
        if rising_edge(clk) then
            if bCounterLoad = '1' then
                wait_counter <= unsigned(delay_before_lock);
                bCounterFinished <= '0';
            else
                if wait_counter > 0 then
                    wait_counter <= wait_counter - 1;
                    bCounterFinished <= '0';
                else
                    if bCounterFinished = '0' then
                        bCounterFinished <= '1';
                    end if;
                end if;
            end if;
        end if;
    end process;



    -- Combine the manual lock request with the FSM's command:
    lock_output <= bLock_manual or bLockFromTriggeringFSM;

end;
