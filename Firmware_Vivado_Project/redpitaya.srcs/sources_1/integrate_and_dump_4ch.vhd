library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


entity integrate_and_dump_4ch is
Generic (
    DATA_WIDTH    : integer := 16;
    COUNTER_WIDTH : integer := 32
);
port (
    clk             : in  std_logic;
    
    clk_enable_in   : in  std_logic;
    data_in1        : in  std_logic_vector(DATA_WIDTH-1 downto 0);
    data_in2        : in  std_logic_vector(DATA_WIDTH-1 downto 0);
    data_in3        : in  std_logic_vector(DATA_WIDTH-1 downto 0);
    data_in4        : in  std_logic_vector(DATA_WIDTH-1 downto 0);
    
    -- config port:
    n_cycles        : in  std_logic_vector(COUNTER_WIDTH-1 downto 0);
    
    clk_enable_out  : out std_logic;
    data_out1       : out std_logic_vector(DATA_WIDTH-1 downto 0);
    data_out2       : out std_logic_vector(DATA_WIDTH-1 downto 0);
    data_out3       : out std_logic_vector(DATA_WIDTH-1 downto 0);
    data_out4       : out std_logic_vector(DATA_WIDTH-1 downto 0)
    );
end entity;

architecture Behavioral of integrate_and_dump_4ch is
    -- data registers: 4 sets
    signal data_in_reg1      : signed(DATA_WIDTH-1 downto 0) := (others => '0');
    signal data_in_reg2      : signed(DATA_WIDTH-1 downto 0) := (others => '0');
    signal data_in_reg3      : signed(DATA_WIDTH-1 downto 0) := (others => '0');
    signal data_in_reg4      : signed(DATA_WIDTH-1 downto 0) := (others => '0');
    signal accum1            : signed(DATA_WIDTH-1 downto 0) := (others => '0');
    signal accum2            : signed(DATA_WIDTH-1 downto 0) := (others => '0');
    signal accum3            : signed(DATA_WIDTH-1 downto 0) := (others => '0');
    signal accum4            : signed(DATA_WIDTH-1 downto 0) := (others => '0');
    signal data_out_reg1     : signed(DATA_WIDTH-1 downto 0) := (others => '0');
    signal data_out_reg2     : signed(DATA_WIDTH-1 downto 0) := (others => '0');
    signal data_out_reg3     : signed(DATA_WIDTH-1 downto 0) := (others => '0');
    signal data_out_reg4     : signed(DATA_WIDTH-1 downto 0) := (others => '0');

    -- control signals: just one set
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
                data_in_reg1 <= signed(data_in1);
                data_in_reg2 <= signed(data_in2);
                data_in_reg3 <= signed(data_in3);
                data_in_reg4 <= signed(data_in4);
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
                    accum1 <= data_in_reg1;
                    accum2 <= data_in_reg2;
                    accum3 <= data_in_reg3;
                    accum4 <= data_in_reg4;
                    data_out_reg1 <= accum1;
                    data_out_reg2 <= accum2;
                    data_out_reg3 <= accum3;
                    data_out_reg4 <= accum4;
                    clk_enable_int <= '1';
                else
                    accum1 <= accum1 + data_in_reg1;
                    accum2 <= accum2 + data_in_reg2;
                    accum3 <= accum3 + data_in_reg3;
                    accum4 <= accum4 + data_in_reg4;
                end if;
            end if;
        end if;
    end process;

    clk_enable_out <= clk_enable_int;
    data_out1      <= std_logic_vector(data_out_reg1);
    data_out2      <= std_logic_vector(data_out_reg2);
    data_out3      <= std_logic_vector(data_out_reg3);
    data_out4      <= std_logic_vector(data_out_reg4);
end;
