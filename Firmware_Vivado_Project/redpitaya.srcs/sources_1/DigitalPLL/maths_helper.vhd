library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- example declaration required to use this library in vivado:
-- library work;
-- use work.maths_helper.all;

package maths_helper is

    function saturate(x : in unsigned; N_BITS : in integer) return unsigned;
    function saturate(x : in   signed; N_BITS : in integer) return signed;

    function max_int( N_BITS : in integer ) return signed;
    function min_int( N_BITS : in integer ) return signed;

    function max_uint( N_BITS : in integer ) return unsigned;
    function min_uint( N_BITS : in integer ) return unsigned;

    -- Returns the rounding constant needed to convert a right_shift from doing an implicit floor() to doing a round operation:
    -- shift_right(x, N) = floor(x/N)
    -- shift_right(x+rounding_constant_signed(N, x'length), N) = round(x/N)
    function rounding_constant_signed( N_SIZE_SHIFT : in integer; N_BITS_OUT : in integer ) return signed;

    -- simply does resize(round(x/2^N_SIZE_SHIFT), x'length-N_SIZE_SHIFT))
    -- note that this can wrap in extreme cases when the input is already super close to the positive rail
    function divide_and_round( x : in signed; N_SIZE_SHIFT : in integer) return signed;

end maths_helper;

package body maths_helper is

    function divide_and_round( x : in signed; N_SIZE_SHIFT : in integer) return signed is
        variable y : signed(x'length-N_SIZE_SHIFT-1 downto 0);
    begin
        y := resize(shift_right( x + rounding_constant_signed(N_SIZE_SHIFT, x'length), N_SIZE_SHIFT), y'length);
        return y;
    end;

    -- returns +2^(N_SIZE_SHIFT-1)
    function rounding_constant_signed( N_SIZE_SHIFT : in integer; N_BITS_OUT : in integer ) return signed is
        variable round_constant : signed(N_BITS_OUT-1 downto 0);
    begin
        round_constant(round_constant'range)    := (others => '0');
        round_constant(N_SIZE_SHIFT-1) := '1';
        return round_constant;
    end rounding_constant_signed;


    -- returns +2^(N_BITS-1)-1
    function max_int( N_BITS : in integer) return signed is
        variable X_MAX : signed(N_BITS-1 downto 0);
    begin
        -- we specify the limits this way because using numeric_std's to_signed() and to_unsigned() are limited at 64 bits I think (or at least they were in some Xilinx tools at some point...)
        X_MAX(X_MAX'range)       := (others => '0');
        X_MAX(N_BITS-2 downto 0) := (others => '1');
        return X_MAX;

    end max_int;

    -- returns -2^(N_BITS-1)
    function min_int( N_BITS : in integer) return signed is
        variable X_MIN : signed(N_BITS-1 downto 0);
    begin
        -- we specify the limits this way because using numeric_std's to_signed() and to_unsigned() are limited at 64 bits I think (or at least they were in some Xilinx tools at some point...)
        X_MIN(X_MIN'range)       := (others => '1');
        X_MIN(N_BITS-2 downto 0) := (others => '0');
        return X_MIN;
    end min_int;

    -- returns +2^(N_BITS-1)-1
    function max_uint( N_BITS : in integer) return unsigned is
        variable X_MAX : unsigned(N_BITS-1 downto 0);
    begin
        -- we specify the limits this way because using numeric_std's to_signed() and to_unsigned() are limited at 64 bits I think (or at least they were in some Xilinx tools at some point...)
        X_MAX                    := (others => '1');
        return X_MAX;
    end max_uint;

    -- returns 0 (just for completeness)
    function min_uint( N_BITS : in integer) return unsigned is
        variable X_MIN : unsigned(N_BITS-1 downto 0);
    begin
        -- we specify the limits this way because using numeric_std's to_signed() and to_unsigned() are limited at 64 bits I think (or at least they were in some Xilinx tools at some point...)
        X_MIN := (others => '0');
        return X_MIN;
    end min_uint;


    -- Saturates an unsigned value to N_BITS (0 to 2**N_BITS-1)
    function saturate(x : in unsigned; N_BITS : in integer) return unsigned is
        variable X_MAX : unsigned(x'length-1 downto 0);
    begin
        -- we specify the limits this way because using numeric_std's to_signed() and to_unsigned() are limited at 64 bits I think (or at least they were in some Xilinx tools at some point...)
        X_MAX(X_MAX'range)       := (others => '0');
        X_MAX(N_BITS-1 downto 0) := (others => '1');
        if x > X_MAX then
            -- saturated high
            return X_MAX(N_BITS-1 downto 0);
        else
            -- normal mode
            return x(N_BITS-1 downto 0);
        end if;

    end saturate;

    -- Saturates a signed value to N_BITS (-2**(N_BITS-1) to 2**(N_BITS-1)-1)
    function saturate(x : in signed; N_BITS : in integer) return signed is
        variable X_MAX : signed(x'length-1 downto 0);
        variable X_MIN : signed(x'length-1 downto 0);
    begin
        -- we specify the limits this way because using numeric_std's to_signed() and to_unsigned() are limited at 64 bits I think (or at least they were in some Xilinx tools at some point...)
        X_MAX(X_MAX'range)       := (others => '0');
        X_MAX(N_BITS-2 downto 0) := (others => '1');
        X_MIN(X_MIN'range)       := (others => '1');
        X_MIN(N_BITS-2 downto 0) := (others => '0');
        if x > X_MAX then
            -- saturated high
            return X_MAX(N_BITS-1 downto 0);
        elsif x < X_MIN then
            -- saturated low
            return X_MIN(N_BITS-1 downto 0);
        else
            -- normal mode
            return x(N_BITS-1 downto 0);
        end if;

    end saturate;

end maths_helper;
