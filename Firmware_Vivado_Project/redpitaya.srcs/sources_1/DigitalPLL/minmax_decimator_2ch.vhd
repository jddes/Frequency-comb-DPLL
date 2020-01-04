library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- decimates the input data by dumping the min and max over "period" clk cycles.
-- this version muxes two channels into one output stream,
-- along with a flag that indicates which of the two inputs is being output

entity minmax_decimator_2ch is
Generic (
    DATA_WIDTH         : integer := 16;
    SYNC_COUNTER_WIDTH : integer := 4
);
port (
    clk            : in  std_logic;
    clk_enable_in  : in  std_logic;
    data1          : in  std_logic_vector(DATA_WIDTH-1 downto 0);
    data2          : in  std_logic_vector(DATA_WIDTH-1 downto 0);
    period         : in  std_logic_vector(32-1 downto 0);

    clk_enable_out : out std_logic;
    counter_out    : out std_logic_vector(SYNC_COUNTER_WIDTH-1 downto 0); -- this can be used to ascertain that all output data has been read properly
    bFirstChannel  : out std_logic; -- equal to 1 when min_out and max_out correspond to the first channel
    min_out        : out std_logic_vector(DATA_WIDTH-1 downto 0);
    max_out        : out std_logic_vector(DATA_WIDTH-1 downto 0)

    );
end entity;

architecture Behavioral of minmax_decimator_2ch is

    signal counter : unsigned(32-1 downto 0) := (others => '0');
    signal dump_results : std_logic := '0';
    signal sync_counter : unsigned(SYNC_COUNTER_WIDTH-1 downto 0) := (others => '0');
    signal clk_enable_out_internal : std_logic := '0';


    signal min_out1, min_out2, min_out_internal : std_logic_vector(DATA_WIDTH-1 downto 0);
    signal max_out1, max_out2, max_out_internal : std_logic_vector(DATA_WIDTH-1 downto 0);
    signal bFirstChannel_internal : std_logic := '0';

    type state_type is (STATE_IDLE, STATE1, STATE2);
    signal FSM_state : state_type := STATE_IDLE;

begin

    -- decimation and output sync counters
    process(clk)
    begin
        if rising_edge(clk) then
            dump_results <= '0';
            if clk_enable_in = '1' then
                if counter < unsigned(period)-1 then
                    counter <= counter + 1;
                else
                    counter <= (others => '0');
                    dump_results <= '1';
                end if;
            end if;

            if dump_results = '1' then
                sync_counter <= sync_counter + 1;
            end if;
        end if;
    end process;

    running_minmax_inst : entity work.running_minmax_signed
    generic map (
        DATA_WIDTH => DATA_WIDTH
    ) port map (
        clk          => clk,
        clk_enable   => clk_enable_in,
        data         => data1,
        dump_results => dump_results,
        min_value    => min_out1,
        max_value    => max_out1
    );

    running_minmax_inst2 : entity work.running_minmax_signed
    generic map (
        DATA_WIDTH => DATA_WIDTH
    ) port map (
        clk          => clk,
        clk_enable   => clk_enable_in,
        data         => data2,
        dump_results => open, -- strictly synced to the first one, so this is not needed
        min_value    => min_out2,
        max_value    => max_out2
    );

    process(clk)
    begin
        if rising_edge(clk) then
            clk_enable_out_internal <= '0';
            bFirstChannel_internal  <= '0';

            if dump_results = '1' then
                FSM_state <= STATE1;
            else
                case FSM_state is
                    when STATE_IDLE =>
                    when STATE1 =>
                        clk_enable_out_internal <= '1';
                        bFirstChannel_internal <= '1';
                        min_out_internal <= min_out1;
                        max_out_internal <= max_out1;
                        FSM_state <= STATE2;
                    when STATE2 =>
                        clk_enable_out_internal <= '1';
                        min_out_internal <= min_out2;
                        max_out_internal <= max_out2;
                        FSM_state <= STATE_IDLE;
                    when others =>
                        FSM_state <= STATE_IDLE;
                end case;
            end if;
        end if;
    end process;

    counter_out    <= std_logic_vector(sync_counter);

    clk_enable_out <= clk_enable_out_internal;
    min_out <= min_out_internal;
    max_out <= max_out_internal;
end;
