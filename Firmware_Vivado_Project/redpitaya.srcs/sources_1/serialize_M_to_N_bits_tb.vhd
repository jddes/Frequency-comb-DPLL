library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

entity serialize_M_to_N_bits_tb is
end serialize_M_to_N_bits_tb;

architecture behavior of serialize_M_to_N_bits_tb is

    -- serialize_M_to_N_bits signals
    -- Generics as constants
    constant INPUT_WIDTH  : integer := 48;
    constant OUTPUT_WIDTH : integer := 16;
    type two_dim_array is array (natural range <>, natural range <>) of std_logic;
    -- Inputs
    signal clk              : std_logic                                := '0';
    signal input_clk_enable : std_logic                                := '0';
    signal data_in          : std_logic_vector(INPUT_WIDTH-1 downto 0) := (others => '0');
    -- Outputs
    signal output_clk_enable : std_logic;
    signal output_sync       : std_logic;
    signal data_out          : std_logic_vector(OUTPUT_WIDTH-1 downto 0);

    -- Clock period definition
    constant clk_period : time := 5 ns;
begin

    -- Unit under test
    serialize_M_to_N_bits_inst : entity work.serialize_M_to_N_bits
    generic map (
        INPUT_WIDTH  => INPUT_WIDTH,
        OUTPUT_WIDTH => OUTPUT_WIDTH
    ) port map (
        clk               => clk,
        input_clk_enable  => input_clk_enable,
        data_in           => data_in,
        output_clk_enable => output_clk_enable,
        output_sync       => output_sync,
        data_out          => data_out
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
            data_in <= x"AAAABBBBCCCC";
            input_clk_enable <= '1';
        wait until rising_edge(clk);
            input_clk_enable <= '0';
        wait for clk_period*100;


        for I in 0 to 1023 loop
        wait until rising_edge(clk);
            data_in <= std_logic_vector(unsigned(data_in) + 1);
            input_clk_enable <= '1';
        wait until rising_edge(clk);
            input_clk_enable <= '0';
        wait for clk_period*10;
        end loop;

        wait;

    end process;
    
end;
