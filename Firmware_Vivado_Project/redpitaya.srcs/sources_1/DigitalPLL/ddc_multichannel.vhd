library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


entity ddc_multichannel is
Generic (
    DATA_WIDTH : integer := 14;
    FREQ_WIDTH : integer := 48;
    IQ_WIDTH   : integer := 16;
    PHASE_WIDTH : integer := 14
);
port (
    clk         : in  std_logic;
    clk_times_N : in  std_logic;

    -- data input:
    data1_in : in  std_logic_vector(DATA_WIDTH-1 downto 0);
    data2_in : in  std_logic_vector(DATA_WIDTH-1 downto 0);
    data3_in : in  std_logic_vector(DATA_WIDTH-1 downto 0);
    data4_in : in  std_logic_vector(DATA_WIDTH-1 downto 0);
    -- config input:
    freq1_in : in  std_logic_vector(FREQ_WIDTH-1 downto 0);
    freq2_in : in  std_logic_vector(FREQ_WIDTH-1 downto 0);
    freq3_in : in  std_logic_vector(FREQ_WIDTH-1 downto 0);
    freq4_in : in  std_logic_vector(FREQ_WIDTH-1 downto 0);

    freq1_in_offset : in  std_logic_vector(FREQ_WIDTH-1 downto 0);
    freq2_in_offset : in  std_logic_vector(FREQ_WIDTH-1 downto 0);
    freq3_in_offset : in  std_logic_vector(FREQ_WIDTH-1 downto 0);
    freq4_in_offset : in  std_logic_vector(FREQ_WIDTH-1 downto 0);
    

    -- IQ outputs, for diagnositcs purposes
    -- each of these contain in sequence: DATA_I, DATA_Q, DONT_CARE, DONT_CARE, DONT_CARE, DONT_CARE, where DONT_CARE are to be ignored
    -- clk_enable_IQ_out strobes this pattern periodically: 1, 1, 0, 0, 0, 0, for an average rate of clk/2.
    -- sync_IQ_out strobes this pattern periodically: 1, 0, 0, 0, 0, 0, and should be used to sync up the data saving with the I value
    -- the IQ data's rate is clk/6
    clk_enable_IQ_out : out std_logic;
    sync_IQ_out       : out std_logic;
    IQ1_out           : out std_logic_vector(IQ_WIDTH-1 downto 0);
    IQ2_out           : out std_logic_vector(IQ_WIDTH-1 downto 0);
    IQ3_out           : out std_logic_vector(IQ_WIDTH-1 downto 0);
    IQ4_out           : out std_logic_vector(IQ_WIDTH-1 downto 0);

    -- debugging outputs
    DDS_cosine1    : out std_logic_vector(16-1 downto 0);
    DDS_sine1      : out std_logic_vector(16-1 downto 0);

    -- wrapped phase outputs, at clk rate/6
    clk_enable_out : out std_logic;
    phi1 : out std_logic_vector(PHASE_WIDTH-1 downto 0);
    phi2 : out std_logic_vector(PHASE_WIDTH-1 downto 0);
    phi3 : out std_logic_vector(PHASE_WIDTH-1 downto 0);
    phi4 : out std_logic_vector(PHASE_WIDTH-1 downto 0)

    );
end entity;

architecture Behavioral of ddc_multichannel is

    signal freq1_in_summed : std_logic_vector(FREQ_WIDTH-1 downto 0);
    signal freq2_in_summed : std_logic_vector(FREQ_WIDTH-1 downto 0);
    signal freq3_in_summed : std_logic_vector(FREQ_WIDTH-1 downto 0);
    signal freq4_in_summed : std_logic_vector(FREQ_WIDTH-1 downto 0);

    signal data_mixer1_real, data_mixer1_imag : std_logic_vector(DATA_WIDTH-1 downto 0);
    signal data_mixer2_real, data_mixer2_imag : std_logic_vector(DATA_WIDTH-1 downto 0);
    signal data_mixer3_real, data_mixer3_imag : std_logic_vector(DATA_WIDTH-1 downto 0);
    signal data_mixer4_real, data_mixer4_imag : std_logic_vector(DATA_WIDTH-1 downto 0);

    constant DATA_WIDTH_LPF : integer := 16;
    signal lpf_clk_enable : std_logic := '0';
    signal data_lpf1_real, data_lpf1_imag : std_logic_vector(DATA_WIDTH_LPF-1 downto 0);
    signal data_lpf2_real, data_lpf2_imag : std_logic_vector(DATA_WIDTH_LPF-1 downto 0);
    signal data_lpf3_real, data_lpf3_imag : std_logic_vector(DATA_WIDTH_LPF-1 downto 0);
    signal data_lpf4_real, data_lpf4_imag : std_logic_vector(DATA_WIDTH_LPF-1 downto 0);

    -- small FSM to mutliplex the IQ data to the diagnostics output:
    constant SYNC_BYTES : std_logic_vector(IQ_WIDTH-1 downto 0) := x"ABCD";
    type state_DIAG_type is (STATE_DIAG_I, STATE_DIAG_Q);
    signal FSM_diag_state      : state_DIAG_type := STATE_DIAG_I;
    signal clk_enable_IQ_int : std_logic := '0';
    signal sync_IQ_int : std_logic := '0';
    signal IQ1_int : std_logic_vector(IQ_WIDTH-1 downto 0) := (others => '0');
    signal IQ2_int : std_logic_vector(IQ_WIDTH-1 downto 0) := (others => '0');
    signal IQ3_int : std_logic_vector(IQ_WIDTH-1 downto 0) := (others => '0');
    signal IQ4_int : std_logic_vector(IQ_WIDTH-1 downto 0) := (others => '0');

    -- another small FSM, this time to multiplex the data into the arctangent core:
    type state_atan_type is (STATE_ATAN_CH1, STATE_ATAN_CH2, STATE_ATAN_CH3, STATE_ATAN_CH4);
    signal FSM_ATAN_state      : state_atan_type := STATE_ATAN_CH1;

    -- arctan signals
    signal atan_clk_enable : std_logic := '0';
    signal atan_chan1_sync : std_logic := '0';
    signal atan_data_real, atan_data_imag : std_logic_vector(DATA_WIDTH_LPF-1 downto 0) := (others => '0');
    signal atan_out_clk_enable : std_logic := '0';
    signal atan_chan1_out_sync : std_logic := '0';
    signal atan_phi : std_logic_vector(14-1 downto 0) := (others => '0');
    signal atan_abs : std_logic_vector(16-1 downto 0) := (others => '0');

    -- The core which computes the angle and the amplitude of the IQ signal
    component angle_cordic
    port (
        aclk                    : in  std_logic;
        s_axis_cartesian_tvalid : in  std_logic;
        s_axis_cartesian_tuser  : in std_logic_vector(0 downto 0);
        s_axis_cartesian_tdata  : in  std_logic_vector(31 downto 0);    -- y_in, x_in, 16 bits each
        m_axis_dout_tvalid      : out std_logic;
        m_axis_dout_tuser       : out std_logic_vector(0 downto 0);
        m_axis_dout_tdata       : out std_logic_vector(31 downto 0)       -- amplitude, phase, 16 bits each, phase has 14 useful bits only
    );
    end component;
    signal s_axis_cartesian_tdata   : std_logic_vector(32-1 downto 0);
    signal s_axis_cartesian_tuser   : std_logic_vector(1-1 downto 0);
    signal cordic_m_axis_dout_tdata : std_logic_vector(32-1 downto 0);
    signal cordic_m_axis_dout_tuser : std_logic_vector(1-1 downto 0);

    -- another small FSM, this time to multiplex the data out of the arctangent core:
    type state_atan_out_type is (STATE_ATAN_OUT_CH1, STATE_ATAN_OUT_CH2, STATE_ATAN_OUT_CH3, STATE_ATAN_OUT_CH4);
    signal FSM_ATAN_out_state      : state_atan_out_type := STATE_ATAN_OUT_CH1;

    signal clk_enable_phi_int : std_logic := '0';
    signal phi1_int : std_logic_vector(PHASE_WIDTH-1 downto 0) := (others => '0');
    signal phi2_int : std_logic_vector(PHASE_WIDTH-1 downto 0) := (others => '0');
    signal phi3_int : std_logic_vector(PHASE_WIDTH-1 downto 0) := (others => '0');
    signal phi4_int : std_logic_vector(PHASE_WIDTH-1 downto 0) := (others => '0');

begin

    ddc_mixer_inst1 : entity work.ddc_mixer
    generic map (
        DATA_WIDTH => DATA_WIDTH,
        FREQ_WIDTH => FREQ_WIDTH
    ) port map (
        clk           => clk,
        data_in       => data1_in,
        freq_in       => freq1_in_summed,
        DDS_cosine    => DDS_cosine1,
        DDS_sine      => DDS_sine1,
        data_out_real => data_mixer1_real,
        data_out_imag => data_mixer1_imag
    );
    ddc_mixer_inst2 : entity work.ddc_mixer
    generic map (
        DATA_WIDTH => DATA_WIDTH,
        FREQ_WIDTH => FREQ_WIDTH
    ) port map (
        clk           => clk,
        data_in       => data2_in,
        freq_in       => freq2_in_summed,
        data_out_real => data_mixer2_real,
        data_out_imag => data_mixer2_imag
    );
    ddc_mixer_inst3 : entity work.ddc_mixer
    generic map (
        DATA_WIDTH => DATA_WIDTH,
        FREQ_WIDTH => FREQ_WIDTH
    ) port map (
        clk           => clk,
        data_in       => data3_in,
        freq_in       => freq3_in_summed,
        data_out_real => data_mixer3_real,
        data_out_imag => data_mixer3_imag
    );
    ddc_mixer_inst4 : entity work.ddc_mixer
    generic map (
        DATA_WIDTH => DATA_WIDTH,
        FREQ_WIDTH => FREQ_WIDTH
    ) port map (
        clk           => clk,
        data_in       => data4_in,
        freq_in       => freq4_in_summed,
        data_out_real => data_mixer4_real,
        data_out_imag => data_mixer4_imag
    );

    process(clk)
    begin
        if rising_edge(clk) then
            freq1_in_summed <= std_logic_vector(signed(freq1_in) + signed(freq1_in_offset));
            freq2_in_summed <= std_logic_vector(signed(freq2_in) + signed(freq2_in_offset));
            freq3_in_summed <= std_logic_vector(signed(freq3_in) + signed(freq3_in_offset));
            freq4_in_summed <= std_logic_vector(signed(freq4_in) + signed(freq4_in_offset));
        end if;
    end process;

    -- filters and decimates by 6
    N_times_clk_FIR_wrapper_inst: entity work.N_times_clk_FIR_multichannel
    port map (
        clk_times_1    => clk,
        clk_times_N    => clk_times_N,
        data1_in       => data_mixer1_real,
        data2_in       => data_mixer1_imag,
        data3_in       => data_mixer2_real,
        data4_in       => data_mixer2_imag,
        data5_in       => data_mixer3_real,
        data6_in       => data_mixer3_imag,
        data7_in       => data_mixer4_real,
        data8_in       => data_mixer4_imag,
        
        clk_enable_out => lpf_clk_enable,
        data1_out      => data_lpf1_real,
        data2_out      => data_lpf1_imag,
        data3_out      => data_lpf2_real,
        data4_out      => data_lpf2_imag,
        data5_out      => data_lpf3_real,
        data6_out      => data_lpf3_imag,
        data7_out      => data_lpf4_real,
        data8_out      => data_lpf4_imag
    );

    -- for diagnostics:
    -- multiplex the IQ data into a sequential output stream:
    process( clk )
    begin
        if rising_edge(clk) then
            clk_enable_IQ_int <= '0'; -- default outputs
            sync_IQ_int <= '0';

            case FSM_diag_state is
                when STATE_DIAG_I =>
                    clk_enable_IQ_int <= lpf_clk_enable;
                    sync_IQ_int <= lpf_clk_enable;
                    IQ1_int <= data_lpf1_real;
                    IQ2_int <= data_lpf2_real;
                    IQ3_int <= data_lpf3_real;
                    IQ4_int <= data_lpf4_real;
                    if lpf_clk_enable = '1' then
                        FSM_diag_state <= STATE_DIAG_Q;
                    end if;
                when STATE_DIAG_Q =>
                    clk_enable_IQ_int <= '1';
                    IQ1_int <= data_lpf1_imag;
                    IQ2_int <= data_lpf2_imag;
                    IQ3_int <= data_lpf3_imag;
                    IQ4_int <= data_lpf4_imag;
                    FSM_diag_state <= STATE_DIAG_I;
                when others =>
                    FSM_diag_state <= STATE_DIAG_I;
            end case;
            
        end if;
    end process;

    clk_enable_IQ_out <= clk_enable_IQ_int;
    sync_IQ_out <= sync_IQ_int;
    IQ1_out <= IQ1_int;
    IQ2_out <= IQ2_int;
    IQ3_out <= IQ3_int;
    IQ4_out <= IQ4_int;

    -- prepare arctan inputs:
    -- multiplex all four channels sequentially
    process( clk )
    begin
        if rising_edge(clk) then
            case FSM_ATAN_state is
                when STATE_ATAN_CH1 =>
                    atan_clk_enable <= lpf_clk_enable;
                    atan_chan1_sync <= '1';
                    atan_data_real <= data_lpf1_real;
                    atan_data_imag <= data_lpf1_imag;
                    if lpf_clk_enable='1' then
                        FSM_ATAN_state <= STATE_ATAN_CH2;
                    end if;

                when STATE_ATAN_CH2 =>
                    atan_clk_enable <= '1';
                    atan_chan1_sync <= '0';
                    atan_data_real <= data_lpf2_real;
                    atan_data_imag <= data_lpf2_imag;
                    FSM_ATAN_state <= STATE_ATAN_CH3;

                when STATE_ATAN_CH3 =>
                    atan_clk_enable <= '1';
                    atan_chan1_sync <= '0';
                    atan_data_real <= data_lpf3_real;
                    atan_data_imag <= data_lpf3_imag;
                    FSM_ATAN_state <= STATE_ATAN_CH4;

                when STATE_ATAN_CH4 =>
                    atan_clk_enable <= '1';
                    atan_chan1_sync <= '0';
                    atan_data_real <= data_lpf4_real;
                    atan_data_imag <= data_lpf4_imag;
                    FSM_ATAN_state <= STATE_ATAN_CH1;

                when others =>
                    FSM_ATAN_state <= STATE_ATAN_CH1;
            end case;

            
        end if;
    end process;

    -- demux the atan outputs back to parallel
    process(clk)
    begin
        if rising_edge(clk) then
            clk_enable_phi_int <= '0'; -- default

            if atan_chan1_out_sync = '1' then
                FSM_ATAN_out_state <= STATE_ATAN_OUT_CH2;
                if atan_out_clk_enable = '1' then
                    phi1_int <= atan_phi;
                end if;
            else

                case FSM_ATAN_out_state is
                    when STATE_ATAN_OUT_CH1 =>
                        -- this is handled by the "atan_chan1_out_sync" condition above

                    when STATE_ATAN_OUT_CH2 =>
                        if atan_out_clk_enable = '1' then
                            phi2_int <= atan_phi;
                        end if;
                        FSM_ATAN_out_state <= STATE_ATAN_OUT_CH3;

                    when STATE_ATAN_OUT_CH3 =>
                        if atan_out_clk_enable = '1' then
                            phi3_int <= atan_phi;
                        end if;
                        FSM_ATAN_out_state <= STATE_ATAN_OUT_CH4;

                    when STATE_ATAN_OUT_CH4 =>
                        if atan_out_clk_enable = '1' then
                            phi4_int <= atan_phi;
                            clk_enable_phi_int <= '1';
                        end if;
                        FSM_ATAN_out_state <= STATE_ATAN_OUT_CH1;

                    when others =>
                        FSM_ATAN_out_state <= STATE_ATAN_OUT_CH1;
                end case;
            end if;

        end if;
    end process;

    CORDIC_inst : angle_CORDIC
    PORT MAP (
        aclk                    => clk,
        s_axis_cartesian_tvalid => atan_clk_enable,
        s_axis_cartesian_tuser  => s_axis_cartesian_tuser,
        s_axis_cartesian_tdata  => s_axis_cartesian_tdata,
        m_axis_dout_tvalid      => atan_out_clk_enable,
        m_axis_dout_tuser       => cordic_m_axis_dout_tuser,
        m_axis_dout_tdata       => cordic_m_axis_dout_tdata       -- amplitude, phase, 12 bits each, sign-extended to 16
    );
    s_axis_cartesian_tdata <= (atan_data_imag & atan_data_real);
    atan_phi <= cordic_m_axis_dout_tdata(14+16-1 downto 16);
    atan_abs <= cordic_m_axis_dout_tdata(15 downto 0);
    s_axis_cartesian_tuser(0) <= atan_chan1_sync;
    atan_chan1_out_sync <= cordic_m_axis_dout_tuser(0);

    -- assign outputs:
    clk_enable_out <= clk_enable_phi_int;
    phi1 <= phi1_int;
    phi2 <= phi2_int;
    phi3 <= phi3_int;
    phi4 <= phi4_int;

end;
