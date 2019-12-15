library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- decimates the input data by dumping the min and max over "period" clk cycles.

entity minmax_decimator  is
Generic (
    DATA_WIDTH : integer := 16;
    SYNC_COUNTER_WIDTH : integer := 4
);
port (
    clk : in  std_logic;
    clk_enable_in : in  std_logic;
    data : in  std_logic_vector(DATA_WIDTH-1 downto 0);
    period : in  std_logic_vector(32-1 downto 0);

    clk_enable_out : out std_logic;
    counter_out    : out std_logic_vector(SYNC_COUNTER_WIDTH-1 downto 0); -- this can be used to acertain that all output data has been read properly
    min_out        : out std_logic_vector(DATA_WIDTH-1 downto 0);
    max_out        : out std_logic_vector(DATA_WIDTH-1 downto 0)

    );
end entity;

architecture Behavioral of minmax_decimator is

    signal counter : unsigned(32-1 downto 0) := (others => '0');
    signal dump_results : std_logic := '0';
    signal sync_counter : unsigned(SYNC_COUNTER_WIDTH-1 downto 0) := (others => '0');
    signal clk_enable_out_internal : std_logic := '0';
---- running_minmax signals
---- Generics as constants
--constant DATA_WIDTH : integer := 16;
---- Inputs
--signal clk          : std_logic                               := '0';
--signal clk_enable   : std_logic                               := '0';
--signal data         : std_logic_vector(DATA_WIDTH-1 downto 0) := (others => '0');
--signal dump_results : std_logic                               := '0';
---- Outputs
--signal min_value : std_logic_vector(DATA_WIDTH-1 downto 0);
--signal max_value : std_logic_vector(DATA_WIDTH-1 downto 0);
--

begin

    -- decimation and output sync counters
    process(clk)
    begin
        if rising_edge(clk) then
            dump_results <= '0';
            if clk_enable_in = '1' then
                if counter < unsigned(period) then
                    counter <= counter + 1;
                else
                    counter <= (others => '0');
                    dump_results <= '1';
                end if;
            end if;

            clk_enable_out_internal <= '0';
            if dump_results = '1' then
                sync_counter <= sync_counter + 1;
                clk_enable_out_internal <= '1'; -- this will be lined up with the update of *_value
            end if;
        end if;
    end process;

    running_minmax_inst : entity work.running_minmax
    generic map (
        DATA_WIDTH => DATA_WIDTH
    ) port map (
        clk          => clk,
        clk_enable   => clk_enable_in,
        data         => data,
        dump_results => dump_results,
        min_value    => min_out,
        max_value    => max_out
    );
    clk_enable_out <= clk_enable_out_internal;

    ---- FSM process example
    --process (clk)
    --begin
    --  if rising_edge(clk) then
    --      case FSM_state is
    --          when STATE_IDLE =>
    --          when others =>
    --              FSM_state <= STATE_IDLE;
    --      end case;
    --  end if;
    --end process;

end;
