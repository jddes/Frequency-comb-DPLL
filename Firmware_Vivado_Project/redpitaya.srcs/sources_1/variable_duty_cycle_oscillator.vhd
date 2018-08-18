library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


entity variable_duty_cycle_oscillator  is
Generic (
    COUNTER_BITS    : integer := 24
);
port (
    clk              : in  std_logic;
    
    bEnable          : in  std_logic;
    bPolarity        : in  std_logic;
    modulus          : in  std_logic_vector(COUNTER_BITS-1 downto 0);
    modulus_active   : in  std_logic_vector(COUNTER_BITS-1 downto 0);
    
    output_square_wave : out std_logic

    );
end entity;

architecture Behavioral of variable_duty_cycle_oscillator is
    signal counter : unsigned(COUNTER_BITS-1 downto 0) := (others => '0');
    signal output_int : std_logic := '0';
begin

    
    process (clk)
    begin
        if rising_edge(clk) then
            if counter < unsigned(modulus)-1 then
                counter <= counter + 1;
            else
                counter <= (others => '0');
            end if;
            if counter < unsigned(modulus_active) then
                output_int <= bEnable and bPolarity;
            else
                output_int <= bEnable and (not bPolarity);
            end if;
        end if;
    end process;

    output_square_wave <= output_int;
end;
