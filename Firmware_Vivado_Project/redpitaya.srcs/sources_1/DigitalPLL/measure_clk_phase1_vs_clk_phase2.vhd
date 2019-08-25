library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- This provides a measurement of clk_target's phase in clk_ref's clock domain.
-- it uses a gray code counter that is clocked in clk_target's clock domain,
-- and read in clk_ref's clock domain.
-- the counter is then unwrapped to 16 bits of integer clock cycles.
entity measure_clk_phase1_vs_clk_phase2  is
generic (
    PHASE_BITS : integer := 16
); port (
    clk_ref          : in  std_logic;
    clk_target       : in  std_logic;
    
    clk_target_phase : out std_logic_vector(PHASE_BITS-1 downto 0)
    );
end entity;

architecture Behavioral of measure_clk_phase1_vs_clk_phase2 is

    constant GRAY_BITS : integer := 4; -- Fixed by our binary-to-gray conversion code.  Sets the maximum frequency ratio between clk_target and clk_ref that can be measured without aliasing
    signal counter_binary_target : std_logic_vector(GRAY_BITS-1 downto 0) := (others => '0');
    signal counter_gray_target   : std_logic_vector(GRAY_BITS-1 downto 0) := (others => '0');

    signal counter_gray_ref_reg1 : std_logic_vector(GRAY_BITS-1 downto 0) := (others => '0');
    signal counter_gray_ref_reg2 : std_logic_vector(GRAY_BITS-1 downto 0) := (others => '0');
    signal counter_gray_ref      : std_logic_vector(GRAY_BITS-1 downto 0) := (others => '0');

    signal counter_binary_ref        : std_logic_vector(GRAY_BITS-1 downto 0) := (others => '0');
    signal counter_binary_ref_d1     : std_logic_vector(GRAY_BITS-1 downto 0) := (others => '0');
    signal counter_binary_increments : unsigned(        GRAY_BITS-1 downto 0) := (others => '0');
    signal counter_unwrapped_ref     : unsigned(       PHASE_BITS-1 downto 0) := (others => '0');

begin
    ------------------------------------------------
    -- clk_target clock domain
    ------------------------------------------------
    -- binary counter
    process(clk_target)
    begin
        if rising_edge(clk_target) then
            counter_binary_target <= std_logic_vector(unsigned(counter_binary_target) + 1);
        end if;
    end process;
    -- convert binary counter to gray code:
    binary_to_gray_4bits_inst : entity work.binary_to_gray_4bits
    port map (
        clk      => clk_target,
        data_in  => counter_binary_target,
        data_out => counter_gray_target
    );

    ------------------------------------------------
    -- clk_ref clock domain
    ------------------------------------------------
    process(clk_ref)
    begin
        if rising_edge(clk_ref) then
            -- clock domain crossing registers
            counter_gray_ref_reg1 <= counter_gray_target;
            counter_gray_ref_reg2 <= counter_gray_ref_reg1;
            counter_gray_ref      <= counter_gray_ref_reg2;

            -- unwrap the counter from 4 to N bits:
            -- doing a standard "cumsum(diff(phi) modulo N_INPUT)" unwrapping algorithm
            counter_binary_ref_d1     <= counter_binary_ref;
            counter_binary_increments <= unsigned(counter_binary_ref) - unsigned(counter_binary_ref_d1); -- diff(phi) modulo 4
            counter_unwrapped_ref     <= counter_unwrapped_ref + counter_binary_increments;
        end if;
    end process;
    -- gray to binary conversion:
    gray_to_binary_4bits_inst : entity work.gray_to_binary_4bits
    port map (
        clk      => clk_ref,
        data_in  => counter_gray_ref,
        data_out => counter_binary_ref
    );

    -- assign output:
    clk_target_phase <= std_logic_vector(counter_unwrapped_ref);
end;
