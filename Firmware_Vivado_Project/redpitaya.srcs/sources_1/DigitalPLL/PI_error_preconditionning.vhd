library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

--library work;
--use work.maths_helper.all;

-- to handle a larger range on the phase error signals:
-- we changed UNWRAPPED_WIDTH above to be larger by N bits (chose N=10),
-- added saturation to remove the M MSBs (chose M=6)
-- then divided down by 2^P (chose P=4) to trim off the LSBs, quantized with no accumulated error
-- with N = M + P, to keep the PI the same input size
-- latency is 3 cycles from input_clk_enable to output_clk_enable,
-- fully pipelined, so input rate can by the full clock rate

entity PI_error_preconditionning is
Generic (
    INPUT_WIDTH  : integer := 14+10; -- set by the unwrapped phase's width
    OUTPUT_WIDTH : integer := 14; -- set by PI_loop_filter's INPUT_WIDTH
    LOG2_DIVIDE : integer := 4 -- trim off the 4 LSBs by quantizing with no accumulated error
);
port (
    clk                : in  std_logic;
    
    input_clk_enable   : in  std_logic;
    unwrapped_phase_in : in  std_logic_vector(INPUT_WIDTH-1 downto 0);

    output_clk_enable  : out std_logic;
    data_out           : out std_logic_vector(OUTPUT_WIDTH-1 downto 0)

    );
end entity;

architecture Behavioral of PI_error_preconditionning is
    -- this is a constant, but it's easier to specify before in combinational statements.
    -- we want all LOG2_DIVIDE LSBs to be zero so as to not accumulate errors
    -- in the quantization process, and also have a small margin to make extra sure
    -- the quantizer never overflows
    signal max_before_shift : signed(INPUT_WIDTH-1 downto 0);
    signal min_before_shift : signed(INPUT_WIDTH-1 downto 0);

    constant MSBS_REMOVED : integer := INPUT_WIDTH-OUTPUT_WIDTH-LOG2_DIVIDE;

    constant ROUNDING_CONSTANT : signed(INPUT_WIDTH-1 downto 0) := to_signed(2**(LOG2_DIVIDE-1), INPUT_WIDTH);

    signal unwrapped_phase_in_d1 : signed(INPUT_WIDTH-1 downto 0) := (others => '0');
    signal unwrapped_phase_in_d2 : signed(INPUT_WIDTH-1 downto 0) := (others => '0');
    signal phase_small_d2 : std_logic_vector(OUTPUT_WIDTH+LOG2_DIVIDE-1 downto 0) := (others => '0');

    signal input_clk_enable_d1, input_clk_enable_d2 : std_logic := '0';

begin

    max_before_shift(max_before_shift'left downto max_before_shift'left-MSBS_REMOVED) <= (others => '0');
    max_before_shift(max_before_shift'left-MSBS_REMOVED-1 downto LOG2_DIVIDE+1) <= (others => '1');
    max_before_shift(LOG2_DIVIDE downto 0) <= (others => '0');

    min_before_shift(min_before_shift'left downto min_before_shift'left-MSBS_REMOVED) <= (others => '1');
    min_before_shift(min_before_shift'left-MSBS_REMOVED-1 downto 0) <= (others => '0');

    -- add a rounding constant to convert the quantization operation into rounding
    process( clk )
    begin
        if rising_edge(clk) then
            input_clk_enable_d1 <= input_clk_enable;
            if input_clk_enable='1' then
                unwrapped_phase_in_d1 <= signed(unwrapped_phase_in) + ROUNDING_CONSTANT;
            end if;
        end if;
    end process;

    -- saturation
    process( clk )
    begin
        if rising_edge(clk) then
            input_clk_enable_d2 <= input_clk_enable_d1;
            if input_clk_enable_d1='1' then
                if unwrapped_phase_in_d1 > max_before_shift then
                    unwrapped_phase_in_d2 <= max_before_shift;
                elsif unwrapped_phase_in_d1 < min_before_shift then
                    unwrapped_phase_in_d2 <= min_before_shift;
                else
                    unwrapped_phase_in_d2 <= unwrapped_phase_in_d1;
                end if;
            end if;
                
        end if;
    end process;

    phase_small_d2 <= std_logic_vector(unwrapped_phase_in_d2(phase_small_d2'range));

    -- a change in the sign bit between these two signals indicates wrapping,
    -- which we are trying to guarantee never to happen via the saturation logic
    assert unwrapped_phase_in_d2(unwrapped_phase_in_d2'left) = phase_small_d2(phase_small_d2'left)
        report "error: phase has wrapped, which is not supposed to happen!"
        severity error;

    -- quantize, effectively dividing by 2^LOG2_DIVIDE, with no accumulated error even if integrated
    quantize_with_accurate_integral_inst : entity work.quantize_with_accurate_integral
    generic map (
        INPUT_WIDTH  => phase_small_d2'length,
        OUTPUT_WIDTH => OUTPUT_WIDTH
    ) port map (
        clk               => clk,
        input_clk_enable  => input_clk_enable_d2,
        data_in           => phase_small_d2,
        output_clk_enable => output_clk_enable,
        data_out          => data_out
    );

end;
