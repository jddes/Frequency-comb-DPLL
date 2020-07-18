library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


entity ddc_mixer is
Generic (
    DATA_WIDTH : integer := 14;
    FREQ_WIDTH : integer := 48;
    LO_WIDTH : integer := 16 -- can't change this
);
port (
    clk           : in  std_logic;

    data_in       : in  std_logic_vector(DATA_WIDTH-1 downto 0);
    freq_in       : in  std_logic_vector(FREQ_WIDTH-1 downto 0);
    -- debugging outputs
    DDS_cosine    : out std_logic_vector(LO_WIDTH-1 downto 0);
    DDS_sine      : out std_logic_vector(LO_WIDTH-1 downto 0);

    data_out_real : out std_logic_vector(DATA_WIDTH-1 downto 0);
    data_out_imag : out std_logic_vector(DATA_WIDTH-1 downto 0)

    );
end entity;

architecture Behavioral of ddc_mixer is

    --type state_type is (STATE_IDLE, STATE_POS_OFFSET, STATE_ZERO1, STATE_NEG_OFFSET, STATE_ZERO2);
    --signal FSM_state      : state_type := STATE_IDLE;
    signal data_highpassed :  std_logic_vector(DATA_WIDTH-1 downto 0) := (others => '0');

    signal lo_dds_m_axis_data_tdata : std_logic_vector(31 downto 0);
    signal DDS_cosine_int : std_logic_vector(LO_WIDTH-1 downto 0);
    signal DDS_sine_int   : std_logic_vector(LO_WIDTH-1 downto 0);

    --Computes input*cos and input*sin
    component input_multiplier
    port (
        clk : in  std_logic;
        a   : in  std_logic_vector(16-1 downto 0);
        b   : in  std_logic_vector(14-1 downto 0);
        p   : out std_logic_vector(14-1 downto 0)
    );
    end component;

    component lo_dds
    port (
        aclk                : in  std_logic;
        s_axis_phase_tvalid : in  std_logic;
        s_axis_phase_tdata  : in  std_logic_vector(47 downto 0);  -- phase increments
        m_axis_data_tvalid  : out std_logic;
        m_axis_data_tdata   : out std_logic_vector(31 downto 0)   -- cos and sine (16 bits signed each)
    );
    end component;

begin

    -- First-order, high-pass, IIR filter, about 7 kHz of cutoff frequency on the input data:
    first_order_IIR_highpass_filter_inst: entity work.first_order_IIR_highpass_filter 
    generic map (
        N_DATA_BITS => DATA_WIDTH
    ) port map (
        clk      => clk,
        data_in  => data_in,
        data_out => data_highpassed
    );

    -- Compute cos() and sin(), or more precisely, round((2^15-1)*cos()) and round((2^15-1)*sin())
    LO_DDS_inst : LO_DDS
    port map (
        aclk                    => clk,
        s_axis_phase_tvalid     => '1',
        s_axis_phase_tdata      => freq_in,
        m_axis_data_tvalid      => open,
        m_axis_data_tdata       => lo_dds_m_axis_data_tdata
    );
    DDS_cosine_int <= lo_dds_m_axis_data_tdata(15 downto 0);
    DDS_sine_int   <= lo_dds_m_axis_data_tdata(31 downto 16);

    -- Multiply with input signal and cancel the 2^15 gain from the amplitude of the LO cos and sin, using symmetric rounding
    input_multiplier_I : input_multiplier
    PORT MAP (
        clk => clk,
        a   => DDS_cosine_int,
        b   => data_highpassed,
        p   => data_out_real
    );
    input_multiplier_Q : input_multiplier
    PORT MAP (
        clk => clk,
        a   => DDS_sine_int,
        b   => data_highpassed,
        p   => data_out_imag
    );
    DDS_cosine <= DDS_cosine_int;
    DDS_sine <= DDS_sine_int;

end;
