library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


entity mux_phase_to_logger is
Generic (
    INPUT_WIDTH     : integer := 64;
    TIMESTAMP_WIDTH : integer := 64;
    OUTPUT_WIDTH    : integer := 32 -- data logger width, this module is intended for OUTPUT_WIDTH=INPUT_WIDTH/2
);
port (
    clk            : in  std_logic;
    
    -- unwrapped and integrated-and-dumped phases,
    -- clk enable rate has to be lower than clk/(12+1),
    -- phiX has to stay valid the whole serialization duration after a strobe on clk_enable_in
    clk_enable_in  : in  std_logic;
    phi1           : in  std_logic_vector(INPUT_WIDTH-1 downto 0);
    phi2           : in  std_logic_vector(INPUT_WIDTH-1 downto 0);
    phi3           : in  std_logic_vector(INPUT_WIDTH-1 downto 0);
    phi4           : in  std_logic_vector(INPUT_WIDTH-1 downto 0);
    
    -- serialized output to data logger, 12 output words per clk_enable_in strobe
    clk_enable_out : out std_logic;
    new_data_chunk : out std_logic;
    data_out       : out std_logic_vector(OUTPUT_WIDTH-1 downto 0)
    );
end entity;

architecture Behavioral of mux_phase_to_logger is
    constant SYNC_BYTES : std_logic_vector(INPUT_WIDTH-1 downto 0) := x"ABCD1234_0A0B0C0D";
    signal timestamp_counter : unsigned(TIMESTAMP_WIDTH-1 downto 0) := (others => '0');
    signal timestamp_counter_reg : unsigned(TIMESTAMP_WIDTH-1 downto 0) := (others => '0');

    type state_type is (STATE_IDLE, STATE_HEADER_LSB, STATE_HEADER_MSB,
                        STATE_TIMESTAMP_LSB, STATE_TIMESTAMP_MSB,
                        STATE_PHI1_LSB, STATE_PHI2_LSB, STATE_PHI3_LSB, STATE_PHI4_LSB,
                        STATE_PHI1_MSB, STATE_PHI2_MSB, STATE_PHI3_MSB, STATE_PHI4_MSB);
    signal FSM_state      : state_type := STATE_IDLE;


    signal new_data_chunk_int, clk_enable_int : std_logic := '0';
    signal data_int       : std_logic_vector(OUTPUT_WIDTH-1 downto 0) := (others => '0');

begin

    -- free-running timestamp counter process
    process( clk )
    begin
        if rising_edge(clk) then
            timestamp_counter <= timestamp_counter + 1;
        end if;
    end process;



    -- FSM process, just goes deterministically through
    -- the sequence of all states when triggered by clk_enable_in,
    -- ie the state variable is just a counter
    process (clk)
    begin
        if rising_edge(clk) then
            clk_enable_int <= '0';
            new_data_chunk_int <= '0';

            case FSM_state is
                when STATE_IDLE =>
                    if clk_enable_in = '1' then
                        FSM_state <= STATE_HEADER_LSB;
                        timestamp_counter_reg <= timestamp_counter;
                    end if;
                when STATE_HEADER_LSB =>
                    new_data_chunk_int <= '1';
                    clk_enable_int <= '1';
                    data_int <= SYNC_BYTES(OUTPUT_WIDTH-1 downto 0);
                    FSM_state <= STATE_HEADER_MSB;
                when STATE_HEADER_MSB =>
                    clk_enable_int <= '1';
                    data_int <= SYNC_BYTES(OUTPUT_WIDTH-1+OUTPUT_WIDTH downto OUTPUT_WIDTH);
                    FSM_state <= STATE_TIMESTAMP_LSB;
                when STATE_TIMESTAMP_LSB =>
                    clk_enable_int <= '1';
                    data_int <= std_logic_vector(timestamp_counter_reg(OUTPUT_WIDTH-1 downto 0));
                    FSM_state <= STATE_TIMESTAMP_MSB;
                when STATE_TIMESTAMP_MSB =>
                    clk_enable_int <= '1';
                    data_int <= std_logic_vector(timestamp_counter_reg(OUTPUT_WIDTH-1+OUTPUT_WIDTH downto OUTPUT_WIDTH));
                    FSM_state <= STATE_PHI1_LSB;
                when STATE_PHI1_LSB =>
                    clk_enable_int <= '1';
                    data_int <= phi1(OUTPUT_WIDTH-1 downto 0);
                    FSM_state <= STATE_PHI1_MSB;
                when STATE_PHI1_MSB =>
                    clk_enable_int <= '1';
                    data_int <= phi1(OUTPUT_WIDTH-1+OUTPUT_WIDTH downto OUTPUT_WIDTH);
                    FSM_state <= STATE_PHI2_LSB;
                when STATE_PHI2_LSB =>
                    clk_enable_int <= '1';
                    data_int <= phi2(OUTPUT_WIDTH-1 downto 0);
                    FSM_state <= STATE_PHI2_MSB;
                when STATE_PHI2_MSB =>
                    clk_enable_int <= '1';
                    data_int <= phi2(OUTPUT_WIDTH-1+OUTPUT_WIDTH downto OUTPUT_WIDTH);
                    FSM_state <= STATE_PHI3_LSB;
                when STATE_PHI3_LSB =>
                    clk_enable_int <= '1';
                    data_int <= phi3(OUTPUT_WIDTH-1 downto 0);
                    FSM_state <= STATE_PHI3_MSB;
                when STATE_PHI3_MSB =>
                    clk_enable_int <= '1';
                    data_int <= phi3(OUTPUT_WIDTH-1+OUTPUT_WIDTH downto OUTPUT_WIDTH);
                    FSM_state <= STATE_PHI4_LSB;
                when STATE_PHI4_LSB =>
                    clk_enable_int <= '1';
                    data_int <= phi4(OUTPUT_WIDTH-1 downto 0);
                    FSM_state <= STATE_PHI4_MSB;
                when STATE_PHI4_MSB =>
                    clk_enable_int <= '1';
                    data_int <= phi4(OUTPUT_WIDTH-1+OUTPUT_WIDTH downto OUTPUT_WIDTH);
                    FSM_state <= STATE_IDLE;
  
                when others =>
                FSM_state <= STATE_IDLE;
            end case;
        end if;
    end process;

    new_data_chunk <= new_data_chunk_int;
    clk_enable_out <= clk_enable_int;
    data_out       <= data_int;

end;
