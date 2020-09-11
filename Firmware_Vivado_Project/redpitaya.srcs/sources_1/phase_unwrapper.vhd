library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- output a phase from INPUT_WIDTH to OUTPUT_WIDTH bits
-- using the cumsum(modulo(diff()) algorithm
-- 2 clk cycles of latency

entity phase_unwrapper is
Generic (
    INPUT_WIDTH  : integer := 14;
    OUTPUT_WIDTH : integer := 32
);
port (
    clk                 : in  std_logic;
    clk_enable_in       : in  std_logic;
    wrapped_phase_in    : in  std_logic_vector(INPUT_WIDTH-1 downto 0);

    reset_offset        : in  std_logic;
    
    clk_enable_out      : out std_logic;
    unwrapped_phase_out : out std_logic_vector(OUTPUT_WIDTH-1 downto 0)

    );
end entity;

architecture Behavioral of phase_unwrapper is
    signal clk_enable_in_d1    : std_logic := '0';
    signal clk_enable_in_d2    : std_logic := '0';
    signal wrapped_phase_in_d1 : signed( INPUT_WIDTH-1 downto 0) := (others => '0');
    signal delta_phase         : signed( INPUT_WIDTH-1 downto 0) := (others => '0');
    signal phase_accum         : signed(OUTPUT_WIDTH-1 downto 0) := (others => '0');

    signal will_reset_offset : std_logic := '0';
    signal resetting : std_logic := '0';
begin

    process( clk )
    begin
        if rising_edge(clk) then
            clk_enable_in_d1 <= clk_enable_in;
            if clk_enable_in = '1' then
                wrapped_phase_in_d1 <= signed(wrapped_phase_in);
                if reset_offset = '1' or will_reset_offset = '1' then
                    resetting <= '1';
                    will_reset_offset <= '0';
                    delta_phase <= signed(wrapped_phase_in);
                else
                    resetting <= '0';
                    delta_phase <= signed(wrapped_phase_in) - wrapped_phase_in_d1;
                end if;
            else
                -- register reset commands until we see the next clock-enabled input point
                if reset_offset = '1' then
                    will_reset_offset <= '1';
                end if;

            end if;
            clk_enable_in_d2 <= clk_enable_in_d1;
            if clk_enable_in_d1 = '1' then
                if resetting = '1' then
                    phase_accum <= resize(delta_phase, OUTPUT_WIDTH);
                else
                    phase_accum <= phase_accum + resize(delta_phase, OUTPUT_WIDTH);
                end if;
            end if;
        end if;
    end process;

    clk_enable_out <= clk_enable_in_d2;
    unwrapped_phase_out <= std_logic_vector(phase_accum);
end;
