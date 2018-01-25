library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity ddc_external_ref_generator_testbench is
end ddc_external_ref_generator_testbench;

architecture behavior of ddc_external_ref_generator_testbench is
    constant INPUT_DATA_WIDTH    : positive := 16;
    constant WRAPPED_PHASE_WIDTH : positive := 14;

    -- Inputs
    signal rst : std_logic := '0';
    signal clk : std_logic := '0';
    signal clk_times_n : std_logic := '0';
    signal data_input : std_logic_vector (input_data_width-1 downto 0) := (others => '0');

    
    signal ddc_filter_select : std_logic_vector (1 downto 0) := b"01";
    signal k : std_logic_vector(25-1 downto 0) := std_logic_vector(to_signed(2**20, 25));   -- output frequency should be k/2^20.
    
    -- Outputs
    signal ref_cosine_out : std_logic_vector (16-1 downto 0);
    signal ref_sine_out : std_logic_vector (16-1 downto 0);
    
    -- Clock period definition
    constant clk_period : time := 5 ns;
    constant clk_period_faster : time := 1.666666666666667 ns;  -- not exactly 5/3 of course, but the clocks should stay in sync long enough for this testbench

    -- We instantiate a DDS just for testing the core:
    component LO_DDS
        port (
        aclk                : IN  std_logic;
        s_axis_phase_tvalid : IN  std_logic;
        s_axis_phase_tdata  : IN  std_logic_vector(47 DOWNTO 0);  -- phase increments
        m_axis_data_tvalid  : OUT std_logic;
        m_axis_data_tdata   : OUT std_logic_vector(31 DOWNTO 0);  -- cos and sine (16 bits signed each)
        m_axis_phase_tvalid : OUT std_logic;
        m_axis_phase_tdata  : OUT std_logic_vector(47 DOWNTO 0)  -- output phase, not used in this module
        );
    end component;
    signal lo_dds_m_axis_data_tdata : std_logic_vector(31 DOWNTO 0);
    signal DDS_cosine     : std_logic_vector(INPUT_DATA_WIDTH-1 downto 0);
    signal DDS_sine       : std_logic_vector(INPUT_DATA_WIDTH-1 downto 0);


    signal input_frequency     : std_logic_vector (47 downto 0) := b"000100000000000000000000000000000000000000000000"; -- dec2bin(round(2^48/16), 48)
    signal reference_frequency : std_logic_vector (47 downto 0) := b"000100101000111101011100001010001111010111000011"; -- dec2bin(round(2^48*(1/16 + 1/100)), 48)
begin

    -- Unit under test
    ddc_external_ref_generator_inst : entity work.ddc_external_ref_generator
    port map (
        rst                 => rst,
        clk                 => clk,
        clk_times_n         => clk_times_n,
        data_input          => data_input,
        reference_frequency => reference_frequency,
        ddc_filter_select   => ddc_filter_select,
        k                   => k,
        ref_cosine_out      => ref_cosine_out,
        ref_sine_out        => ref_sine_out
    );

    -- Clock process definition for "clk"
    process
    begin
        clk <= '0';
        wait for clk_period/2;
        clk <= '1';
        wait for clk_period/2;
    end process;

    -- Clock process definition for "clk_times_n"
    process
    begin
        clk_times_n <= '0';
        wait for clk_period_faster/2;
        clk_times_n <= '1';
        wait for clk_period_faster/2;
    end process;


    -- DDS used for generating the input stimulus
    LO_DDS_inst : LO_DDS
    port map (
        aclk                    => clk,
        s_axis_phase_tvalid     => '1',
        s_axis_phase_tdata      => input_frequency,
        m_axis_data_tvalid      => open,
        m_axis_data_tdata       => lo_dds_m_axis_data_tdata,
        m_axis_phase_tvalid     => open,
        m_axis_phase_tdata      => open
    );
    DDS_cosine     <= lo_dds_m_axis_data_tdata(15 downto 0);
    DDS_sine       <= lo_dds_m_axis_data_tdata(31 downto 16);

    data_input     <= std_logic_vector(shift_right(signed(DDS_cosine), 2));

    -- Stimulus process
    process
    begin
        ---- to test the LPF
        --wait for clk_period*100;
        --wait until rising_edge(clk);
        --data_input     <= std_logic_vector(to_signed(1000, data_input'length));

        -- change the frequency ratio to x2:
        wait for clk_period*1000;
        wait until rising_edge(clk);
            k <= std_logic_vector(to_signed(2*2**20, 25));   -- output frequency should be k/2^20.
        

        -- change the frequency ratio to x4.5:
        wait for clk_period*1000;
        wait until rising_edge(clk);
            k <= std_logic_vector(to_signed(9*2**(20-1), 25));   -- output frequency should be k/2^20.




        wait;

        ---- Example of a for loop:
        --wait until new_data_available = '1';
        --for I in 0 to 1023 loop
        --    wait until rising_edge(clk);
        --        read_enable <= '1';
        --    wait until rising_edge(clk);
        --        read_enable <= '0';
        --    wait for clk_period*5;
        --end loop;
    end process;
    
end;
