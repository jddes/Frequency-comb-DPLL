----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    12:29:03 10/22/2013 
-- Design Name: 
-- Module Name:    DDC - Behavioral 
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
-- Description: 
--
-- Dependencies: 
--
-- Revision: 
-- Revision 0.01 - File Created
-- Additional Comments: 
--
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;


    entity DDC_wideband_filters is
    Generic(
        INPUT_DATA_WIDTH    : positive := 16;
        WRAPPED_PHASE_WIDTH : positive := 10;
        N_SHIFT_BASEBAND : integer := 7+8 -- this with IQ_monitor_gain's min value of 2^7 sets the minimum gain to 2^-8, mapping a full-range 16-bits signal into 8 bits
    );
    Port ( 
        rst                 : in  std_logic;
        clk                 : in  std_logic;
        clk_times_N         : in  std_logic;
        data_input          : in  std_logic_vector (INPUT_DATA_WIDTH-1 downto 0);
        -- Optional: the local oscillator can be generator outside of this module (selected by setting bUseExternalLO = 1)
        -- needs to have an amplitude equal to 2^15-1 peak (oscillates from +2^15-1 to -(2^15-1)).
        external_LO_cosine  : in  std_logic_vector (16-1 downto 0);
        external_LO_sine    : in  std_logic_vector (16-1 downto 0);

        -- Configuration port
        reference_frequency : in  std_logic_vector (47 downto 0);
        boxcar_filter_size  : in  std_logic_vector (11 downto 0);
        ddc_filter_select   : in  std_logic_vector (1 downto 0);    -- 0 means wideband (25 MHz) filter, 1 means narrowband (6 MHz), 2 means 16-taps minimum-phase fir
        bUseExternalLO      : in  std_logic; -- 0 means to use the LO DDS inside this module, 1 means to use the external LO inputs
        IQ_monitor_gain     : in  std_logic_vector(16-1 downto 0);      -- max usable is 2^15, sets the scale of the IQ monitor port output

        -- Reference tone output, goes to the ddr2 logger:
        ref_cosine_out      : out std_logic_vector (16-1 downto 0);
        ref_sine_out        : out std_logic_vector (16-1 downto 0);

        -- IQ monitor output, goes to the ddr2 logger:
        -- This is equal to the actual baseband IQ signal, times IQ_monitor_gain/2^N_SHIFT_BASEBAND and saturated to 8 bits signed.
        monitor_I : out std_logic_vector(8-1 downto 0);
        monitor_Q : out std_logic_vector(8-1 downto 0);


        -- Binary lock state: used to null the phase error to 0 instead of an arbitrary offset:
        lock                : in  std_logic;
        angleSelect         : in  std_logic_vector (3 downto 0);

        amplitude           : out std_logic_vector (WRAPPED_PHASE_WIDTH+2-1 downto 0);
        wrapped_phase       : out std_logic_vector (WRAPPED_PHASE_WIDTH-1   downto 0);
        inst_frequency      : out std_logic_vector (WRAPPED_PHASE_WIDTH-1   downto 0)
    );
    end entity;

architecture Behavioral of DDC_wideband_filters is
    --Coregen declarations
    -----------------------------------------------------------------------
    -- The Core which generates sine and cosine
    
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
    --Computes input*cos and input*sin
    COMPONENT input_multiplier
      PORT (
        clk : IN  std_logic;
        a   : IN  std_logic_vector(15 DOWNTO 0);
        b   : IN  std_logic_vector(15 DOWNTO 0);
        p   : OUT std_logic_vector(31 DOWNTO 0)
      );
    END COMPONENT;

    
    -- The core which computes the angle and the amplitude of the IQ signal
    COMPONENT angle_CORDIC
    PORT (
        aclk                    : IN  std_logic;
        s_axis_cartesian_tvalid : IN  std_logic;
        s_axis_cartesian_tdata  : IN  std_logic_vector(31 DOWNTO 0);    -- y_in, x_in, 16 bits each
        m_axis_dout_tvalid      : OUT std_logic;
        m_axis_dout_tdata       : OUT std_logic_vector(31 DOWNTO 0)       -- amplitude, phase, 12 bits each, sign-extended to 16
        
    );
    END COMPONENT;
    signal s_axis_cartesian_tdata   : std_logic_vector(32-1 downto 0);
    signal cordic_m_axis_dout_tdata : std_logic_vector(32-1 downto 0);

    -- Internal signals:
    -----------------------------------------------------------------------
    signal DDS_cosine_tmp : std_logic_vector(INPUT_DATA_WIDTH-1 downto 0);
    signal DDS_sine_tmp   : std_logic_vector(INPUT_DATA_WIDTH-1 downto 0);
    signal DDS_cosine     : std_logic_vector(INPUT_DATA_WIDTH-1 downto 0);
    signal DDS_sine       : std_logic_vector(INPUT_DATA_WIDTH-1 downto 0);
    
    -- High-pass filter signals:
    signal data_input_to_mult    : std_logic_vector(INPUT_DATA_WIDTH-1 downto 0);
    signal data_input_highpassed : std_logic_vector(INPUT_DATA_WIDTH-1 downto 0);

    -- Multipliers output signals 
    constant BIT_SHIFT_AFTER_MULT : positive := 15;    -- Divides the output of the filter by 2^BIT_SHIFT_AFTER_FILTER to keep gain approximately equal to 1.  Note that the filter has a DC gain equal to its length, while the product by cos has a gain of 1/2, so this value should be approx= log2(boxcar_filter_size/2)
    signal input_times_cos_wide   : std_logic_vector(32-1 downto 0) := (others => '0');
    signal input_times_sin_wide   : std_logic_vector(32-1 downto 0) := (others => '0');
    signal input_times_cos        : std_logic_vector(INPUT_DATA_WIDTH-1 downto 0) := (others => '0');
    signal input_times_sin        : std_logic_vector(INPUT_DATA_WIDTH-1 downto 0) := (others => '0');
    
    -- Filters signals
    constant BIT_SHIFT_AFTER_FILTER : positive := 4;    -- Divides the output of the filter by 2^BIT_SHIFT_AFTER_FILTER to keep gain approximately equal to 1.  Note that the filter has a DC gain equal to its length, while the product by cos has a gain of 1/2, so this value should be approx= log2(boxcar_filter_size/2)
    signal I_filtered_wide    : std_logic_vector(INPUT_DATA_WIDTH+1-1+5 downto 0);
    signal Q_filtered_wide    : std_logic_vector(INPUT_DATA_WIDTH+1-1+5 downto 0);
    signal I_filtered         : std_logic_vector(INPUT_DATA_WIDTH-1 downto 0);
    signal Q_filtered         : std_logic_vector(INPUT_DATA_WIDTH-1 downto 0);

    -- IQ monitor signals:
    signal I_filtered_mon  : signed(IQ_monitor_gain'length+I_filtered'length+1-1 downto 0) := (others => '0');
    signal I_filtered_mon2 : std_logic_vector(IQ_monitor_gain'length+I_filtered'length+1-1 downto 0) := (others => '0');
    signal Q_filtered_mon  : signed(IQ_monitor_gain'length+I_filtered'length+1-1 downto 0) := (others => '0');
    signal Q_filtered_mon2 : std_logic_vector(IQ_monitor_gain'length+I_filtered'length+1-1 downto 0) := (others => '0');
    
    -- Phase unwrapping signals
    signal wrapped_phase_cordic            : std_logic_vector(WRAPPED_PHASE_WIDTH+2-1 downto 0);
    signal wrapped_phase_internal          : std_logic_vector(WRAPPED_PHASE_WIDTH-1   downto 0) := (others => '0');
    signal wrapped_phase_internal_last     : std_logic_vector(WRAPPED_PHASE_WIDTH-1   downto 0) := (others => '0');
    signal wrapped_phase_internal_last2    : std_logic_vector(WRAPPED_PHASE_WIDTH-1   downto 0) := (others => '0');
    signal phase_offset, inst_freq_adjust  : signed(          WRAPPED_PHASE_WIDTH-1   downto 0) := (others => '0');
    signal inst_freq_internal              : std_logic_vector(WRAPPED_PHASE_WIDTH-1   downto 0) := (others => '0');
    
    signal lock_last : std_logic := '0';
--    signal unwrapped_phase_internal        : std_logic_vector(UNWRAPPED_PHASE_WIDTH-1 downto 0);

    attribute keep : string;
    attribute KEEP of I_filtered : signal is "TRUE";
    attribute KEEP of Q_filtered : signal is "TRUE";
    
    
    signal Q_quantized    : std_logic_vector(WRAPPED_PHASE_WIDTH-1 downto 0) := (others => '0');
    signal Q_limited_wide : std_logic_vector(INPUT_DATA_WIDTH-1 downto 0) := (others => '0');
    signal Q_limited      : std_logic_vector(WRAPPED_PHASE_WIDTH-1 downto 0) := (others => '0');
    constant Q_limit_min  : std_logic_vector(INPUT_DATA_WIDTH-1 downto 0) := std_logic_vector(to_signed(-2**(WRAPPED_PHASE_WIDTH-1),  INPUT_DATA_WIDTH));
    constant Q_limit_max  : std_logic_vector(INPUT_DATA_WIDTH-1 downto 0) := std_logic_vector(to_signed(2**(WRAPPED_PHASE_WIDTH-1)-1, INPUT_DATA_WIDTH));
    
    signal I_quantized    : std_logic_vector(WRAPPED_PHASE_WIDTH-1 downto 0) := (others => '0');
    signal I_limited_wide : std_logic_vector(INPUT_DATA_WIDTH-1 downto 0) := (others => '0');
    signal I_limited      : std_logic_vector(WRAPPED_PHASE_WIDTH-1 downto 0) := (others => '0');
    constant I_limit_min  : std_logic_vector(INPUT_DATA_WIDTH-1 downto 0) := std_logic_vector(to_signed(-2**(WRAPPED_PHASE_WIDTH-1),  INPUT_DATA_WIDTH));
    constant I_limit_max  : std_logic_vector(INPUT_DATA_WIDTH-1 downto 0) := std_logic_vector(to_signed(2**(WRAPPED_PHASE_WIDTH-1)-1, INPUT_DATA_WIDTH));
    
--    attribute KEEP of wrapped_phase_cordic2 : signal is "TRUE";

    signal bReferenceFrequencyIs0Hz : std_logic := '0';
begin

-- Compute cos() and sin(), or more precisely, round((2^15-1)*cos()) and round((2^15-1)*sin())
    LO_DDS_inst : LO_DDS
    port map (
    
        aclk                    => clk,
        s_axis_phase_tvalid     => '1',
        s_axis_phase_tdata      => reference_frequency,
        m_axis_data_tvalid      => open,
        m_axis_data_tdata       => lo_dds_m_axis_data_tdata,
        m_axis_phase_tvalid     => open,
        m_axis_phase_tdata      => open
    );
    DDS_cosine_tmp  <= lo_dds_m_axis_data_tdata(15 downto 0);
    DDS_sine_tmp    <= lo_dds_m_axis_data_tdata(31 downto 16);
    
    -- this is to replace the reference exponential by just a real constant to change the behavior to a baseband lock
    -- added by Hugo
    -- JDD 2018-01-09: Also added option of using an external LO signal
    process (DDS_cosine_tmp, DDS_sine_tmp, bReferenceFrequencyIs0Hz, external_LO_cosine, external_LO_sine, bUseExternalLO) is
    begin
        if bUseExternalLO = '1' then
            -- LO is sourced externally
            DDS_cosine <= external_LO_cosine;
            DDS_sine   <= external_LO_sine;
        elsif bReferenceFrequencyIs0Hz = '1' then
            -- LO is at DC: this is to do a baseband lock.  Replace LO with a constant at a known phase in the complex plane (on the real axis in this case).
            DDS_cosine <= std_logic_vector(to_signed(2**(INPUT_DATA_WIDTH-1)-1, INPUT_DATA_WIDTH));
            DDS_sine   <= std_logic_vector(to_signed(0                        , INPUT_DATA_WIDTH));
        else
            -- normal mode: The LO is sourced internally
            DDS_cosine <= DDS_cosine_tmp;
            DDS_sine   <= DDS_sine_tmp;
        end if;

    end process;

    -- To detect the LO at 0 Hz condition in a pipelined manner:
    process (clk)
    begin
        if reference_frequency = std_logic_vector(to_signed(0, reference_frequency'length)) then
            bReferenceFrequencyIs0Hz <= '1';
        else
            bReferenceFrequencyIs0Hz <= '0';
        end if;
    end process;
                
    ref_cosine_out <= DDS_cosine;
    ref_sine_out   <= DDS_sine;
    
    -- First-order, high-pass, IIR filter, about 7 kHz of cutoff frequency on the input data:
    first_order_IIR_highpass_filter_inst: entity work.first_order_IIR_highpass_filter 
    PORT MAP (
        clk      => clk,
        data_in  => data_input,
        data_out => data_input_highpassed
    );
    
    -- Bypass HPF if user wants a baseband lock
    data_input_to_mult <=   data_input when bReferenceFrequencyIs0Hz = '1' else
                            data_input_highpassed;

    -- Multiply with input signal
    input_multiplier_I : input_multiplier
    PORT MAP (
        clk => clk,
        a   => data_input_to_mult,
        b   => DDS_cosine,
        p   => input_times_cos_wide
    );

    input_multiplier_Q : input_multiplier
    PORT MAP (
        clk => clk,
        a   => data_input_to_mult,
        b   => DDS_sine,
        p   => input_times_sin_wide
    );

    -- Cancel the multiplier gain and round the multiplication product.
    process (clk)
    begin
        if rising_edge(clk) then
            input_times_cos <= std_logic_vector(resize(shift_right(
                                        signed(input_times_cos_wide) + to_signed(2**(BIT_SHIFT_AFTER_MULT-1), input_times_cos_wide'length)
                                        , BIT_SHIFT_AFTER_MULT), input_times_cos'length));

            input_times_sin <= std_logic_vector(resize(shift_right(
                                        signed(input_times_sin_wide) + to_signed(2**(BIT_SHIFT_AFTER_MULT-1), input_times_cos_wide'length)
                                        , BIT_SHIFT_AFTER_MULT), input_times_cos'length));
        end if;
    end process;


    -- Low-pass filter the result of the multiplication to yield I and Q signals
    -- These filters have a DC gain of 1.
    ddc_frontend_lowpass_filter_inst_I: entity work.ddc_frontend_lowpass_filter
    GENERIC MAP (
        INPUT_SIZE => input_times_cos'length
    )
    PORT MAP (
        rst           => rst,
        clk           => clk,
        clk_times_N   => clk_times_N,
        data_input    => input_times_cos,
        filter_select => ddc_filter_select,
        data_output   => I_filtered
    );

    ddc_frontend_lowpass_filter_inst_Q: entity work.ddc_frontend_lowpass_filter
    GENERIC MAP (
        INPUT_SIZE => input_times_sin'length
    )
    PORT MAP (
        rst           => rst,
        clk           => clk,
        clk_times_N   => clk_times_N,
        data_input    => input_times_sin,
        filter_select => ddc_filter_select,
        data_output   => Q_filtered
    );

    -- Monitoring operations for the baseband IQ signal:
    -- We multiply by IQ_monitor_gain/2^N_SHIFT_BASEBAND and saturate to 8 bits signed.
    process (clk)
    begin
        if rising_edge(clk) then
            -- Apply gain of IQ_monitor_gain/2^N_SHIFT_BASEBAND:
            I_filtered_mon <= shift_right(
                                            resize(signed(I_filtered)*signed(IQ_monitor_gain), I_filtered'length+IQ_monitor_gain'length+1)
                                            + to_signed(2**(N_SHIFT_BASEBAND-1)              , I_filtered'length+IQ_monitor_gain'length+1)
                                                , N_SHIFT_BASEBAND);
            Q_filtered_mon <= shift_right(
                                            resize(signed(Q_filtered)*signed(IQ_monitor_gain), I_filtered'length+IQ_monitor_gain'length+1)
                                            + to_signed(2**(N_SHIFT_BASEBAND-1)              , I_filtered'length+IQ_monitor_gain'length+1)
                                                , N_SHIFT_BASEBAND);
            -- Add extra pipeline register to help timing:
            I_filtered_mon2 <= std_logic_vector(I_filtered_mon);
            Q_filtered_mon2 <= std_logic_vector(Q_filtered_mon);

        end if;
    end process;
    -- Saturate to 8 bits
    resize_with_saturation_I_mon_inst : entity work.resize_with_saturation
    Generic map (
        N_INPUT => I_filtered_mon'length,
        N_OUTPUT => monitor_I'length
    ) Port map (
        clk               => clk,--: in  STD_LOGIC;
        synchronous_clear => '0',--: in std_logic;
        data_in           => I_filtered_mon2,--: in  STD_LOGIC_VECTOR (N_INPUT-1 downto 0);
        railed_positive   => open,--: out std_logic;
        railed_negative   => open,--: out std_logic;
        data_out          => monitor_I--: out  STD_LOGIC_VECTOR (N_OUTPUT-1 downto 0)
    );
    resize_with_saturation_Q_mon_inst : entity work.resize_with_saturation
    Generic map (
        N_INPUT => Q_filtered_mon'length,
        N_OUTPUT => monitor_Q'length
    ) Port map (
        clk               => clk,--: in  STD_LOGIC;
        synchronous_clear => '0',--: in std_logic;
        data_in           => Q_filtered_mon2,--: in  STD_LOGIC_VECTOR (N_INPUT-1 downto 0);
        railed_positive   => open,--: out std_logic;
        railed_negative   => open,--: out std_logic;
        data_out          => monitor_Q--: out  STD_LOGIC_VECTOR (N_OUTPUT-1 downto 0)
    );

    
    -- For debugging of the CORDIC: Send the LO directly to the CORDIC
--    I_filtered <= DDS_cosine(15) & DDS_cosine(15) & DDS_cosine(15 downto 0+2);
--    Q_filtered <= DDS_sine(15) & DDS_sine(15) & DDS_sine(15 downto 0+2);

-- Compute the angle and the abs() of the IQ signal:
    CORDIC_inst : angle_CORDIC
    PORT MAP (
        aclk => clk,
        s_axis_cartesian_tvalid => '1',
        s_axis_cartesian_tdata => s_axis_cartesian_tdata,
        m_axis_dout_tvalid => open,
        m_axis_dout_tdata => cordic_m_axis_dout_tdata       -- amplitude, phase, 12 bits each, sign-extended to 16
    );
    s_axis_cartesian_tdata <= (Q_filtered & I_filtered);
    wrapped_phase_cordic    <= cordic_m_axis_dout_tdata(27 downto 16);
    amplitude               <= cordic_m_axis_dout_tdata(11 downto 0);
      
    -- The CORDIC always outputs two useless bits in the phase vector (see datasheet)
    with angleSelect select
    wrapped_phase_internal <= wrapped_phase_cordic(wrapped_phase_internal'range) when b"0000",
                              Q_quantized                                        when b"0001",
                              Q_limited                                          when b"0010",
                              I_quantized                                        when b"0011",
                              I_limited                                          when b"0100",
                              (others => '0')                                    when others;
  
  
  
    quadrature_quantizer : entity work.quantizer
    generic map (
        DI_WIDTH => Q_filtered'length,
        DO_WIDTH => Q_quantized'length
    ) port map (
        clk => clk,
        di  => Q_filtered,
        do  => Q_quantized
    );
    
    quadrature_limiter : entity work.limiter
    generic map (
        DATA_WIDTH => Q_filtered'length
    ) port map (
        clk    => clk,
        di     => Q_filtered,
        di_min => Q_limit_min,
        di_max => Q_limit_max,
        do     => Q_limited_wide
    );
    Q_limited <= Q_limited_wide(WRAPPED_PHASE_WIDTH-1 downto 0);
    
    
    inphase_quantizer : entity work.quantizer
    generic map (
        DI_WIDTH => I_filtered'length,
        DO_WIDTH => I_quantized'length
    ) port map (
        clk => clk,
        di  => I_filtered,
        do  => I_quantized
    );
    
    inphase_limiter : entity work.limiter
    generic map (
        DATA_WIDTH => I_filtered'length
    ) port map (
        clk    => clk,
        di     => I_filtered,
        di_min => I_limit_min,
        di_max => I_limit_max,
        do     => I_limited_wide
    );
    I_limited <= I_limited_wide(WRAPPED_PHASE_WIDTH-1 downto 0);
  
  
    -- Differentiate the phase to yield the instantenous frequency (modulo 2*pi to remove phase discontinuities)
    process (clk)
    begin
        if rising_edge(clk) then
            if rst = '1' then
                inst_freq_internal <= (others => '0');
                wrapped_phase_internal_last <= (others => '0');
            else
                wrapped_phase_internal_last  <= wrapped_phase_internal;    -- one sample delay
                wrapped_phase_internal_last2 <= wrapped_phase_internal_last;
                inst_freq_internal <= std_logic_vector(signed(wrapped_phase_internal) - signed(wrapped_phase_internal_last) + inst_freq_adjust);
                
                -- this is to ensure lock at 0 phase error, instead of at some arbitrary offset
                lock_last <= lock;
                if lock = '1' and lock_last = '0' then
                    -- we just turned on the lock: remember the offset:
                    phase_offset <= signed(wrapped_phase_internal_last2);
                    inst_freq_adjust <= (others => '0');
                    
                else
                    -- trickle the offsets to the inst freq:
                    if phase_offset > 0 then
                        phase_offset <= phase_offset - 1;
                        inst_freq_adjust <= to_signed(1, inst_freq_adjust'length);
                    elsif phase_offset < 0 then
                        phase_offset <= phase_offset + 1;
                        inst_freq_adjust <= to_signed(-1, inst_freq_adjust'length);
                    else
                        inst_freq_adjust <= (others => '0');
                    end if;
                end if;
                
                
            end if;
        end if;
    end process;

    -- Assign outputs:
    wrapped_phase  <= wrapped_phase_internal;
    inst_frequency <= inst_freq_internal;
    
end Behavioral;

