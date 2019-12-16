library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- Computes a*b, where A and B and complex numbers in cartesian form
-- real(a*b) = real(a)*real(b)-imag(a)*imag(b)
-- imag(a*b) = real(a)*imag(b)+imag(a)*real(b)
--
-- has a latency of 3 clk cycles from a change either on A or B and the associated change in the output
-- due to internal pipelining
entity complex_mult is
Generic (
    A_WIDTH : integer := 16;
    B_WIDTH : integer := 14
);
port (
    clk   : in  std_logic;

    a_real : in  std_logic_vector(A_WIDTH-1 downto 0);
    a_imag : in  std_logic_vector(A_WIDTH-1 downto 0);
    b_real : in  std_logic_vector(B_WIDTH-1 downto 0);
    b_imag : in  std_logic_vector(B_WIDTH-1 downto 0);

    -- General purpose flag input, will be delayed by the same latency as the numeric inputs
    user_flag_in  : in  std_logic;
    user_flag_out : out std_logic;

    out_real : out std_logic_vector(A_WIDTH+B_WIDTH+1-1 downto 0);
    out_imag : out std_logic_vector(A_WIDTH+B_WIDTH+1-1 downto 0)

    );
end entity;

architecture Behavioral of complex_mult is

    signal a_real_reg   : signed(          A_WIDTH-1 downto 0) := (others => '0');
    signal a_imag_reg   : signed(          A_WIDTH-1 downto 0) := (others => '0');
    signal b_real_reg   : signed(          B_WIDTH-1 downto 0) := (others => '0');
    signal b_imag_reg   : signed(          B_WIDTH-1 downto 0) := (others => '0');
    signal ar_times_br  : signed(  A_WIDTH+B_WIDTH-1 downto 0) := (others => '0');
    signal ar_times_bi  : signed(  A_WIDTH+B_WIDTH-1 downto 0) := (others => '0');
    signal ai_times_br  : signed(  A_WIDTH+B_WIDTH-1 downto 0) := (others => '0');
    signal ai_times_bi  : signed(  A_WIDTH+B_WIDTH-1 downto 0) := (others => '0');
    signal results_real : signed(A_WIDTH+B_WIDTH+1-1 downto 0) := (others => '0');
    signal results_imag : signed(A_WIDTH+B_WIDTH+1-1 downto 0) := (others => '0');

    signal flag_d1, flag_d2, flag_d3 : std_logic := '0';
begin

    process (clk)
    begin
        if rising_edge(clk) then
            -- 1st pipeline stage: register operands before multiplication
            a_real_reg <= signed(a_real);
            a_imag_reg <= signed(a_imag);
            b_real_reg <= signed(b_real);
            b_imag_reg <= signed(b_imag);
            flag_d1 <= user_flag_in;


            -- 2nd pipeline stage: compute required products of pairs of inputs
            ar_times_br <= a_real_reg*b_real_reg;
            ar_times_bi <= a_real_reg*b_imag_reg;
            ai_times_br <= a_imag_reg*b_real_reg;
            ai_times_bi <= a_imag_reg*b_imag_reg;
            flag_d2 <= flag_d1;

            -- 2nd pipeline step: add rounding constant and quantize back to OUTPUT_WIDTH bits
            -- Changed 2018-11-16: we don't even need that, since we want the output to be big anyway...
            modulation_output_post_mult <= divide_and_round(productr+producti, LOG2_DIVIDE_AFTER_MULT);

            -- 3rd pipeline stage: compute sums of pairwise products
            results_real <= resize(ar_times_br, results_real'length) - resize(ai_times_bi, results_real'length);
            results_imag <= resize(ar_times_bi, results_real'length) + resize(ai_times_br, results_real'length);
            flag_d3 <= flag_d2;
        end if;
    end process;

    -- assign outputs:
    out_real <= std_logic_vector(results_real);
    out_imag <= std_logic_vector(results_imag);
    user_flag_out <= flag_d3;
end;
