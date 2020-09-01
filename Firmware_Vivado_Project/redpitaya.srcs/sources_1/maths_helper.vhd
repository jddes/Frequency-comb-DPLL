library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

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

    function clog2(x: in integer) return integer; -- ceil(log2(x))
    function clog2(x: in unsigned) return integer;  -- ceil(log2(x))
    function find_msb(x: in unsigned) return unsigned; -- floor(log2(abs(x)))
    function find_msb(x: in   signed) return unsigned; -- floor(log2(abs(x)))

    -- trivial conversion functions that should exist in the language/math_real package...
    function to_real( x: in unsigned ) return real;
    function to_real( x: in   signed ) return real;
    function to_unsigned( x: in real; N_BITS : in natural ) return unsigned;
    function to_signed( x: in real; N_BITS : in natural ) return signed;

    -- so we can use the equivalent of shift_left(unsigned) and shift_right(unsigned) with std_logic_vector()
    function shift_left_logical( x: in std_logic_vector; N_BITS : in integer ) return std_logic_vector;
    function shift_right_logical( x: in std_logic_vector; N_BITS : in integer ) return std_logic_vector;

    -- uses math_real to synthesize cos/sine in fixed point, fixed frequency:
    -- actual equation is round((2^(N_BITS-1)-1)*cos(2*pi*num/den)) (or sin)
    function cos_fixed( num: in integer; den: in integer; N_BITS : in integer ) return signed;
    function sin_fixed( num: in integer; den: in integer; N_BITS : in integer ) return signed;

end maths_helper;

package body maths_helper is

    function cos_fixed( num: in integer; den: in integer; N_BITS : in integer ) return signed is
    begin
        return to_signed(integer(    round((2.0**(real(N_BITS)-1.0)-1.0) *     cos(math_2_pi*real(num)/real(den)))    ), N_BITS);
    end;
    function sin_fixed( num: in integer; den: in integer; N_BITS : in integer ) return signed is
    begin
        return to_signed(integer(    round((2.0**(real(N_BITS)-1.0)-1.0) *     sin(math_2_pi*real(num)/real(den)))    ), N_BITS);
    end;

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
        if N_SIZE_SHIFT > 0 then
            round_constant(N_SIZE_SHIFT-1) := '1';
        end if;
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

    -- shifts bits left, padding with zeros, just to save some typing and make things more readable
    function shift_left_logical( x: in std_logic_vector; N_BITS : in integer ) return std_logic_vector is
    begin
        return std_logic_vector(shift_left(unsigned(x), N_BITS));
    end shift_left_logical;

    -- shifts bits right, padding with zeros, just to save some typing and make things more readable
    function shift_right_logical( x: in std_logic_vector; N_BITS : in integer ) return std_logic_vector is
    begin
        return std_logic_vector(shift_right(unsigned(x), N_BITS));
    end shift_right_logical;

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


    function clog2(x: in integer) return integer is
    begin
        return integer(ceil(log2(real(x))));
    end clog2;

    function clog2(x: in unsigned) return integer is
    begin
        return integer(ceil(log2(real(to_integer(x)))));
    end clog2;

    -- Finds the position of the MSB
    -- returns floor(log2(x)), except in the special case of x=0: returns 0
    function find_msb(x : in unsigned) return unsigned is
        constant OUTPUT_WIDTH : integer := clog2(x'length);
        variable retval : unsigned(OUTPUT_WIDTH-1 downto 0);
    begin
        retval := (others => '0');
        for I in 0 to x'length-1 loop
            if x(I) = '1' then
                retval := to_unsigned(I, OUTPUT_WIDTH);
            end if;
        end loop;
        return retval;
    end find_msb;

    -- same function, for signed input: returns floor(log2(abs(x)))
    function find_msb(x : in signed) return unsigned is
        constant OUTPUT_WIDTH : integer := clog2(x'length);
        variable retval : unsigned(OUTPUT_WIDTH-1 downto 0);
    begin
        retval := (others => '0');
        for I in 0 to x'length-1 loop
            -- positive case: find the first bit equal to '1'
            if x(x'left) = '0' and x(I) = '1' then
                retval := to_unsigned(I, OUTPUT_WIDTH);
            end if;
            -- negative case: find the first bit equal to '0'
            if x(x'left) = '1' and x(I) = '0' then
                retval := to_unsigned(I, OUTPUT_WIDTH);
            end if;
        end loop;
        return retval;
    end find_msb;


    -- trivial conversion functions that should exist in the language/math_real package...
    function to_real( x: in unsigned ) return real is 
    begin
        return real(to_integer(x));
    end to_real;

    function to_real( x: in   signed ) return real is 
    begin
        return real(to_integer(x));
    end to_real;

    function to_unsigned( x: in real; N_BITS : in natural ) return unsigned is
    begin
        return to_unsigned(integer(x), N_BITS);
    end to_unsigned;
    function to_signed( x: in real; N_BITS : in natural ) return signed is
    begin
        return to_signed(integer(x), N_BITS);
    end to_signed;
end maths_helper;


--------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

-- This generates uniform random numbers over the full span covered by DATA_WIDTH (whether interpreted as signed or unsigned)
-- This is limited to 31 bits due to the use of "integer" internally
entity rng_slv is
Generic (
    DATA_WIDTH    : integer := 31
);
port (
    clk : in  std_logic;
    data  : out std_logic_vector(DATA_WIDTH-1 downto 0);
    data2 : out std_logic_vector(DATA_WIDTH-1 downto 0)
    );
end entity;

architecture Behavioral of rng_slv is
    constant int_range : real := real(2)**real(DATA_WIDTH)-real(1);
    signal data_real, data2_real : real;
begin
    
    process(clk)
        variable seed1, seed2 : integer := 1; -- can't use 0 here or the rng doesn't start (see math_real.vhd)
        variable rand_re, rand_im : real;
    begin
        if rising_edge(clk) then
            uniform(seed1, seed2, rand_re); -- rand_re is uniform between 0 and 1
            uniform(seed1, seed2, rand_im); -- rand_im is uniform between 0 and 1
            data_real <= rand_re;
            data2_real <= rand_im;
            data <= std_logic_vector(to_unsigned(
                                    integer(round(int_range*rand_re))
                                    , DATA_WIDTH));
            data2 <= std_logic_vector(to_unsigned(
                                    integer(round(int_range*rand_im))
                                    , DATA_WIDTH));

        end if;
    end process;

end;