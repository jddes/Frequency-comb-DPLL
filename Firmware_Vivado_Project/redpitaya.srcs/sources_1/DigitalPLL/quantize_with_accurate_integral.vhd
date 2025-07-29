library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- quantize a signal from INPUT_WIDTH to OUTPUT_WIDTH bits, with INPUT_WIDTH>OUTPUT_WIDTH,
-- making sure to accumulate the quantization error,
-- and adding it to the output when its big enough
--
-- known limitations:
-- this can wrap/not handle well the case of the input being equal or above the maximum value
-- in the output (normal behavior would be to dither between MAX and MAX+1, but MAX+1 just wraps around...
entity quantize_with_accurate_integral is
Generic (
    INPUT_WIDTH : integer := 16;
    OUTPUT_WIDTH : integer := 10
);
port (
    clk : in  std_logic;

    input_clk_enable   : in  std_logic;
    data_in            : in  std_logic_vector(INPUT_WIDTH-1 downto 0);
    output_clk_enable  : out std_logic;
    data_out           : out std_logic_vector(OUTPUT_WIDTH-1 downto 0)

    );
end entity;

architecture Behavioral of quantize_with_accurate_integral is

    constant TRUNCATED_BITS : integer := INPUT_WIDTH-OUTPUT_WIDTH;

    signal accumulated_error : unsigned(TRUNCATED_BITS+1-1 downto 0) := (others => '0');
    signal output_reg        :   signed(OUTPUT_WIDTH-1 downto 0) := (others => '0');

    signal input_clk_enable_d1 : std_logic := '0';
begin

    process (clk)
    begin
        if rising_edge(clk) then
            input_clk_enable_d1 <= input_clk_enable;
            if input_clk_enable='1' then
                accumulated_error <= resize(accumulated_error(TRUNCATED_BITS-1 downto 0), TRUNCATED_BITS+1) + 
                    resize(unsigned(data_in(TRUNCATED_BITS-1 downto 0)), TRUNCATED_BITS+1);
                output_reg <= signed(data_in(data_in'left downto data_in'left-OUTPUT_WIDTH+1))
                              + signed(resize(accumulated_error(accumulated_error'left downto accumulated_error'left), OUTPUT_WIDTH));
            end if;
        end if;
    end process;

    data_out <= std_logic_vector(output_reg);
    output_clk_enable <= input_clk_enable_d1;
end;
