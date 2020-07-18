library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- pretty much the simplest uart tx possible,
-- fixed baud rate via a generic,
-- 1 start bit, 1 stop bit, no parity
--
-- the user is responsible for waiting until a transmission is done before triggering another one.
-- triggering another two fast will result in corrupted data.
entity uart_tx is
Generic (
    CLK_DIVIDER   : integer := 100; -- baud rate = input clk/CLK_DIVIDER
    COUNTER_WIDTH : integer := 32; -- must be at least ceil(log2(CLK_DIVIDER))
    BITS_PER_WORD : integer := 8
);
port (
    clk             : in  std_logic;
    
    send_clk_enable : in  std_logic; -- strobe on this starts transmission of the word in data_to_send
    data_to_send    : in  std_logic_vector(BITS_PER_WORD-1 downto 0);
    
    serial_out      : out std_logic

    );
end entity;

architecture Behavioral of uart_tx is
    constant START_BIT_VALUE : std_logic := '0';
    constant BUS_IDLE_VALUE : std_logic := '1';

    signal reg : std_logic_vector(BITS_PER_WORD+1-1 downto 0) := (others => '0');

    signal one_hot_counter : std_logic_vector(BITS_PER_WORD+1-1 downto 0) := (others => '0');
    signal clk_counter : unsigned(COUNTER_WIDTH-1 downto 0) := (others => '0');
    signal clk_enable : std_logic := '0';
    signal counter_enable : std_logic := '0';

    signal send_clk_enable_last : std_logic := '0';

begin

    -- clk counter process
    process( clk )
    begin
        if rising_edge(clk) then
            clk_enable <= '0';

            if counter_enable = '1' then
                if clk_counter < CLK_DIVIDER-1 then
                    clk_counter <= clk_counter + 1;
                else
                    clk_counter <= (others => '0');
                    clk_enable <= '1';
                end if;
            else
                clk_counter <= (others => '0');
            end if;
        end if;
    end process;


    -- just a shift register + a one-hot counter that decides when we are done with a word's transmission
    process (clk)
    begin
        if rising_edge(clk) then
            if clk_enable = '1' then
                reg <= BUS_IDLE_VALUE & reg(reg'left downto 1);
                one_hot_counter <= '1' & one_hot_counter(one_hot_counter'left downto 1);
                if one_hot_counter(0) = '1' then
                    counter_enable <= '0'; -- we are done
                end if;
            end if;

            send_clk_enable_last <= send_clk_enable; -- for rising edge detection to avoid double-sending a single value
            if send_clk_enable = '1' and send_clk_enable_last = '0' then
                reg <= data_to_send & START_BIT_VALUE;
                one_hot_counter <= (others => '0');
                one_hot_counter(one_hot_counter'left) <= '1';
                counter_enable <= '1';
            end if;

        end if;
    end process;

    serial_out <= reg(0);

end;
