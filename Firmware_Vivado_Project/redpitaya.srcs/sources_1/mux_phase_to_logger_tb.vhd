library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

entity mux_phase_to_logger_tb is
end mux_phase_to_logger_tb;

architecture behavior of mux_phase_to_logger_tb is

    -- mux_phase_to_logger signals
    -- Generics as constants
    constant INPUT_WIDTH   : integer := 64;
    constant COUNTER_WIDTH : integer := 64;
    constant OUTPUT_WIDTH  : integer := 32;
    type two_dim_array is array (natural range <>, natural range <>) of std_logic;
    -- Inputs
    signal clk           : std_logic                                := '0';
    signal clk_enable_in : std_logic                                := '0';
    signal phi1          : std_logic_vector(INPUT_WIDTH-1 downto 0) := (others => '0');
    signal phi2          : std_logic_vector(INPUT_WIDTH-1 downto 0) := (others => '0');
    signal phi3          : std_logic_vector(INPUT_WIDTH-1 downto 0) := (others => '0');
    signal phi4          : std_logic_vector(INPUT_WIDTH-1 downto 0) := (others => '0');
    -- Outputs
    signal clk_enable_out : std_logic;
    signal new_data_chunk : std_logic;
    signal data_out       : std_logic_vector(OUTPUT_WIDTH-1 downto 0);

    -- Clock period definition
    constant clk_period : time := 5 ns;
begin

    -- Unit under test
    mux_phase_to_logger_inst : entity work.mux_phase_to_logger
    generic map (
        INPUT_WIDTH   => INPUT_WIDTH,
        COUNTER_WIDTH => COUNTER_WIDTH,
        OUTPUT_WIDTH  => OUTPUT_WIDTH
    ) port map (
        clk            => clk,
        clk_enable_in  => clk_enable_in,
        phi1           => phi1,
        phi2           => phi2,
        phi3           => phi3,
        phi4           => phi4,
        clk_enable_out => clk_enable_out,
        new_data_chunk => new_data_chunk,
        data_out       => data_out
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
            clk_enable_in <= '1';
            phi1 <= x"1112131415161718";
            phi2 <= x"2122232425262728";
            phi3 <= x"3132333435363738";
            phi4 <= x"4142434445464748";
        wait until rising_edge(clk);
            clk_enable_in <= '0';
        wait until rising_edge(clk);
        wait for clk_period*30;
            phi1 <= (others => '0');
            phi2 <= (others => '0');
            phi3 <= (others => '0');
            phi4 <= (others => '0');

    end process;
    
end;
