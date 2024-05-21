library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


entity multichannel_freq_counter_top is
generic (
    DATA_WIDTH    : integer := 14;
    FREQ_WIDTH    : integer := 48;
    IQ_WIDTH      : integer := 16;
    COUNTER_WIDTH : integer := 32;
    PHASE_WIDTH   : integer := 14;
    DDS_WIDTH     : integer := 48


); port (
    clk                   : in  std_logic;
    clk_times_N           : in  std_logic;
    
    -- data input:
    data1_in              : in  std_logic_vector(DATA_WIDTH-1 downto 0);
    data2_in              : in  std_logic_vector(DATA_WIDTH-1 downto 0);
    
    -- Data logger port:
    LoggerData_clk_enable : out std_logic;
    LoggerData            : out std_logic_vector(16-1 downto 0);
    LoggerIsWriting       : in  std_logic;

    -- this is used to update AD9912 registers directly
    -- the way we access each individual AD9912 is a bit peculiar because of how we shared
    -- all the SCK and CSB signals on the board (only SDIOx is different for each):
    -- the register address is always set to an invalid value 
    -- except for the chip that we want to write to,
    -- hence the shared write enable and value signals,
    -- but not addresses
    AD9912_register_write    : out std_logic; -- rising edge on this starts the transfer at the next opportuinity
    AD9912_register_address1 : out std_logic_vector(13-1 downto 0);
    AD9912_register_address2 : out std_logic_vector(13-1 downto 0);
    AD9912_register_address3 : out std_logic_vector(13-1 downto 0);
    AD9912_register_address4 : out std_logic_vector(13-1 downto 0);
    AD9912_register_value    : out std_logic_vector( 8-1 downto 0);
    DDS_SPI_enables          : out std_logic_vector(16-1 downto 0);

    -- monitors actual clock mode:
    clk_int_or_ext_actual   : in  std_logic;
    clk_int_or_ext_desired  : in  std_logic;
    clk_ext_good            : in  std_logic;
    
    -- data output:
    DACout1               : out std_logic_vector(16-1 downto 0);
    DACout2               : out std_logic_vector(16-1 downto 0);
    
    DDS_clk_enable        : out std_logic;
    DDSout1               : out std_logic_vector(DDS_WIDTH-1 downto 0);
    DDSout2               : out std_logic_vector(DDS_WIDTH-1 downto 0);
    DDSout3               : out std_logic_vector(DDS_WIDTH-1 downto 0);
    DDSout4               : out std_logic_vector(DDS_WIDTH-1 downto 0);

    -- CPU interface
    sys_addr              : in  std_logic_vector(32-1 downto 0);   -- bus address
    sys_wdata             : in  std_logic_vector(32-1 downto 0);   -- bus write data
    sys_wen               : in  std_logic;   -- bus write enable
    sys_ren               : in  std_logic;   -- bus read enable
    sys_rdata             : out std_logic_vector(32-1 downto 0);  -- bus read data
    sys_err               : out std_logic;  -- bus error indicator
    sys_ack               : out std_logic   -- bus acknowledge signal


    );
end entity;

architecture Behavioral of multichannel_freq_counter_top is

    signal phi_clk_enable : std_logic := '0';
    signal phi1, phi2, phi3, phi4 : std_logic_vector(PHASE_WIDTH-1 downto 0) := (others => '0');
    signal iq_clk_enable, iq_sync : std_logic := '0';
    signal IQ1, IQ2, IQ3, IQ4 : std_logic_vector(IQ_WIDTH-1 downto 0) := (others => '0');

    signal DACout1_int, DACout2_int : std_logic_vector(DACout1'length-1 downto 0) := (others => '0');

    signal selected_output : std_logic_vector(LoggerData'length+2-1 downto 0) := (others => '0');

    -- config registers:
    signal freq1_in : std_logic_vector(FREQ_WIDTH-1 downto 0) := (others => '0');
    signal freq2_in : std_logic_vector(FREQ_WIDTH-1 downto 0) := (others => '0');
    signal freq3_in : std_logic_vector(FREQ_WIDTH-1 downto 0) := (others => '0');
    signal freq4_in : std_logic_vector(FREQ_WIDTH-1 downto 0) := (others => '0');
    signal freq1_in_lsbs : std_logic_vector(32-1 downto 0) := (others => '0');
    signal freq2_in_lsbs : std_logic_vector(32-1 downto 0) := (others => '0');
    signal freq3_in_lsbs : std_logic_vector(32-1 downto 0) := (others => '0');
    signal freq4_in_lsbs : std_logic_vector(32-1 downto 0) := (others => '0');


    signal freq1_in_offset : std_logic_vector(FREQ_WIDTH-1 downto 0) := (others => '0');
    signal freq2_in_offset : std_logic_vector(FREQ_WIDTH-1 downto 0) := (others => '0');
    signal freq3_in_offset : std_logic_vector(FREQ_WIDTH-1 downto 0) := (others => '0');
    signal freq4_in_offset : std_logic_vector(FREQ_WIDTH-1 downto 0) := (others => '0');

    signal n_cycles : std_logic_vector(COUNTER_WIDTH-1 downto 0) := std_logic_vector(to_unsigned(208333, 32)); -- ~100 Hz nominal update rate at 125/6 MS/s input clk

    signal logger_mux_selector : std_logic_vector(5-1 downto 0) := (others => '0');
    signal trigger_identification : std_logic := '0';

    signal DDS_cosine1     : std_logic_vector(16-1 downto 0);
    signal DDS_sine1       : std_logic_vector(16-1 downto 0);

    -- new stuff for PI to DDSes:
    signal n_cycles_to_pi    : std_logic_vector(COUNTER_WIDTH-1 downto 0) := std_logic_vector(to_unsigned(20, 32));
    signal P_enable          : std_logic_vector(4-1 downto 0)             := (others => '0');
    signal I_enable          : std_logic_vector(4-1 downto 0)             := (others => '0');
    signal gain_fine1        : std_logic_vector(4-1 downto 0)             := std_logic_vector(to_signed(3, 4));
    signal gain_fine2        : std_logic_vector(4-1 downto 0)             := std_logic_vector(to_signed(3, 4));
    signal gain_fine4        : std_logic_vector(4-1 downto 0)             := std_logic_vector(to_signed(3, 4));
    signal gain_fine3        : std_logic_vector(4-1 downto 0)             := std_logic_vector(to_signed(3, 4));
    signal P_gain_coarse1    : std_logic_vector(6-1 downto 0)             := (others => '0');
    signal P_gain_coarse2    : std_logic_vector(6-1 downto 0)             := (others => '0');
    signal P_gain_coarse3    : std_logic_vector(6-1 downto 0)             := (others => '0');
    signal P_gain_coarse4    : std_logic_vector(6-1 downto 0)             := (others => '0');
    signal I_gain_coarse1    : std_logic_vector(6-1 downto 0)             := (others => '0');
    signal I_gain_coarse2    : std_logic_vector(6-1 downto 0)             := (others => '0');
    signal I_gain_coarse3    : std_logic_vector(6-1 downto 0)             := (others => '0');
    signal I_gain_coarse4    : std_logic_vector(6-1 downto 0)             := (others => '0');
    signal manual_offset_changed : std_logic_vector(4-1 downto 0) := (others => '0');
    signal manual_offset_dds1    : std_logic_vector(DDS_WIDTH-1 downto 0)  := (others => '0');
    signal manual_offset_dds2    : std_logic_vector(DDS_WIDTH-1 downto 0)  := (others => '0');
    signal manual_offset_dds3    : std_logic_vector(DDS_WIDTH-1 downto 0)  := (others => '0');
    signal manual_offset_dds4    : std_logic_vector(DDS_WIDTH-1 downto 0)  := (others => '0');
    signal manual_offset_dds1_lsbs : std_logic_vector(32-1 downto 0)  := (others => '0');
    signal manual_offset_dds2_lsbs : std_logic_vector(32-1 downto 0)  := (others => '0');
    signal manual_offset_dds3_lsbs : std_logic_vector(32-1 downto 0)  := (others => '0');
    signal manual_offset_dds4_lsbs : std_logic_vector(32-1 downto 0)  := (others => '0');

    signal limit_high_dds1       : std_logic_vector(16-1 downto 0)            := std_logic_vector(to_signed(2**15-1, 16));
    signal limit_high_dds2       : std_logic_vector(16-1 downto 0)            := std_logic_vector(to_signed(2**15-1, 16));
    signal limit_high_dds3       : std_logic_vector(16-1 downto 0)            := std_logic_vector(to_signed(2**15-1, 16));
    signal limit_high_dds4       : std_logic_vector(16-1 downto 0)            := std_logic_vector(to_signed(2**15-1, 16));
    signal limit_low_dds1        : std_logic_vector(16-1 downto 0)            := std_logic_vector(to_signed(-2**15, 16));
    signal limit_low_dds2        : std_logic_vector(16-1 downto 0)            := std_logic_vector(to_signed(-2**15, 16));
    signal limit_low_dds3        : std_logic_vector(16-1 downto 0)            := std_logic_vector(to_signed(-2**15, 16));
    signal limit_low_dds4        : std_logic_vector(16-1 downto 0)            := std_logic_vector(to_signed(-2**15, 16));

    signal ramp_resets : std_logic_vector(4-1 downto 0) := (others => '1');
    signal ramp_slope1 : std_logic_vector(64-1 downto 0) := (others => '0');
    signal ramp_slope2 : std_logic_vector(64-1 downto 0) := (others => '0');
    signal ramp_slope3 : std_logic_vector(64-1 downto 0) := (others => '0');
    signal ramp_slope4 : std_logic_vector(64-1 downto 0) := (others => '0');

    signal ramp_slope1_lsbs : std_logic_vector(32-1 downto 0) := (others => '0');
    signal ramp_slope2_lsbs : std_logic_vector(32-1 downto 0) := (others => '0');
    signal ramp_slope3_lsbs : std_logic_vector(32-1 downto 0) := (others => '0');
    signal ramp_slope4_lsbs : std_logic_vector(32-1 downto 0) := (others => '0');


    signal dither_results1 : std_logic_vector(64-1 downto 0);
    signal dither_results2 : std_logic_vector(64-1 downto 0);
    signal dither_results3 : std_logic_vector(64-1 downto 0);
    signal dither_results4 : std_logic_vector(64-1 downto 0);

    signal DDS1_clk_enable_to_logger, DDS2_clk_enable_to_logger, DDS3_clk_enable_to_logger, DDS4_clk_enable_to_logger : std_logic := '0';
    signal DDS1_sync, DDS2_sync, DDS3_sync, DDS4_sync : std_logic := '0';
    signal DDSout1_to_logger, DDSout2_to_logger, DDSout3_to_logger, DDSout4_to_logger : std_logic_vector(16-1 downto 0);

    signal DDS_clk_enable_int      : std_logic;
    signal DDSout1_int             : std_logic_vector(DDS_WIDTH-1 downto 0);
    signal DDSout2_int             : std_logic_vector(DDS_WIDTH-1 downto 0);
    signal DDSout3_int             : std_logic_vector(DDS_WIDTH-1 downto 0);
    signal DDSout4_int             : std_logic_vector(DDS_WIDTH-1 downto 0);

    signal DDS_SPI_enables_int     :  std_logic_vector(16-1 downto 0) := (others => '1');

    attribute mark_debug : string;
    attribute mark_debug of DDS_clk_enable_int: signal is "True";
    attribute mark_debug of ramp_resets:        signal is "True";
    attribute mark_debug of ramp_slope1:        signal is "True";
    attribute mark_debug of freq1_in_offset:    signal is "True";

    --attribute mark_debug of P_enable:           signal is "True";
    --attribute mark_debug of I_enable:           signal is "True";
    --attribute mark_debug of gain_fine1:         signal is "True";
    --attribute mark_debug of P_gain_coarse1:     signal is "True";
    --attribute mark_debug of DDS_clk_enable_int: signal is "True";
    ----attribute mark_debug of DDSout1_int:        signal is "True";
begin

    ddc_multichannel_inst : entity work.ddc_multichannel
    generic map (
        DATA_WIDTH  => DATA_WIDTH,
        FREQ_WIDTH  => FREQ_WIDTH,
        IQ_WIDTH    => IQ_WIDTH,
        PHASE_WIDTH => PHASE_WIDTH
    ) port map (
        clk               => clk,
        clk_times_N       => clk_times_N,
        data1_in          => data1_in,
        data2_in          => data1_in,
        data3_in          => data2_in,
        data4_in          => data2_in,
        freq1_in          => freq1_in,
        freq2_in          => freq2_in,
        freq3_in          => freq3_in,
        freq4_in          => freq4_in,

        freq1_in_offset   => freq1_in_offset,
        freq2_in_offset   => freq2_in_offset,
        freq3_in_offset   => freq3_in_offset,
        freq4_in_offset   => freq4_in_offset,

        clk_enable_IQ_out => iq_clk_enable,
        sync_IQ_out       => iq_sync,
        IQ1_out           => IQ1,
        IQ2_out           => IQ2,
        IQ3_out           => IQ3,
        IQ4_out           => IQ4,
        DDS_cosine1       => DDS_cosine1,
        DDS_sine1         => DDS_sine1,


        clk_enable_out    => phi_clk_enable,
        phi1              => phi1,
        phi2              => phi2,
        phi3              => phi3,
        phi4              => phi4
    );

    freq_counter_backend_inst : entity work.freq_counter_backend
    port map (
        clk               => clk,
        clk_enable_in     => phi_clk_enable,
        wrapped_phase_in1 => phi1,
        wrapped_phase_in2 => phi2,
        wrapped_phase_in3 => phi3,
        wrapped_phase_in4 => phi4,
        dither_results1   => dither_results1,
        dither_results2   => dither_results2,
        dither_results3   => dither_results3,
        dither_results4   => dither_results4,
        clk_int_or_ext_actual  => clk_int_or_ext_actual,
        clk_int_or_ext_desired => clk_int_or_ext_desired,
        clk_ext_good           => clk_ext_good,
        n_cycles          => n_cycles,
        sys_addr          => sys_addr,
        sys_wdata         => sys_wdata,
        sys_wen           => sys_wen,
        sys_ren           => sys_ren,
        sys_rdata         => sys_rdata,
        sys_err           => sys_err,
        sys_ack           => sys_ack
    );

    -- mux the logger outputs
    multiplexer_NbitsxMsignals_to_Nbits_inst_stage1 : entity work.multiplexer_NbitsxMsignals_to_Nbits
    generic map (
        N_bits_per_signal => LoggerData'length+2 -- 1 more signal for the clk enable, and 2 more for the sync
    ) port map (
        clk             => clk,
        in0             => ('1' & '1' & std_logic_vector(resize(signed(data1_in), LoggerData'length))),
        in1             => ('1' & '1' & std_logic_vector(resize(signed(data2_in), LoggerData'length))),
        in2             => (iq_sync & iq_clk_enable & IQ1),
        in3             => (iq_sync & iq_clk_enable & IQ2),
        in4             => (iq_sync & iq_clk_enable & IQ3),
        in5             => (iq_sync & iq_clk_enable & IQ4),
        in6             => (DDS1_sync & DDS1_clk_enable_to_logger & DDSout1_to_logger),
        in7             => (DDS2_sync & DDS2_clk_enable_to_logger & DDSout2_to_logger),
        in8             => (DDS3_sync & DDS3_clk_enable_to_logger & DDSout3_to_logger),
        in9             => (DDS4_sync & DDS4_clk_enable_to_logger & DDSout4_to_logger),
        in10            => ('1', '1', others => '0'),
        selector        => logger_mux_selector,
        selected_output => selected_output
    );
    -- this mux is used both for adding in a timestamp at the start of every data packet going to the logger,
    -- and also making sure that the first point that we commit to the logger is always I from the IQ stream
    aux_data_mux_inst : entity work.aux_data_mux
    port map (
        clk            => clk,
        write_mode     => LoggerIsWriting,
        clk_enable_in  => selected_output(LoggerData'length-1+1),
        sync_in        => selected_output(LoggerData'length-1+2),
        data_in        => selected_output(LoggerData'range),
        clk_enable_out => LoggerData_clk_enable,
        data_out       => LoggerData
    );
    -- the DDS outputs are DDS_WIDTH=48 bits, but our logger input is 16 bits, so we serialize this
    serialize_M_to_N_bits_inst1 : entity work.serialize_M_to_N_bits
    generic map (
        INPUT_WIDTH  => DDS_WIDTH,
        OUTPUT_WIDTH => 16
    ) port map (
        clk               => clk,
        input_clk_enable  => DDS_clk_enable_int,
        data_in           => DDSout1_int,
        output_clk_enable => DDS1_clk_enable_to_logger,
        output_sync       => DDS1_sync,
        data_out          => DDSout1_to_logger
    );
    serialize_M_to_N_bits_inst2 : entity work.serialize_M_to_N_bits
    generic map (
        INPUT_WIDTH  => DDS_WIDTH,
        OUTPUT_WIDTH => 16
    ) port map (
        clk               => clk,
        input_clk_enable  => DDS_clk_enable_int,
        data_in           => DDSout2_int,
        output_clk_enable => DDS2_clk_enable_to_logger,
        output_sync       => DDS2_sync,
        data_out          => DDSout2_to_logger
    );
    serialize_M_to_N_bits_inst3 : entity work.serialize_M_to_N_bits
    generic map (
        INPUT_WIDTH  => DDS_WIDTH,
        OUTPUT_WIDTH => 16
    ) port map (
        clk               => clk,
        input_clk_enable  => DDS_clk_enable_int,
        data_in           => DDSout3_int,
        output_clk_enable => DDS3_clk_enable_to_logger,
        output_sync       => DDS3_sync,
        data_out          => DDSout3_to_logger
    );
    serialize_M_to_N_bits_inst4 : entity work.serialize_M_to_N_bits
    generic map (
        INPUT_WIDTH  => DDS_WIDTH,
        OUTPUT_WIDTH => 16
    ) port map (
        clk               => clk,
        input_clk_enable  => DDS_clk_enable_int,
        data_in           => DDSout4_int,
        output_clk_enable => DDS4_clk_enable_to_logger,
        output_sync       => DDS4_sync,
        data_out          => DDSout4_to_logger
    );

    -- PI section:
    PI_4ch_inst : entity work.PI_4ch
    generic map (
        INPUT_WIDTH     => PHASE_WIDTH,
        COUNTER_WIDTH   => COUNTER_WIDTH,
        OUTPUT_WIDTH    => DDS_WIDTH
    ) port map (
        clk               => clk,
        clk_enable_in     => phi_clk_enable,
        wrapped_phase_in1 => phi1,
        wrapped_phase_in2 => phi2,
        wrapped_phase_in3 => phi3,
        wrapped_phase_in4 => phi4,
        n_cycles          => n_cycles_to_pi,
        P_enable          => P_enable,
        I_enable          => I_enable,
        gain_fine1        => gain_fine1,
        gain_fine2        => gain_fine2,
        gain_fine4        => gain_fine4,
        gain_fine3        => gain_fine3,
        P_gain_coarse1    => P_gain_coarse1,
        P_gain_coarse2    => P_gain_coarse2,
        P_gain_coarse3    => P_gain_coarse3,
        P_gain_coarse4    => P_gain_coarse4,
        I_gain_coarse1    => I_gain_coarse1,
        I_gain_coarse2    => I_gain_coarse2,
        I_gain_coarse3    => I_gain_coarse3,
        I_gain_coarse4    => I_gain_coarse4,
        manual_offset_changed => manual_offset_changed,
        manual_offset1    => manual_offset_dds1,
        manual_offset2    => manual_offset_dds2,
        manual_offset3    => manual_offset_dds3,
        manual_offset4    => manual_offset_dds4,
        limit_high1       => limit_high_dds1,
        limit_high2       => limit_high_dds2,
        limit_high3       => limit_high_dds3,
        limit_high4       => limit_high_dds4,
        limit_low1        => limit_low_dds1,
        limit_low2        => limit_low_dds2,
        limit_low3        => limit_low_dds3,
        limit_low4        => limit_low_dds4,

        cmd_trig          => sys_wen,
        cmd_addr          => (x"0000" & sys_addr(16-1+2 downto 2)),
        cmd_data          => sys_wdata,
        dither_results1   => dither_results1,
        dither_results2   => dither_results2,
        dither_results3   => dither_results3,
        dither_results4   => dither_results4,
        clk_enable_out    => DDS_clk_enable_int,
        freq_out1         => DDSout1_int,
        freq_out2         => DDSout2_int,
        freq_out3         => DDSout3_int,
        freq_out4         => DDSout4_int
    );
    DDS_clk_enable <= DDS_clk_enable_int and DDS_SPI_enables_int(0);
    DDSout1 <= DDSout1_int;
    DDSout2 <= DDSout2_int;
    DDSout3 <= DDSout3_int;
    DDSout4 <= DDSout4_int;
    DDS_SPI_enables <= DDS_SPI_enables_int;


    -- add a linear ramp, controllable from the PC, to provide drift cancellation features
    linear_ramp_gen_inst1 : entity work.linear_ramp_gen
    generic map (
        OUTPUT_DATA_WIDTH => FREQ_WIDTH
    ) port map (
        clk           => clk,
        reset_ramp    => ramp_resets(0),
        clk_enable_in => DDS_clk_enable_int,
        ramp_slope    => ramp_slope1,
        data_out      => freq1_in_offset
    );
    linear_ramp_gen_inst2 : entity work.linear_ramp_gen
    generic map (
        OUTPUT_DATA_WIDTH => FREQ_WIDTH
    ) port map (
        clk           => clk,
        reset_ramp    => ramp_resets(1),
        clk_enable_in => DDS_clk_enable_int,
        ramp_slope    => ramp_slope2,
        data_out      => freq2_in_offset
    );
    linear_ramp_gen_inst3 : entity work.linear_ramp_gen
    generic map (
        OUTPUT_DATA_WIDTH => FREQ_WIDTH
    ) port map (
        clk           => clk,
        reset_ramp    => ramp_resets(2),
        clk_enable_in => DDS_clk_enable_int,
        ramp_slope    => ramp_slope3,
        data_out      => freq3_in_offset
    );
    linear_ramp_gen_inst4 : entity work.linear_ramp_gen
    generic map (
        OUTPUT_DATA_WIDTH => FREQ_WIDTH
    ) port map (
        clk           => clk,
        reset_ramp    => ramp_resets(3),
        clk_enable_in => DDS_clk_enable_int,
        ramp_slope    => ramp_slope4,
        data_out      => freq4_in_offset
    );


    -------------------------------------------------
    -- config registers
    process(clk)
    begin
        if rising_edge(clk) then
            manual_offset_changed <= (others => '0');
            AD9912_register_write <= '0';
            -- I hope there is actually no register at this address, this is meant to disable the write
            -- the datasheet lists none at this address, but who knows
            AD9912_register_address1 <= '0' & x"210";
            AD9912_register_address2 <= '0' & x"210";
            AD9912_register_address3 <= '0' & x"210";
            AD9912_register_address4 <= '0' & x"210";
            -- Note: sys_ack is generated inside registers_read, and is strobed by default in response to all reads/writes

            -- defaults, for implementing strobes on writes:
            trigger_identification <= '0';

            if sys_wen = '1' then
                case sys_addr(16-1+2 downto 2) is -- note that we divide the Zynq addresses by 4 when mapping to the DPLL addresses.  This is because the Zynq cannot address memory locations that are not on 32-bits boundaries, but the legacy bus didn't have this restriction.
                    when x"1" => logger_mux_selector <= sys_wdata(logger_mux_selector'range);
                    when x"2" => n_cycles            <= sys_wdata(n_cycles'range);
                    when x"3" => n_cycles_to_pi      <= sys_wdata(n_cycles_to_pi'range);

                    when x"6" => trigger_identification <= '1';

                    -- written as two 32-bits registers that update when the MSBs are written
                    when x"7" => freq1_in_lsbs <= sys_wdata(32-1 downto 0);
                    when x"8" => freq1_in <= (sys_wdata(FREQ_WIDTH-32-1 downto 0) & freq1_in_lsbs);

                    -- written as two 32-bits registers that update when the MSBs are written
                    when x"9" => freq2_in_lsbs <= sys_wdata(32-1 downto 0);
                    when x"A" => freq2_in <= (sys_wdata(FREQ_WIDTH-32-1 downto 0) & freq2_in_lsbs);

                    -- written as two 32-bits registers that update when the MSBs are written
                    when x"B" => freq3_in_lsbs <= sys_wdata(32-1 downto 0);
                    when x"C" => freq3_in <= (sys_wdata(FREQ_WIDTH-32-1 downto 0) & freq3_in_lsbs);

                    -- written as two 32-bits registers that update when the MSBs are written
                    when x"D" => freq4_in_lsbs <= sys_wdata(32-1 downto 0);
                    when x"E" => freq4_in <= (sys_wdata(FREQ_WIDTH-32-1 downto 0) & freq4_in_lsbs);

                    -- written as two 32-bits registers that update when the MSBs are written
                    when x"10" => manual_offset_dds1_lsbs <= sys_wdata(32-1 downto 0);
                    when x"11" => manual_offset_dds1 <= (sys_wdata(FREQ_WIDTH-32-1 downto 0) & manual_offset_dds1_lsbs); manual_offset_changed(0) <= '1';

                    -- written as two 32-bits registers that update when the MSBs are written
                    when x"12" => manual_offset_dds2_lsbs <= sys_wdata(32-1 downto 0);
                    when x"13" => manual_offset_dds2 <= (sys_wdata(FREQ_WIDTH-32-1 downto 0) & manual_offset_dds2_lsbs); manual_offset_changed(1) <= '1';

                    -- written as two 32-bits registers that update when the MSBs are written
                    when x"14" => manual_offset_dds3_lsbs <= sys_wdata(32-1 downto 0);
                    when x"15" => manual_offset_dds3 <= (sys_wdata(FREQ_WIDTH-32-1 downto 0) & manual_offset_dds3_lsbs); manual_offset_changed(2) <= '1';

                    -- written as two 32-bits registers that update when the MSBs are written
                    when x"16" => manual_offset_dds4_lsbs <= sys_wdata(32-1 downto 0);
                    when x"17" => manual_offset_dds4 <= (sys_wdata(FREQ_WIDTH-32-1 downto 0) & manual_offset_dds4_lsbs); manual_offset_changed(3) <= '1';

                    when x"18" => limit_high_dds1 <= sys_wdata(16-1+16 downto 16); limit_low_dds1 <= sys_wdata(16-1 downto 0);
                    when x"19" => limit_high_dds2 <= sys_wdata(16-1+16 downto 16); limit_low_dds2 <= sys_wdata(16-1 downto 0);
                    when x"1A" => limit_high_dds3 <= sys_wdata(16-1+16 downto 16); limit_low_dds3 <= sys_wdata(16-1 downto 0);
                    when x"1B" => limit_high_dds4 <= sys_wdata(16-1+16 downto 16); limit_low_dds4 <= sys_wdata(16-1 downto 0);

                    when x"1C" => I_enable <= sys_wdata(4-1+4 downto 4); P_enable <= sys_wdata(4-1 downto 0);
                    when x"1D" =>
                        gain_fine1 <= sys_wdata(gain_fine1'length-1+gain_fine1'length*0 downto gain_fine1'length*0);
                        gain_fine2 <= sys_wdata(gain_fine1'length-1+gain_fine1'length*1 downto gain_fine1'length*1);
                        gain_fine3 <= sys_wdata(gain_fine1'length-1+gain_fine1'length*2 downto gain_fine1'length*2);
                        gain_fine4 <= sys_wdata(gain_fine1'length-1+gain_fine1'length*3 downto gain_fine1'length*3);

                    when x"1E" =>
                        P_gain_coarse1 <= sys_wdata(P_gain_coarse1'length-1+P_gain_coarse1'length*0 downto P_gain_coarse1'length*0);
                        P_gain_coarse2 <= sys_wdata(P_gain_coarse1'length-1+P_gain_coarse1'length*1 downto P_gain_coarse1'length*1);
                        P_gain_coarse3 <= sys_wdata(P_gain_coarse1'length-1+P_gain_coarse1'length*2 downto P_gain_coarse1'length*2);
                        P_gain_coarse4 <= sys_wdata(P_gain_coarse1'length-1+P_gain_coarse1'length*3 downto P_gain_coarse1'length*3);

                    when x"1F" =>
                        I_gain_coarse1 <= sys_wdata(P_gain_coarse1'length-1+P_gain_coarse1'length*0 downto P_gain_coarse1'length*0);
                        I_gain_coarse2 <= sys_wdata(P_gain_coarse1'length-1+P_gain_coarse1'length*1 downto P_gain_coarse1'length*1);
                        I_gain_coarse3 <= sys_wdata(P_gain_coarse1'length-1+P_gain_coarse1'length*2 downto P_gain_coarse1'length*2);
                        I_gain_coarse4 <= sys_wdata(P_gain_coarse1'length-1+P_gain_coarse1'length*3 downto P_gain_coarse1'length*3);

                    when x"20" =>
                        AD9912_register_write    <= '1';
                        AD9912_register_value    <= sys_wdata(                                AD9912_register_value'length-1 downto 0);
                        AD9912_register_address1 <= sys_wdata(AD9912_register_address1'length+AD9912_register_value'length-1 downto AD9912_register_value'length);

                    when x"21" =>
                        AD9912_register_write    <= '1';
                        AD9912_register_value    <= sys_wdata(                                AD9912_register_value'length-1 downto 0);
                        AD9912_register_address2 <= sys_wdata(AD9912_register_address1'length+AD9912_register_value'length-1 downto AD9912_register_value'length);

                    when x"22" =>
                        AD9912_register_write    <= '1';
                        AD9912_register_value    <= sys_wdata(                                AD9912_register_value'length-1 downto 0);
                        AD9912_register_address3 <= sys_wdata(AD9912_register_address1'length+AD9912_register_value'length-1 downto AD9912_register_value'length);

                    when x"23" =>
                        AD9912_register_write    <= '1';
                        AD9912_register_value    <= sys_wdata(                                AD9912_register_value'length-1 downto 0);
                        AD9912_register_address4 <= sys_wdata(AD9912_register_address1'length+AD9912_register_value'length-1 downto AD9912_register_value'length);

                    when x"24" =>
                        DDS_SPI_enables_int <= sys_wdata(DDS_SPI_enables_int'range);


                    when x"25" => ramp_resets <= sys_wdata(ramp_resets'range);

                    -- written as two 32-bits registers that update when the MSBs are written
                    when x"26" => ramp_slope1_lsbs <= sys_wdata(32-1 downto 0);
                    when x"27" => ramp_slope1 <= (sys_wdata(32-1 downto 0) & ramp_slope1_lsbs);

                    -- written as two 32-bits registers that update when the MSBs are written
                    when x"28" => ramp_slope2_lsbs <= sys_wdata(32-1 downto 0);
                    when x"29" => ramp_slope2 <= (sys_wdata(32-1 downto 0) & ramp_slope2_lsbs);

                    -- written as two 32-bits registers that update when the MSBs are written
                    when x"30" => ramp_slope3_lsbs <= sys_wdata(32-1 downto 0);
                    when x"31" => ramp_slope3 <= (sys_wdata(32-1 downto 0) & ramp_slope3_lsbs);

                    -- written as two 32-bits registers that update when the MSBs are written
                    when x"32" => ramp_slope4_lsbs <= sys_wdata(32-1 downto 0);
                    when x"33" => ramp_slope4 <= (sys_wdata(32-1 downto 0) & ramp_slope4_lsbs);

                    when others => 
                end case;
            end if;

        end if;
    end process;

end;
