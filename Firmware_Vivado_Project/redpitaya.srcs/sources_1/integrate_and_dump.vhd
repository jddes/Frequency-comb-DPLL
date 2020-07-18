library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


entity integrate_and_dump is
Generic (
    DATA_WIDTH    : integer := 16;
    COUNTER_WIDTH : integer := 32
);
port (
    clk            : in  std_logic;
    
    clk_enable_in  : in  std_logic;
    data_in        : in  std_logic_vector(DATA_WIDTH-1 downto 0);
    
    -- config port:
    n_cycles       : in  std_logic_vector(COUNTER_WIDTH-1 downto 0);
    
    clk_enable_out : out std_logic;
    data_out       : out std_logic_vector(DATA_WIDTH-1 downto 0)
    );
end entity;

architecture Behavioral of integrate_and_dump is
    signal data_in_reg      : signed(DATA_WIDTH-1 downto 0) := (others => '0');
    signal accum            : signed(DATA_WIDTH-1 downto 0) := (others => '0');
    signal data_out_reg     : signed(DATA_WIDTH-1 downto 0) := (others => '0');
    signal counter          : unsigned(COUNTER_WIDTH-1 downto 0) := (others => '0');
    signal dump             : std_logic := '0';
    
    signal clk_enable_in_d1 : std_logic := '0';
    signal clk_enable_int   : std_logic := '0';
begin

    -- input register & counter process
    process( clk )
    begin
        if rising_edge(clk) then
            dump <= '0';

            clk_enable_in_d1 <= clk_enable_in;
            if clk_enable_in = '1' then
                data_in_reg <= signed(data_in);
                if counter < unsigned(n_cycles)-1 then
                    counter <= counter + 1;
                else
                    counter <= (others => '0');
                    dump <= '1';
                end if;
            end if;
        end if;
    end process;

    -- integrator process
    process( clk )
    begin
        if rising_edge(clk) then
            clk_enable_int <= '0';

            if clk_enable_in_d1 = '1' then
                if dump = '1' then
                    accum <= data_in_reg;
                    data_out_reg <= accum;
                    clk_enable_int <= '1';
                else
                    accum <= accum + data_in_reg;
                end if;
            end if;
        end if;
    end process;

    clk_enable_out <= clk_enable_int;
    data_out       <= std_logic_vector(data_out_reg);
end;
