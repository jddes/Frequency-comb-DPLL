library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity spi_master_write_only_testbench is
end spi_master_write_only_testbench;

architecture behavior of spi_master_write_only_testbench is

    -- Inputs
    signal clk :    std_logic;
    signal data_input :    std_logic_vector(47 downto 0) := (others => '0');
    signal reg_address :    std_logic_vector(12 downto 0) := (others => '0');
    signal reg_size_in_bits :    std_logic_vector(5 downto 0) := (others => '0');
    signal send_reg :    std_logic := '0';
    signal clk_div :    std_logic_vector(15 downto 0) := std_logic_vector(to_unsigned(10, 16));
    
    -- Outputs
    signal core_ready :   std_logic;
    signal spi_sclk :   std_logic;
    signal spi_sdio :   std_logic;
    signal spi_csb :   std_logic;
    
    -- Clock period definition
    constant clk_period : time := 5 ns;
begin

    -- Unit under test
    spi_master_write_only_inst : entity work.spi_master_write_only
    port map (
        clk => clk,
        data_input => data_input,
        reg_address => reg_address,
        reg_size_in_bits => reg_size_in_bits,
        send_reg => send_reg,
        clk_div => clk_div,
        core_ready => core_ready,
        spi_sclk => spi_sclk,
        spi_sdio => spi_sdio,
        spi_csb => spi_csb
    );

    -- Clock process definition for "clk"
    process
    begin
        clk <= '0';
        wait for clk_period/2;
        clk <= '1';
        wait for clk_period/2;
    end process;


    -- Stimulus process
    process
    begin
        wait for clk_period*10;
        wait until rising_edge(clk);
        wait for clk_period*100;
        wait until rising_edge(clk);
            send_reg <= '1';
            reg_size_in_bits <= std_logic_vector(to_unsigned(32, reg_size_in_bits'length));
            data_input <= b"00000000_00000000_11111111_00001111_00110011_01010101";
        --wait until rising_edge(clk);
        --    send_reg <= '0';
        wait for clk_period*1003;
        wait until rising_edge(clk);
            send_reg <= '0';
        wait for clk_period*1003;
        wait until rising_edge(clk);
            send_reg <= '1';
            reg_size_in_bits <= std_logic_vector(to_unsigned(32, reg_size_in_bits'length));
            data_input <= b"00000000_00000000_11111111_00001111_00110011_01010101";
        wait for clk_period*1003;
        wait until rising_edge(clk);
            send_reg <= '0';
        wait for clk_period*1003;
        wait until rising_edge(clk);
            send_reg <= '1';
            reg_size_in_bits <= std_logic_vector(to_unsigned(32, reg_size_in_bits'length));
            data_input <= b"00000000_00000000_11111111_00001111_00110011_01010101";
        wait for clk_period*1003;
        wait until rising_edge(clk);
            send_reg <= '0';
        wait;
    end process;
end;
