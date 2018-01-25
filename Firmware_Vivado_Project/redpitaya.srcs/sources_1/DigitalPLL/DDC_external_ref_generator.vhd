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


entity DDC_external_ref_generator is
Generic(
    INPUT_DATA_WIDTH    : positive := 16;
    WRAPPED_PHASE_WIDTH : positive := 14
);
Port ( 
    rst                 : in  std_logic;
    clk                 : in  std_logic;
    data_input          : in  std_logic_vector (INPUT_DATA_WIDTH-1 downto 0);

    -- Configuration port
    reference_frequency : in  std_logic_vector (47 downto 0);
    ddc_filter_select   : in  std_logic_vector (1 downto 0);    -- 0 means wideband (25 MHz) filter, 1 means narrowband (6 MHz), 2 means 16-taps minimum-phase fir
    -- output frequency is equal to input frequency * k/N, where N = 2^20.
    k                   : in  std_logic_vector(25-1 downto 0); 


    -- Reference tone output, goes to the other DDC
    ref_cosine_out      : out std_logic_vector (16-1 downto 0);
    ref_sine_out        : out std_logic_vector (16-1 downto 0)

);
end entity;

architecture Behavioral of DDC_external_ref_generator is
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
    component input_multiplier
      port (
        clk : IN  std_logic;
        a   : IN  std_logic_vector(15 DOWNTO 0);
        b   : IN  std_logic_vector(15 DOWNTO 0);
        p   : OUT std_logic_vector(31 DOWNTO 0)
      );
    end component;

    
    -- The core which computes the angle and the amplitude of the IQ signal
    component angle_CORDIC_14bits
    port (
        aclk                    : IN  std_logic;
        s_axis_cartesian_tvalid : IN  std_logic;
        s_axis_cartesian_tdata  : IN  std_logic_vector(31 DOWNTO 0);    -- y_in, x_in, 16 bits each
        m_axis_dout_tvalid      : OUT std_logic;
        m_axis_dout_tdata       : OUT std_logic_vector(31 DOWNTO 0)       -- amplitude, phase, 12 bits each, sign-extended to 16
        
    );
    end component;
    signal s_axis_cartesian_tdata   : std_logic_vector(32-1 downto 0);
    signal cordic_m_axis_dout_tdata : std_logic_vector(32-1 downto 0);

    component complex_mult_16x16
      port (
        aclk : IN std_logic;
        s_axis_a_tvalid : IN std_logic;
        s_axis_a_tdata : IN std_logic_vector(31 DOWNTO 0);
        s_axis_b_tvalid : IN std_logic;
        s_axis_b_tdata : IN std_logic_vector(31 DOWNTO 0);
        m_axis_dout_tvalid : OUT std_logic;
        m_axis_dout_tdata : OUT std_logic_vector(79 DOWNTO 0)
      );
    end component;
    signal complex_mult_m_axis_dout_tdata : std_logic_vector(79 DOWNTO 0);


    component Ref_generator_DDS_2
    port (
        aclk : IN STD_LOGIC;
        s_axis_phase_tvalid : IN STD_LOGIC;
        s_axis_phase_tdata : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
        m_axis_data_tvalid : OUT STD_LOGIC;
        m_axis_data_tdata : OUT STD_LOGIC_VECTOR(31 DOWNTO 0)
    );
    end component;
    signal ref_gen_dds_s_axis_phase_tdata : std_logic_vector(15 DOWNTO 0) := (others => '0');
    signal ref_gen_dds_m_axis_dout_tdata : std_logic_vector(31 DOWNTO 0);

    -- Internal signals:
    -----------------------------------------------------------------------
    signal DDS_cosine     : std_logic_vector(INPUT_DATA_WIDTH-1 downto 0);
    signal DDS_sine       : std_logic_vector(INPUT_DATA_WIDTH-1 downto 0);
    signal DDS_cosine_reg : std_logic_vector(INPUT_DATA_WIDTH-1 downto 0) := (others => '0');
    signal DDS_sine_reg   : std_logic_vector(INPUT_DATA_WIDTH-1 downto 0) := (others => '0');
    
    -- High-pass filter signals:
    signal data_input_to_mult    : std_logic_vector(INPUT_DATA_WIDTH-1 downto 0);
    signal data_input_highpassed : std_logic_vector(INPUT_DATA_WIDTH-1 downto 0);

    -- Multipliers output signals 
    constant BIT_SHIFT_AFTER_MULT : positive := 15;    -- Divides the output of the mult by 2^BIT_SHIFT_AFTER_MULT to keep gain approximately equal to 1.  Note that the product by cos has a gain of 1/2
    signal input_times_cos_wide   : std_logic_vector(32-1 downto 0) := (others => '0');
    signal input_times_sin_wide   : std_logic_vector(32-1 downto 0) := (others => '0');
    signal input_times_cos        : std_logic_vector(INPUT_DATA_WIDTH-1 downto 0) := (others => '0');
    signal input_times_sin        : std_logic_vector(INPUT_DATA_WIDTH-1 downto 0) := (others => '0');
    
    -- Filters signals
    signal I_filtered         : std_logic_vector(INPUT_DATA_WIDTH-1 downto 0);
    signal Q_filtered         : std_logic_vector(INPUT_DATA_WIDTH-1 downto 0);

    -- Signals after the complex multiplier:
    constant BIT_SHIFT_AFTER_MULT2 : positive := 15;    -- Divides the output of the complex mult by 2^BIT_SHIFT_AFTER_MULT2 to keep gain approximately equal to 1.
    signal bandpass_I_wide   : std_logic_vector(33-1 downto 0) := (others => '0');
    signal bandpass_Q_wide   : std_logic_vector(33-1 downto 0) := (others => '0');
    signal bandpass_I        : std_logic_vector(INPUT_DATA_WIDTH-1 downto 0) := (others => '0');
    signal bandpass_Q        : std_logic_vector(INPUT_DATA_WIDTH-1 downto 0) := (others => '0');
    
    -- Phase unwrapping signals
    signal wrapped_phase_cordic            : std_logic_vector(WRAPPED_PHASE_WIDTH+2-1 downto 0);
    signal wrapped_phase_internal          : std_logic_vector(WRAPPED_PHASE_WIDTH-1 downto 0) := (others => '0');
    signal wrapped_phase_internal_last     : std_logic_vector(WRAPPED_PHASE_WIDTH-1 downto 0) := (others => '0');
    signal inst_freq_internal              : std_logic_vector(WRAPPED_PHASE_WIDTH-1 downto 0) := (others => '0');
    
--    signal unwrapped_phase_internal        : std_logic_vector(UNWRAPPED_PHASE_WIDTH-1 downto 0);

    attribute keep : string;
    attribute KEEP of I_filtered : signal is "TRUE";
    attribute KEEP of Q_filtered : signal is "TRUE";
    
    -- Signals used for scaling the frequency by k/N
    signal k_reg             : std_logic_vector(25-1 downto 0) := (others => '0');
    signal inst_freq_times_k : signed(14+25-1 downto 0) := (others => '0');

    constant PHI_TIMES_K_BITS            : integer := 48;
    constant PHI_TIMES_K_GUARD_BITS      : integer := 2; -- numbers of bits reserved to detect overflow.  I think only 1 is necessary but it doesn't hurt to put more.
    constant LOG2_M2_PHI_TIMES_K_MODULUS : integer := PHI_TIMES_K_BITS-PHI_TIMES_K_GUARD_BITS;
    signal phi_times_k                         : signed(PHI_TIMES_K_BITS  -1 downto 0) := (others => '0');
    signal phi_times_k_over_N                  : signed(PHI_TIMES_K_BITS  -1 downto 0) := (others => '0');
    signal phi_times_k_over_N_last             : signed(PHI_TIMES_K_BITS  -1 downto 0) := (others => '0');
    signal phi_times_k_over_N_diffed           : signed(PHI_TIMES_K_BITS+1-1 downto 0) := (others => '0');
    signal phi_times_k_over_N_adjusted         : signed(PHI_TIMES_K_BITS  -1 downto 0) := (others => '0');
    signal phi_times_k_over_N_adjusted_wrapped : signed(14-1 downto 0) := (others => '0');

    
    -- These two are just for debugging purposes:
    signal phi_times_k_over_N_adjusted_last : signed(48-1 downto 0) := (others => '0');
    signal dphi_times_k_over_N_adjusted     : signed(48-1 downto 0) := (others => '0');

    signal bPositiveOverlow     : std_logic := '0';
    signal bNegativeOverlow     : std_logic := '0';
    signal bPositiveOverlow_reg : std_logic := '0';
    signal bNegativeOverlow_reg : std_logic := '0';



    constant LOG2_N : integer := 18;    -- N = 2^18.
    constant DIVIDE_BY_N_ROUNDING_CONSTANT : integer := LOG2_N-1;
    

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
    DDS_cosine     <= lo_dds_m_axis_data_tdata(15 downto 0);
    DDS_sine       <= lo_dds_m_axis_data_tdata(31 downto 16);

    
    -- First-order, high-pass, IIR filter, about 7 kHz of cutoff frequency on the input data:
    first_order_IIR_highpass_filter_inst: entity work.first_order_IIR_highpass_filter 
    PORT MAP (
        clk      => clk,
        data_in  => data_input,
        data_out => data_input_highpassed
    );
    
    -- Always apply the HPF
    data_input_to_mult <= data_input_highpassed;

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
    ddc_frontend_lowpass_filter_inst_I: entity work.ddc_frontend_lowpass_filter_no_fir
    GENERIC MAP (
        INPUT_SIZE => input_times_cos'length
    )
    PORT MAP (
        rst           => rst,
        clk           => clk,
        data_input    => input_times_cos,
        filter_select => ddc_filter_select,
        data_output   => I_filtered
    );

    ddc_frontend_lowpass_filter_inst_Q: entity work.ddc_frontend_lowpass_filter_no_fir
    GENERIC MAP (
        INPUT_SIZE => input_times_sin'length
    )
    PORT MAP (
        rst           => rst,
        clk           => clk,
        data_input    => input_times_sin,
        filter_select => ddc_filter_select,
        data_output   => Q_filtered
    );

    -- Re-multiply the baseband I and Q signals with the LO.
    -- This is now a complex * complex multiplication so it requires more resources (3 real multiplications + 2 sums: done in 3 DSP48 slices)
    complex_mult_16x16_inst : complex_mult_16x16
    port map (
        aclk               => clk, --: IN std_logic;
        s_axis_a_tvalid    => '1', --: IN std_logic;
        s_axis_a_tdata     => (Q_filtered & I_filtered), --: IN std_logic_vector(31 DOWNTO 0);
        s_axis_b_tvalid    => '1', --: IN std_logic;
        s_axis_b_tdata     => (DDS_sine_reg & DDS_cosine_reg), --: IN std_logic_vector(31 DOWNTO 0);
        m_axis_dout_tvalid => open, --: OUT std_logic;
        m_axis_dout_tdata  => complex_mult_m_axis_dout_tdata --: OUT std_logic_vector(79 DOWNTO 0)
      );

    bandpass_I_wide <= complex_mult_m_axis_dout_tdata(72 downto 40);
    bandpass_Q_wide <= complex_mult_m_axis_dout_tdata(32 downto  0);

    -- Register on the LO signals and implement a complex conjugation operation:
    process (clk)
    begin
        if rising_edge(clk) then
            DDS_cosine_reg <= DDS_cosine;
            DDS_sine_reg   <= std_logic_vector(-signed(DDS_sine));
        end if;
    end process;

    -- Cancel the multiplier gain and round the multiplication product.
    -- This can technically wrap, but we don't want to operate so close to saturation anyway so I won't bother putting in an explicit saturation
    process (clk)
    begin
        if rising_edge(clk) then
            bandpass_I <= std_logic_vector(resize(shift_right(
                                        signed(bandpass_I_wide) + to_signed(2**(BIT_SHIFT_AFTER_MULT2-1), bandpass_I_wide'length)
                                        , BIT_SHIFT_AFTER_MULT2), bandpass_I'length));

            bandpass_Q <= std_logic_vector(resize(shift_right(
                                        signed(bandpass_Q_wide) + to_signed(2**(BIT_SHIFT_AFTER_MULT2-1), bandpass_I_wide'length)
                                        , BIT_SHIFT_AFTER_MULT2), bandpass_I'length));
        end if;
    end process;



    -- Compute the angle and the abs() of the bandpass IQ signal:
    CORDIC_inst : angle_CORDIC_14bits
    PORT MAP (
        aclk => clk,
        s_axis_cartesian_tvalid => '1',
        s_axis_cartesian_tdata => s_axis_cartesian_tdata,
        m_axis_dout_tvalid => open,
        m_axis_dout_tdata => cordic_m_axis_dout_tdata       -- amplitude, phase, 12 bits each, sign-extended to 16
    );
    s_axis_cartesian_tdata  <= (bandpass_Q & bandpass_I);
    wrapped_phase_cordic    <= cordic_m_axis_dout_tdata(31 downto 16);
    --amplitude               <= cordic_m_axis_dout_tdata(15 downto 0);

    -- The CORDIC always outputs two useless bits in the phase vector (see datasheet)
    wrapped_phase_internal <= wrapped_phase_cordic(wrapped_phase_internal'range);

  
    -- Differentiate the phase to yield the instantenous frequency (modulo 2*pi to remove phase discontinuities)
    process (clk)
    begin
        if rising_edge(clk) then
            if rst = '1' then
                inst_freq_internal          <= (others => '0');
                wrapped_phase_internal_last <= (others => '0');
            else
                wrapped_phase_internal_last  <= wrapped_phase_internal;    -- one sample delay
                inst_freq_internal <= std_logic_vector(signed(wrapped_phase_internal) - signed(wrapped_phase_internal_last));
            end if;
        end if;
    end process;

    -- Starting from here is a chain of manipulations on the phase increments to yield a multiplication of the input frequency by k/N, where k is an arbitrary integer between 1 and 2^24, and N is a power of two, here chosen as 2^24/16 = 2^20.
    -- The denominator value of 16 was chosen so that for a reference input frequency of 10 MHz, we can hit more than the full range of useful frequencies: 16*10MHz = 160 MHz, which is way past Nyquist


    process (clk)
        variable temp_phi : signed(PHI_TIMES_K_BITS-1 downto 0);
    begin
        if rising_edge(clk) then
            k_reg <= k; -- input reg to help timing
            bPositiveOverlow <= '0';    -- default values
            bNegativeOverlow <= '0';    -- default values

            -- 1st pipeline stage:
            -----------------------------------------------
            inst_freq_times_k <= signed(inst_freq_internal) * signed(k_reg);    -- 14x25, should map to a DSP48 slice.

            -- 2nd pipeline stage:
            -----------------------------------------------
            -- Accumulate the phase while keeping track of overflow (wrapping):
            temp_phi := phi_times_k + resize(inst_freq_times_k, phi_times_k'length);
            phi_times_k <= resize(temp_phi(LOG2_M2_PHI_TIMES_K_MODULUS-1 downto 0), PHI_TIMES_K_BITS);   -- compute modulo result
            -- Detect overflow conditions:

            if temp_phi > shift_left(to_signed(1, PHI_TIMES_K_BITS), LOG2_M2_PHI_TIMES_K_MODULUS-1)-1 then
                -- positive overflow
                bPositiveOverlow <= '1';
            elsif temp_phi < shift_left(to_signed(-1, PHI_TIMES_K_BITS), LOG2_M2_PHI_TIMES_K_MODULUS-1) then
                -- negative overflow
                bPositiveOverlow <= '0';
            end if;

            -- 3rd pipeline stage:
            -----------------------------------------------
            -- Compute phi_times_k divided by N: since N is a power of 2, this is just a right_shift with addition of the proper rounding constant
            phi_times_k_over_N <= shift_right(phi_times_k + DIVIDE_BY_N_ROUNDING_CONSTANT, LOG2_N);
            bPositiveOverlow_reg <= bPositiveOverlow;
            bNegativeOverlow_reg <= bNegativeOverlow;

            -- 4th pipeline stage:
            -----------------------------------------------
            -- unwrap phi_times_k_over_N based on the new modulus: cumsum(diff(phi*k/N1) modulo 2^(M2-N1) )
            phi_times_k_over_N_last <= phi_times_k_over_N;
            phi_times_k_over_N_diffed <= resize(phi_times_k_over_N, phi_times_k_over_N_diffed'length) - resize(phi_times_k_over_N_last, phi_times_k_over_N_diffed'length); -- diff()
            phi_times_k_over_N_adjusted <= phi_times_k_over_N_adjusted
                                            + resize(phi_times_k_over_N_diffed(LOG2_M2_PHI_TIMES_K_MODULUS-LOG2_N-1 downto 0), phi_times_k_over_N_adjusted'length);-- cumsum( diff() modulo ...)

            ---- Adjust the result of phi_times_k/N if phi_times_k overflowed in the numbers that we used
            --if bPositiveOverlow_reg = '1' then
            --    -- Compensate for a positive overflow (we subtracted M2/N)
            --    phi_times_k_over_N_adjusted <= phi_times_k_over_N + to_signed(2**(LOG2_M2_PHI_TIMES_K_MODULUS-LOG2_N), PHI_TIMES_K_BITS);
            --elsif bNegativeOverlow_reg = '1' then
            --    -- Compensate for a negative overflow (we added M2/N)
            --    phi_times_k_over_N_adjusted <= phi_times_k_over_N - to_signed(2**(LOG2_M2_PHI_TIMES_K_MODULUS-LOG2_N), PHI_TIMES_K_BITS);
            --else
            --    -- no overflow happened, we can take the division result as-is
            --    phi_times_k_over_N_adjusted <= phi_times_k_over_N;
            --end if;
            ----phi_times_k_over_N_adjusted_wrapped <= resize(phi_times_k_over_N_adjusted, (phi_times_k_over_N_adjusted_wrapped'length));
            phi_times_k_over_N_adjusted_wrapped <= phi_times_k_over_N_adjusted(phi_times_k_over_N_adjusted_wrapped'range);
            ---- just for debugging:
            --phi_times_k_over_N_adjusted_wrapped <= phi_times_k_over_N_adjusted_wrapped + 1;


            dphi_times_k_over_N_adjusted <= resize(phi_times_k_over_N_adjusted, 48) - resize(phi_times_k_over_N_adjusted_last, 48);
            phi_times_k_over_N_adjusted_last <= phi_times_k_over_N_adjusted;
        end if;
    end process;




    -- Send the phase to the reference generator DDS:
    Ref_generator_DDS_2_inst : Ref_generator_DDS_2
    port map (
        aclk                => clk,--: IN STD_LOGIC;
        s_axis_phase_tvalid => '1',--: IN STD_LOGIC;
        s_axis_phase_tdata  => ref_gen_dds_s_axis_phase_tdata,--: IN STD_LOGIC_VECTOR(15 DOWNTO 0);
        m_axis_data_tvalid  => open,--: OUT STD_LOGIC;
        m_axis_data_tdata   => ref_gen_dds_m_axis_dout_tdata--: OUT STD_LOGIC_VECTOR(31 DOWNTO 0)
    );
    ref_gen_dds_s_axis_phase_tdata(13 downto 0) <= std_logic_vector(phi_times_k_over_N_adjusted_wrapped);
    ref_gen_dds_s_axis_phase_tdata(15 downto 14) <= (others => '0');

    -- Assign outputs:
    ref_cosine_out  <= ref_gen_dds_m_axis_dout_tdata(15 downto 0);
    ref_sine_out    <= ref_gen_dds_m_axis_dout_tdata(31 downto 16);
    
end Behavioral;

