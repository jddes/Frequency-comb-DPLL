library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity minmax_decimator_testbench is
end minmax_decimator_testbench;

architecture behavior of minmax_decimator_testbench is

    -- minmax_decimator signals
    -- Generics as constants
    constant DATA_WIDTH         : integer := 16;
    constant SYNC_COUNTER_WIDTH : integer := 4;
    -- Inputs
    signal clk           : std_logic                               := '0';
    signal clk_enable_in : std_logic                               := '1';
    signal data          : std_logic_vector(DATA_WIDTH-1 downto 0) := (others => '0');
    signal period        : std_logic_vector(32-1 downto 0)         := std_logic_vector(to_unsigned(10, 32));
    -- Outputs
    signal clk_enable_out : std_logic;
    signal counter_out    : std_logic_vector(SYNC_COUNTER_WIDTH-1 downto 0);
    signal min_out        : std_logic_vector(DATA_WIDTH-1 downto 0);
    signal max_out        : std_logic_vector(DATA_WIDTH-1 downto 0);

    -- Clock period definition
    constant clk_period : time := 5 ns;
begin

    -- Unit under test
    minmax_decimator_inst : entity work.minmax_decimator
    generic map (
        DATA_WIDTH         => DATA_WIDTH,
        SYNC_COUNTER_WIDTH => SYNC_COUNTER_WIDTH
    ) port map (
        clk            => clk,
        clk_enable_in  => clk_enable_in,
        data           => data,
        period         => period,
        clk_enable_out => clk_enable_out,
        counter_out    => counter_out,
        min_out        => min_out,
        max_out        => max_out
    );

    -- Clock process definition for "clk"
    process
    begin
        clk <= '0';
        wait for clk_period/2;
        clk <= '1';
        wait for clk_period/2;
    end process;

    process(clk)
    begin
        if rising_edge(clk) then
            data <= std_logic_vector(signed(data)-1); -- down-ramp

        end if;
    end process;

    -- Stimulus process
    process
    begin
        wait for clk_period*10;
        wait until rising_edge(clk);
        wait;

    end process;
    
end;
