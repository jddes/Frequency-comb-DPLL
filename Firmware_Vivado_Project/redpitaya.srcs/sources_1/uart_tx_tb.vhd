library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity uart_tx_tb is
end uart_tx_tb;

architecture behavior of uart_tx_tb is

    -- uart_tx signals
    -- Generics as constants
    constant CLK_DIVIDER   : integer := 10;
    constant COUNTER_WIDTH : integer := 32;
    constant BITS_PER_WORD : integer := 8;
    type two_dim_array is array (natural range <>, natural range <>) of std_logic;
    -- Inputs
    signal clk             : std_logic                                  := '0';
    signal send_clk_enable : std_logic                                  := '0';
    signal data_to_send    : std_logic_vector(BITS_PER_WORD-1 downto 0) := (others => '0');
    -- Outputs
    signal serial_out : std_logic;

    -- testbench signals
    signal reg_rx    : std_logic_vector(BITS_PER_WORD-1 downto 0) := (others => '0');
    signal clk_counter : unsigned(32-1 downto 0) := (others => '0');
    signal bits_counter : unsigned(32-1 downto 0) := (others => '0');
    signal counter_enabled, clk_enable_rx, serial_out_last : std_logic := '0';
    signal rx_sample_delay_line : std_logic_vector(CLK_DIVIDER/2-1 downto 0) := (others => '0'); -- this is used to line up our sampling times closer to the center of the bits

    signal error_flag, valid_flag, rx_sample_time, rx_sample_time_last : std_logic := '0';

    -- Clock period definition
    constant clk_period : time := 5 ns;
begin

    -- Unit under test
    uart_tx_inst : entity work.uart_tx
    generic map (
        CLK_DIVIDER   => CLK_DIVIDER,
        COUNTER_WIDTH => COUNTER_WIDTH,
        BITS_PER_WORD => BITS_PER_WORD
    ) port map (
        clk             => clk,
        send_clk_enable => send_clk_enable,
        data_to_send    => data_to_send,
        serial_out      => serial_out
    );

    -- Clock process definition for "clk"
    process
    begin
        clk <= '0';
        wait for clk_period/2;
        clk <= '1';
        wait for clk_period/2;
    end process;

    
    process( clk )
    begin
        if rising_edge(clk) then

        end if;
    end process;


    -- simple uart rx, just for testing the tx:
    process( clk )
    begin
        if rising_edge(clk) then
            serial_out_last <= serial_out;
            clk_enable_rx <= '0';
            if counter_enabled = '1' then
                if clk_counter < CLK_DIVIDER-1 then
                    clk_counter <= clk_counter + 1;
                else
                    clk_counter <= (others => '0');
                    clk_enable_rx <= '1';
                end if;

            else
                clk_counter <= (others => '0');

                -- detect start condition:
                if serial_out = '0' and serial_out_last = '1' then
                    bits_counter <= (others => '0');
                    counter_enabled <= '1';
                end if;

            end if;

            rx_sample_delay_line <= rx_sample_delay_line(rx_sample_delay_line'left-1 downto 0) & clk_enable_rx;
            if rx_sample_time = '1' then
                reg_rx <= serial_out & reg_rx(reg_rx'left downto 1);
            end if;

            -- turn off counter after receiving BITS_PER_WORD bits
            rx_sample_time_last <= rx_sample_time;
            if rx_sample_time_last = '1' then
                if bits_counter < BITS_PER_WORD-1 then
                    bits_counter <= bits_counter + 1;
                else
                    -- we are done
                    bits_counter <= (others => '0');
                    counter_enabled <= '0';
                    -- compare received and transmitted value to check for errors:
                    if reg_rx /= data_to_send then
                        error_flag <= '1';
                        valid_flag <= '0';
                    else
                        error_flag <= '0';
                        valid_flag <= '1';
                    end if;
                end if;
            end if;
        end if;
    end process;
    rx_sample_time <= rx_sample_delay_line(rx_sample_delay_line'left);

    -- Stimulus process
    process
    begin
        wait for clk_period*100;

        for I in 0 to 255 loop
            wait until rising_edge(clk);
                send_clk_enable <= '1';
                data_to_send <= std_logic_vector(to_unsigned(I, data_to_send'length));
            wait until rising_edge(clk);
                send_clk_enable <= '0';
            wait for clk_period*(CLK_DIVIDER+BITS_PER_WORD + 1000);
        end loop;

        wait;

    end process;
    
end;
