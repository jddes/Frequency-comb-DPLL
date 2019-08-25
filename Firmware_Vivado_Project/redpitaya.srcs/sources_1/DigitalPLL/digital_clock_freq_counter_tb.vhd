library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity digital_clock_freq_counter_tb is
end digital_clock_freq_counter_tb;

architecture behavior of digital_clock_freq_counter_tb is

    -- digital_clock_freq_counter signals
    -- Generics as constants
    constant N_gate_time : std_logic_vector(32-1 downto 0) := std_logic_vector(to_unsigned(1000, 32)); -- much lower number for simulation
    -- Inputs
    signal clk_ref    : std_logic := '0';
    signal clk_target : std_logic := '0';
    -- Outputs
    signal output_clk_enable : std_logic;
    signal freq_count_out, freq_count_out_d1, freq_count_out_d2 : std_logic_vector(64-1 downto 0);
    signal freq_count_out_reconstructed    : unsigned(64-1 downto 0);
    signal out_reg_to_axi1   : std_logic_vector(32-1 downto 0);
    signal out_reg_to_axi2   : std_logic_vector(32-1 downto 0);
    signal out_reg_to_axi3   : std_logic_vector(32-1 downto 0);

    -- testbench signals:
    signal data_index_recovered1_d1 : unsigned(8-1 downto 0) := (others => '0');
    signal data_index_recovered1    : unsigned(8-1 downto 0) := (others => '0');
    signal data_index_recovered2    : unsigned(8-1 downto 0) := (others => '0');
    signal data_index_recovered3    : unsigned(8-1 downto 0) := (others => '0');

    signal freq_count_matches, data_index_match, data_index_is_ok : std_logic := '0';

    -- Clock period definition
    constant clk_period_ref    : time := 4 ns;
    constant clk_period_target : time := 5.05 ns;
begin

    -- Unit under test
    digital_clock_freq_counter_inst : entity work.digital_clock_freq_counter
    generic map (
        N_gate_time => N_gate_time
    ) port map (
        clk_ref           => clk_ref,
        clk_target        => clk_target,
        output_clk_enable => output_clk_enable,
        freq_count_out    => freq_count_out,
        out_reg_to_axi1   => out_reg_to_axi1,
        out_reg_to_axi2   => out_reg_to_axi2,
        out_reg_to_axi3   => out_reg_to_axi3
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

    freq_count_out_reconstructed <=            resize(unsigned(out_reg_to_axi1 and x"00FF_FFFF"), 64)      + 
                                    shift_left(resize(unsigned(out_reg_to_axi2 and x"00FF_FFFF"), 64), 24) + 
                                    shift_left(resize(unsigned(out_reg_to_axi3 and x"0000_FFFF"), 64), 48);

    data_index_recovered1        <= resize(shift_right(unsigned(out_reg_to_axi1 and x"FF00_0000"), 24), 8);
    data_index_recovered2        <= resize(shift_right(unsigned(out_reg_to_axi2 and x"FF00_0000"), 24), 8);
    data_index_recovered3        <= resize(shift_right(unsigned(out_reg_to_axi3 and x"FF00_0000"), 24), 8);

    -- check that:
    --1. freq_count_out_reconstructed matches freq_count_out (delayed by 1 clk cycle)
    --2. data_index_recovered changes by 1 everytime freq_count_out_reconstructed changes, and never changes when freq_count_out_reconstructed doesn't.
    --3. all three data indexes are always equal.
    process(clk_ref)
    begin
        if rising_edge(clk_ref) then
            freq_count_out_d1 <= freq_count_out;
            freq_count_out_d2 <= freq_count_out_d1;

            data_index_recovered1_d1 <= data_index_recovered1;

            if freq_count_out_d1 /= freq_count_out_d2 then
                -- freq out changed. data_index must change by 1.
                if unsigned(data_index_recovered1) - unsigned(data_index_recovered1_d1) = 1 then
                    data_index_is_ok <= '1';
                else
                    data_index_is_ok <= '0';
                end if;
            else
                -- freq_out did not change. data_index must not change either.
                if data_index_recovered1 = data_index_recovered1_d1 then
                    data_index_is_ok <= '1';
                else
                    data_index_is_ok <= '0';
                end if;
            end if;
        end if;
    end process;

    

    freq_count_matches <=      '1' when freq_count_out_reconstructed = unsigned(freq_count_out_d1)
                          else '0';

    data_index_match   <=      '1' when (data_index_recovered1 = data_index_recovered1) and
                                        (data_index_recovered2 = data_index_recovered2) and
                                        (data_index_recovered3 = data_index_recovered3)
                          else '0';

end;
