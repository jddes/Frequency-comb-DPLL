library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity complex_mult_testbench is
end complex_mult_testbench;

architecture behavior of complex_mult_testbench is

    constant A_WIDTH                : integer := 16;
    constant B_WIDTH                : integer := 8;
    constant LOG2_DIVIDE_AFTER_MULT : integer := 8;
    constant OUTPUT_WIDTH           : integer := 16;

    -- Inputs
    signal clk : std_logic := '0';
    signal a_real : std_logic_vector(a_width-1 downto 0) := x"0100";
    signal a_imag : std_logic_vector(a_width-1 downto 0) := x"1000";
    signal b_real : std_logic_vector(b_width-1 downto 0) := x"01";
    signal b_imag : std_logic_vector(b_width-1 downto 0) := x"10";

    signal user_flag_in  : std_logic := '0';
    signal user_flag_out : std_logic := '0';
    
    -- Outputs
    signal out_real : std_logic_vector(OUTPUT_WIDTH-1 downto 0);
    signal out_imag : std_logic_vector(OUTPUT_WIDTH-1 downto 0);
    
    -- Clock period definition
    constant clk_period : time := 5 ns;
begin

    -- Unit under test
    complex_mult_inst : entity work.complex_mult
    generic map (
        A_WIDTH => A_WIDTH,
        B_WIDTH => B_WIDTH,
        LOG2_DIVIDE_AFTER_MULT => LOG2_DIVIDE_AFTER_MULT,
        OUTPUT_WIDTH => OUTPUT_WIDTH

    ) port map (
        clk           => clk,
        a_real        => a_real,
        a_imag        => a_imag,
        b_real        => b_real,
        b_imag        => b_imag,
        user_flag_in  => user_flag_in,
        user_flag_out => user_flag_out,
        out_real      => out_real,
        out_imag      => out_imag
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
            a_real <= std_logic_vector(to_signed(-2**15, a_real'length));
            user_flag_in <= '1';    -- to test the flag's latency vs the data
        wait until rising_edge(clk);
            user_flag_in <= '0';
        wait;

    end process;
    
end;
