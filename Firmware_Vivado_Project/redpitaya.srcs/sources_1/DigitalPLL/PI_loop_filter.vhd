library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.maths_helper.all;

-- in the linear regime (neither input nor output saturated),
-- this computes data_out = gain_fine * (2^P_gain_coarse * unwrapped_phase_in + 2^I_gain_coarse * cumsum(unwrapped_phase_in))
-- latency is 55 clk cycles from input_clk_enable to output_clk_enable

entity PI_loop_filter is
Generic (
    INPUT_WIDTH  : integer := 14; -- ideally this should be low enough so that it fits in a multiplier slice (25 bits max)
    OUTPUT_WIDTH : integer := 48
);
port (
    clk                : in  std_logic;
    
    -- input rate must be <= clk/55 (exact value TBD!)
    input_clk_enable   : in  std_logic;
    unwrapped_phase_in : in  std_logic_vector(INPUT_WIDTH-1 downto 0);
    
    -- config port
    gain_fine          : in  std_logic_vector(4-1 downto 0); -- signed: also sets the overall loop sign
    P_gain_coarse      : in  std_logic_vector(6-1 downto 0); -- max is 48 bits shift
    I_gain_coarse      : in  std_logic_vector(6-1 downto 0); -- max is 48 bits shift
    P_enable           : in  std_logic;
    I_enable           : in  std_logic;
    
    -- status port, from output summing module which also implements limits
    railed_high        : in  std_logic;
    railed_low         : in  std_logic;
    
    -- output port, meant to go to a DDS control word
    output_clk_enable  : out std_logic;
    data_out           : out std_logic_vector(OUTPUT_WIDTH-1 downto 0)

    );
end entity;

architecture Behavioral of PI_loop_filter is
    constant MAX_SHIFT : integer := 48;
    
    signal clk_enable_error_scaled : std_logic := '0';
    signal error_valid             : std_logic := '0';
    signal error_valid_gated       : std_logic := '0';
    signal error_scaled : std_logic_vector(INPUT_WIDTH+gain_fine'length-1 downto 0) := (others => '0');

    signal error_scaled_P       : std_logic_vector(OUTPUT_WIDTH-1 downto 0) := (others => '0');
    signal error_scaled_P_gated : std_logic_vector(OUTPUT_WIDTH-1 downto 0) := (others => '0');
    signal error_scaled_I       : std_logic_vector(OUTPUT_WIDTH-1 downto 0) := (others => '0');
    signal error_scaled_I_clk_enable : std_logic := '0';

    signal error_valid_d1       : std_logic := '0';
    signal error_valid_gated_d1 : std_logic := '0';
    signal error_valid_d2       : std_logic := '0';
    signal int : std_logic_vector(OUTPUT_WIDTH-1 downto 0) := (others => '0');
    signal int_plus_error : signed(int'length+1-1 downto 0) := (others => '0'); -- this has one extra bit to avoid overflow


    signal PI_sum_clk_enable     : std_logic := '0';
    signal output_clk_enable_int : std_logic := '0';

    signal PI_sum     : signed(OUTPUT_WIDTH+1-1 downto 0) := (others => '0'); -- this has a guard bit to avoid saturation at the summing stage
    signal output_int : signed(OUTPUT_WIDTH  -1 downto 0) := (others => '0');

    -- all part of the anti-windup feature:
    signal railed_high_P          : std_logic := '0';
    signal railed_low_P           : std_logic := '0';
    signal railed_high_I          : std_logic := '0';
    signal railed_low_I           : std_logic := '0';
    signal railed_high_PI         : std_logic := '0';
    signal railed_low_PI          : std_logic := '0';
    signal railed_high_prev       : std_logic := '0';
    signal railed_low_prev        : std_logic := '0';
    signal railed_high_int        : std_logic := '0';
    signal railed_low_int         : std_logic := '0';

    --attribute mark_debug : string;
    --attribute mark_debug of int:                       signal is "True";
    --attribute mark_debug of error_scaled_I:            signal is "True";
    --attribute mark_debug of error_valid_d2:            signal is "True";
    --attribute mark_debug of error_scaled_I_clk_enable: signal is "True";
    --attribute mark_debug of PI_sum_clk_enable:         signal is "True";

begin

    ----------------------------------------------------------
    -- Common to both integral and proportional branches:
    -- apply fine gain, anti-windup feature
    railed_low_int  <= railed_low_prev  or railed_low;
    railed_high_int <= railed_high_prev or railed_high;
    process(clk)
    begin
        if rising_edge(clk) then
            clk_enable_error_scaled <= input_clk_enable;
            if input_clk_enable = '1' then
                error_scaled <= std_logic_vector(signed(unwrapped_phase_in) * signed(gain_fine));
            end if;

            error_valid <= clk_enable_error_scaled;
            -- anti-windup: error gets gated out from the integral if it would push the output further into saturation
            error_valid_gated <= clk_enable_error_scaled;
            if clk_enable_error_scaled = '1' then
                if signed(error_scaled) < 0 and railed_low_int = '1' then
                    error_valid_gated <= '0';
                elsif signed(error_scaled) > 0 and railed_high_int = '1' then
                    error_valid_gated <= '0';
                end if;
            end if;
        end if;
    end process;

    ----------------------------------------------------------
    -- P branch: apply coarse gain:
    serial_barrel_shifter_P_inst : entity work.serial_barrel_shifter
    generic map (
        INPUT_WIDTH  => error_scaled'length,
        OUTPUT_WIDTH => OUTPUT_WIDTH,
        MAX_SHIFT    => MAX_SHIFT -- this will make the shift_amount input: ceil(log2(MAX_SHIFT)) = 6 bits
    ) port map (
        clk               => clk,
        input_clk_enable  => error_valid,
        data_in           => error_scaled,
        shift_amount      => P_gain_coarse,
        output_clk_enable => open,
        railed_high       => railed_high_P,
        railed_low        => railed_low_P,
        data_out          => error_scaled_P
    );

    ----------------------------------------------------------
    -- I branch: integrate first
    process(clk)
    begin
        if rising_edge(clk) then
            error_valid_d1 <= error_valid;
            -- integrator with saturation instead of overflow:
            error_valid_gated_d1 <= error_valid_gated;
            int_plus_error <= resize(signed(int), int'length+1) + resize(signed(error_scaled), int'length+1); -- don't need to make this conditional
            if I_enable = '0' then
                int <= (others => '0');
            else
                if error_valid_gated_d1 = '1' then
                    int <= std_logic_vector(saturate(int_plus_error, int'length));
                end if;
            end if;
            error_valid_d2 <= error_valid_d1; -- Use the non-gated clk enable here, so that we only skip the integrator, but continue computing the output otherwise
        end if;
    end process;

    -- I branch: apply coarse gain
    serial_barrel_shifter_I_inst : entity work.serial_barrel_shifter
    generic map (
        INPUT_WIDTH  => int'length,
        OUTPUT_WIDTH => OUTPUT_WIDTH,
        MAX_SHIFT    => MAX_SHIFT -- this will make the shift_amount input: ceil(log2(MAX_SHIFT)) = 6 bits
    ) port map (
        clk               => clk,
        input_clk_enable  => error_valid_d2,
        data_in           => int,
        shift_amount      => I_gain_coarse,
        output_clk_enable => error_scaled_I_clk_enable,
        railed_high       => railed_high_I,
        railed_low        => railed_low_I,
        data_out          => error_scaled_I
    );

    ----------------------------------------------------------
    -- sum P & I branches & saturate
    process(clk)
    begin
        if rising_edge(clk) then
            -- P branch only: apply P_enable flag:
            if P_enable = '0' then
                error_scaled_P_gated <= (others => '0');
            else
                error_scaled_P_gated <= error_scaled_P;
            end if;

            -- sum: P + I
            PI_sum_clk_enable <= error_scaled_I_clk_enable;
            if error_scaled_I_clk_enable='1' then
                PI_sum <= resize(signed(error_scaled_P_gated), PI_sum'length) + resize(signed(error_scaled_I), PI_sum'length);
                railed_high_PI <= railed_high_I or railed_high_P;
                railed_low_PI  <= railed_low_I  or railed_low_P;
            end if;

            -- saturate
            output_clk_enable_int <= PI_sum_clk_enable;
            if PI_sum_clk_enable='1' then
                output_int <= resize(saturate(PI_sum, OUTPUT_WIDTH), OUTPUT_WIDTH);
                -- compute combined saturation flags:
                if PI_sum > max_int(OUTPUT_WIDTH) or railed_high_PI = '1' then
                    railed_high_prev <= '1';
                else
                    railed_high_prev <= '0';
                end if;
                if PI_sum < min_int(OUTPUT_WIDTH) or railed_low_PI = '1' then
                    railed_low_prev <= '1';
                else
                    railed_low_prev <= '0';
                end if;
            end if;
        end if;
    end process;

    output_clk_enable <= output_clk_enable_int;
    data_out <= std_logic_vector(output_int);
end;
