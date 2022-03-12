library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


entity clock_presence_detector is
Generic (
    COUNTER_WIDTH : integer := 24
);
port (
    clk_stable                       : in  std_logic;
    clk_under_test                   : in  std_logic;
    
    minimum_cycles_of_clk_under_test : in  std_logic_vector(COUNTER_WIDTH-1 downto 0);
    cycles_of_clk_stable             : in  std_logic_vector(COUNTER_WIDTH-1 downto 0);
    
    clk_good                         : out  std_logic
    );
end entity;

architecture Behavioral of clock_presence_detector is

    signal counter             : unsigned(32-1 downto 0) := (others => '0');
    signal counter_strobe      : std_logic := '0';
    signal counter_strobe_d1   : std_logic := '0';
    
    signal clk_target_phase    : std_logic_vector(COUNTER_WIDTH-1 downto 0) := (others => '0');
    signal clk_target_phase_d1 : unsigned(COUNTER_WIDTH-1 downto 0) := (others => '0');
    signal clk_target_diff     : unsigned(COUNTER_WIDTH-1 downto 0) := (others => '0');

    signal clk_good_int        : std_logic := '0';

    attribute mark_debug : string;
    --attribute mark_debug of clk_target_phase: signal is "True";
begin

    measure_clk_phase1_vs_clk_phase2_inst : entity work.measure_clk_phase1_vs_clk_phase2
    generic map (
        PHASE_BITS => COUNTER_WIDTH
    ) port map (
        clk_ref          => clk_stable,
        clk_target       => clk_under_test,
        clk_target_phase => clk_target_phase
    );

    
    -- counter process, yields one strobe per cycles_of_clk_stable
    process( clk_stable )
    begin
        if rising_edge(clk_stable) then
            counter_strobe <= '0';
            if counter < unsigned(cycles_of_clk_stable)-1 then
                counter <= counter + 1;
            else
                counter_strobe <= '1';
                counter <= (others => '0');
            end if;
        end if;
    end process;

    process(clk_stable)
    begin
        if rising_edge(clk_stable) then
            -- diff the clk under test's phase at every counter strobe
            -- need to have at least cycles_of_clk_stable to be declared good
            counter_strobe_d1 <= counter_strobe;
            if counter_strobe = '1' then
                clk_target_phase_d1 <= unsigned(clk_target_phase);
                clk_target_diff <= unsigned(clk_target_phase) - clk_target_phase_d1;
            end if;
            if counter_strobe_d1 = '1' then
                if clk_target_diff >= unsigned(minimum_cycles_of_clk_under_test) then
                    clk_good_int <= '1';
                else
                    clk_good_int <= '0';
                end if;
            end if;
        end if;
    end process;

    clk_good <= clk_good_int;
end;
