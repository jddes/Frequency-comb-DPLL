library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- This provides a measurement of clk_target's phase in clk_ref's clock domain.
-- it uses a gray code counter that is clocked in clk_target's clock domain,
-- and read in clk_ref's clock domain.
-- the counter is then unwrapped to 16 bits of integer clock cycles.
entity digital_clock_freq_counter  is
generic (
    N_gate_time : std_logic_vector(32-1 downto 0) := std_logic_vector(to_unsigned(250e6, 32)) -- fixed for clk_ref = 250 MHz, 1 sec gate time
); port (
    clk_ref           : in  std_logic;
    clk_target        : in  std_logic;
    
    -- simplue output port, just the results with a clk enable.
    output_clk_enable : out std_logic;
    freq_count_out    : out std_logic_vector(64-1 downto 0);

    -- output port, specific for the Zynq:
    -- this is meant to go to 3x AXI4 registers
    -- the counter's 64 bits data is split into 3 parts,
    -- and there is a index number associated with reach result,
    -- this is packed in the following way into the 32 bits registers:
    -- labelling each nibble of the counter's 64 bits output:
    -- FEDC_BA98_7654_3210
    -- out_reg_to_axi1:
    -- II54_3210
    -- IIBA_9876
    -- IIXX_FEDC
    -- "II" is the 8-bits index counter, which increments by 1 everytime the counter data changes (on each output_clk_enable assertion)
    -- "UU" means unused nibbles (currently 0)
    out_reg_to_axi1 : out std_logic_vector(32-1 downto 0);
    out_reg_to_axi2 : out std_logic_vector(32-1 downto 0);
    out_reg_to_axi3 : out std_logic_vector(32-1 downto 0)

    );
end entity;

architecture Behavioral of digital_clock_freq_counter is

    constant PHASE_BITS : integer := 10; -- set to match the input size of the frequency counter
    signal clk_target_phase : std_logic_vector(PHASE_BITS-1 downto 0) := (others => '0');
    signal clk_target_phase_d1 : std_logic_vector(PHASE_BITS-1 downto 0) := (others => '0');
    signal clk_target_phase_diffed : std_logic_vector(PHASE_BITS-1 downto 0) := (others => '0');


    signal output_clk_enable_internal : std_logic := '0';
    signal freq_count_out_internal    : std_logic_vector(64-1 downto 0) := (others => '0');
    signal freq_count_out_internal_d1 : std_logic_vector(64-1 downto 0) := (others => '0');
    
    signal data_index_counter : unsigned(8-1 downto 0) := (others => '0');

begin

    measure_clk_phase1_vs_clk_phase2_inst : entity work.measure_clk_phase1_vs_clk_phase2
    generic map (
        PHASE_BITS => PHASE_BITS
    ) port map (
        clk_ref          => clk_ref,
        clk_target       => clk_target,
        clk_target_phase => clk_target_phase
    );

    -- diff the phase since the counters expects diffed phase
    process(clk_ref)
    begin
        if rising_edge(clk_ref) then
            clk_target_phase_d1     <= clk_target_phase;
            clk_target_phase_diffed <= std_logic_vector(unsigned(clk_target_phase) - unsigned(clk_target_phase_d1));
        end if;
    end process;

    dual_type_frequency_counter_inst : entity work.dual_type_frequency_counter
    port map (
        rst                              => '0',
        clk                              => clk_ref,
        data_input                       => clk_target_phase_diffed,
        N_gate_time                      => N_gate_time,
        N_times_faster_gate_time         => (others => '0'), -- unused feature
        triangular_mode                  => '1',
        output_clk_enable_N_times_faster => open, -- unused feature
        data_output                      => freq_count_out_internal,
        output_clk_enable                => output_clk_enable_internal
    );



    -- data index counter
    process(clk_ref)
    begin
        if rising_edge(clk_ref) then
            if output_clk_enable_internal = '1' then
                data_index_counter         <= data_index_counter + 1;
                freq_count_out_internal_d1 <= freq_count_out_internal;
            end if;
        end if;
    end process;



    -- assign outputs:
    output_clk_enable <= output_clk_enable_internal;
    freq_count_out    <= freq_count_out_internal;

    -- labelling each nibble of the counter's 64 bits output:
    -- FEDC_BA98_7654_3210
    -- out_reg_to_axi1:
    -- II54_3210
    -- IIBA_9876
    -- IIXX_FEDC
    -- "II" is the 8-bits index counter, which increments by 1 everytime the counter data changes (on each output_clk_enable assertion)
    -- "UU" means unused nibbles (currently 0)
    out_reg_to_axi1(24-1 downto 0) <= freq_count_out_internal_d1(   24-1 downto 0);
    out_reg_to_axi2(24-1 downto 0) <= freq_count_out_internal_d1(   48-1 downto 24);
    out_reg_to_axi3(16-1 downto 0) <= freq_count_out_internal_d1(   64-1 downto 48);

    out_reg_to_axi3(24-1 downto 16) <= x"00"; -- unused

    out_reg_to_axi1(32-1 downto 24) <= std_logic_vector(data_index_counter);
    out_reg_to_axi2(32-1 downto 24) <= std_logic_vector(data_index_counter);
    out_reg_to_axi3(32-1 downto 24) <= std_logic_vector(data_index_counter);

    
end;
