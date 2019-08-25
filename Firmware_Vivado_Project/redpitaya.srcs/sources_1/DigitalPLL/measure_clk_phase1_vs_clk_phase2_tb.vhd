library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity measure_clk_phase1_vs_clk_phase2_testbench is
end measure_clk_phase1_vs_clk_phase2_testbench;

architecture behavior of measure_clk_phase1_vs_clk_phase2_testbench is

    -- measure_clk_phase1_vs_clk_phase2 signals
    -- Generics as constants
    constant PHASE_BITS : integer := 16;
    -- Inputs
    signal clk_ref    : std_logic := '0';
    signal clk_target : std_logic := '0';
    -- Outputs
    signal clk_target_phase : std_logic_vector(PHASE_BITS-1 downto 0);

    -- testbench signals:
    signal clk_target_phase_true : std_logic_vector(PHASE_BITS-1 downto 0) := (others => '0');

    -- Clock period definition
    constant clk_period_ref    : time := 4 ns;
    constant clk_period_target : time := 5.05 ns;
begin

    -- Unit under test
    measure_clk_phase1_vs_clk_phase2_inst : entity work.measure_clk_phase1_vs_clk_phase2
    generic map (
        PHASE_BITS => PHASE_BITS
    ) port map (
        clk_ref          => clk_ref,
        clk_target       => clk_target,
        clk_target_phase => clk_target_phase
    );

    -- Clock process definition for "clk_ref"
    process
    begin
        clk_ref <= '0';
        wait for clk_period_ref/2;
        clk_ref <= '1';
        wait for clk_period_ref/2;
    end process;

    -- Clock process definition for "clk_target"
    process
    begin
        clk_target <= '0';
        wait for clk_period_target/2;
        clk_target <= '1';
        wait for clk_period_target/2;
    end process;

    process(clk_target)
    begin
        if rising_edge(clk_target) then
            clk_target_phase_true <= std_logic_vector(unsigned(clk_target_phase_true) + 1);
        end if;
    end process;
    
end;
