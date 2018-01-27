library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- simply computes:
-- error1_out = (DAC0_in - DAC0_lockpoint_in)/2^6, with appropriate saturation logic to ensure nothing ever wraps around
-- This was designed to scale a 16-bits error signal down to a 10-bits one, with an offset added.

-- This was exclusively tested with:
--    constant N_BITS_IN  : integer := 16;
--    constant N_BITS_OUT : integer := 10;
--
-- So it needs to be re-tested before using with different generics.

entity cascade_lock_error_formatter  is
Generic (
    N_BITS_IN  : integer := 16; -- only N_BITS_IN =16 was tested
    N_BITS_OUT : integer := 10  -- only N_BITS_OUT=10 was tested
);
port (
    clk               : in  std_logic;
    
    DAC0_in           : in  std_logic_vector(N_BITS_IN-1 downto 0);
    DAC0_lockpoint_in : in  std_logic_vector(N_BITS_IN-1 downto 0);
    error1_out        : out std_logic_vector(N_BITS_OUT-1 downto 0)

    );
end entity;

architecture Behavioral of cascade_lock_error_formatter is

    signal error_wide : signed(N_BITS_IN+1-1 downto 0) := (others => '0');
    constant BITS_SHIFT : integer := N_BITS_IN-N_BITS_OUT; -- divide the subtraction result by 2^BITS_SHIFT=2^6
    constant ERROR_MAX : signed(N_BITS_IN+1-1 downto 0) := shift_left(to_signed( 2**(N_BITS_OUT-1)-1, N_BITS_IN+1), BITS_SHIFT);
    constant ERROR_MIN : signed(N_BITS_IN+1-1 downto 0) := shift_left(to_signed(-2**(N_BITS_OUT-1)  , N_BITS_IN+1), BITS_SHIFT);

    signal error_internal : signed(N_BITS_IN+1-1 downto 0) := (others => '0');
begin

    process (clk)
    begin
        if rising_edge(clk) then
            error_wide <= resize(signed(DAC0_in), N_BITS_IN+1) - resize(signed(DAC0_lockpoint_in), N_BITS_IN+1);
            -- saturate and right shift the subtraction result
            if error_wide > ERROR_MAX then
                -- saturated positive
                error_internal <= shift_right(ERROR_MAX, BITS_SHIFT);
            elsif error_wide < ERROR_MIN then
                -- saturated negative
                error_internal <= shift_right(ERROR_MIN, BITS_SHIFT);
            else
                -- normal operation
                error_internal <= shift_right(error_wide, BITS_SHIFT);
            end if;
        end if;
    end process;


    error1_out <= std_logic_vector(error_internal(N_BITS_OUT-1 downto 0));
end;
