library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

entity AD9912_DDS_controller_tb is
end AD9912_DDS_controller_tb;

architecture behavior of AD9912_DDS_controller_tb is

    -- AD9912_DDS_controller signals
    -- Generics as constants
    
    -- Inputs
    signal clk                  : std_logic                       := '0';
    signal freq_word            : std_logic_vector(48-1 downto 0) := (others => '0');
    signal freq_word_delay_only : std_logic_vector(48-1 downto 0) := (others => '0');
    signal update_freq          : std_logic                       := '0';
    signal register_write       : std_logic                       := '0';
    signal register_address     : std_logic_vector(13-1 downto 0) := (others => '0');
    signal register_value       : std_logic_vector( 8-1 downto 0) := (others => '0');
    signal timestamp_in         : std_logic_vector(64-1 downto 0) := (others => '0');
    signal clk_div              : std_logic_vector(16-1 downto 0) := std_logic_vector(to_unsigned(10, 16));
    -- Outputs
    signal current_dds_freq         : std_logic_vector(48-1 downto 0);
    signal timestamp_at_freq_update : std_logic_vector(64-1 downto 0);
    signal SPI_SCLK                 : std_logic;
    signal SPI_SDIO                 : std_logic;
    signal SPI_CSB                  : std_logic;

    -- Clock period definition
    constant clk_period : time := 5 ns;
begin

    -- Unit under test
    AD9912_DDS_controller_inst : entity work.AD9912_DDS_controller
    port map (
        clk                      => clk,
        freq_word                => freq_word,
        freq_word_delay_only     => freq_word_delay_only,
        update_freq              => update_freq,
        register_write           => register_write,
        register_address         => register_address,
        register_value           => register_value,
        current_dds_freq         => current_dds_freq,
        timestamp_in             => timestamp_in,
        timestamp_at_freq_update => timestamp_at_freq_update,
        clk_div                  => clk_div,
        SPI_SCLK                 => SPI_SCLK,
        SPI_SDIO                 => SPI_SDIO,
        SPI_CSB                  => SPI_CSB
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
        wait for clk_period*1000;
        wait until rising_edge(clk);
        -- send a few config values:
        wait until rising_edge(clk);
            register_address <= "1100000001111";
            register_value <= x"FF";
            register_write <= '1';
        wait until rising_edge(clk);
            register_write <= '0';

        wait for clk_period*1000;
        wait until rising_edge(clk);
            register_address <= "1111111111111";
            register_value <= x"00";
            register_write <= '1';
        wait until rising_edge(clk);
            register_write <= '0';

        -- send a few frequency words:
        for I in 0 to 10 loop
            wait until rising_edge(clk);
                update_freq <= '1';
                freq_word <= std_logic_vector(signed(freq_word) + 1);
            wait until rising_edge(clk);
                update_freq <= '0';
            wait for clk_period*1000;
        end loop;


        -- now try pushing the SPI clock rate to what we'll actually be using
        -- the chip has 50 MHz as its maximum clock, but our clock rate is 125 MHz,
        -- so we can only do 125 MHz/4 = 31.25 MHz since we are limited to even number of cycles per clock periods
        -- with the current implementation
        wait for clk_period*1000;
        wait until rising_edge(clk);
            clk_div <= std_logic_vector(to_unsigned(4, 16));
        wait for clk_period*100;

        -- send a few frequency words:
        for I in 0 to 10 loop
            wait until rising_edge(clk);
                update_freq <= '1';
                freq_word <= std_logic_vector(signed(freq_word) + 1);
            wait until rising_edge(clk);
                update_freq <= '0';
            wait for clk_period*1000;
        end loop;

        wait;

    end process;
    
end;
