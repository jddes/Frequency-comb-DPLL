library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

entity quantize_with_accurate_integral_tb is
end quantize_with_accurate_integral_tb;

architecture behavior of quantize_with_accurate_integral_tb is

    -- quantize_with_accurate_integral signals
    -- Generics as constants
    constant INPUT_WIDTH  : integer := 16;
    constant OUTPUT_WIDTH : integer := 10;
    type two_dim_array is array (natural range <>, natural range <>) of std_logic;
    -- Inputs
    signal clk     : std_logic                                := '0';
    signal data_in : std_logic_vector(INPUT_WIDTH-1 downto 0) := (others => '0');
    -- Outputs
    signal data_out : std_logic_vector(OUTPUT_WIDTH-1 downto 0);

    -- Clock period definition
    constant clk_period : time := 5 ns;

    -- testbench signals
    signal data_in_d1 : std_logic_vector(INPUT_WIDTH-1 downto 0) := (others => '0');
    signal data_in_accum : signed(64-1 downto 0) := (others => '0');
    signal data_out_accum : signed(64-1 downto 0) := (others => '0');
    signal data_out_accum_scaled : signed(64-1 downto 0) := (others => '0');
    signal integral_error : signed(64-1 downto 0) := (others => '0');
    signal reset_accums : std_logic := '0';
begin

    -- Unit under test
    quantize_with_accurate_integral_inst : entity work.quantize_with_accurate_integral
    generic map (
        INPUT_WIDTH  => INPUT_WIDTH,
        OUTPUT_WIDTH => OUTPUT_WIDTH
    ) port map (
        clk      => clk,
        data_in  => data_in,
        data_out => data_out
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
            data_in_d1 <= data_in;
            if reset_accums='1' then
                data_in_accum <= (others => '0'); -- accums get reset between different tests, to make it easier to interpret the waveforms
                data_out_accum <= (others => '0'); -- accums get reset between different tests, to make it easier to interpret the waveforms
            else
                data_in_accum <= data_in_accum + resize(signed(data_in_d1), data_in_accum'length);
                data_out_accum <= data_out_accum + resize(signed(data_out), data_out_accum'length);
            end if;
        end if;
    end process;

    -- this is to make it easier to compare input and output data
    data_out_accum_scaled <= shift_left(data_out_accum, INPUT_WIDTH-OUTPUT_WIDTH);
    integral_error <= data_out_accum_scaled - data_in_accum;

    -- Stimulus process
    process
    begin
        wait for clk_period*10;
        wait until rising_edge(clk);

        -- Test #1: send a small value in (whose individual values get quantized out)
        for I in 0 to 1023 loop
            wait until rising_edge(clk);
                data_in <= std_logic_vector(to_signed(3, data_in'length));
        end loop;

        wait for clk_period*50;
        wait until rising_edge(clk);
            reset_accums <= '1';
        wait until rising_edge(clk);
            reset_accums <= '0';
        wait for clk_period*50;

        -- Test #2: send a small ramp (whose individual values initially get quantized out, but then pick up the pace)
        for I in 0 to 1023 loop
            wait until rising_edge(clk);
                data_in <= std_logic_vector(signed(data_in) + 3);
        end loop;


        wait for clk_period*50;
        wait until rising_edge(clk);
            reset_accums <= '1';
        wait until rising_edge(clk);
            reset_accums <= '0';
        wait for clk_period*50;

        -- Test #3: send a large signal that doesn't really even suffer from quantization
        -- (but still does a bit, so we see how the module reacts)
        for I in 0 to 1023 loop
            wait until rising_edge(clk);
                data_in <= std_logic_vector(signed(data_in) + 64 + 2);
        end loop;

        wait;

        -- Example of a for loop:
    end process;
    
end;
