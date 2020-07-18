library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


entity multichannel_freq_counter_top is
generic (
    DATA_WIDTH    : integer := 14;
    FREQ_WIDTH    : integer := 48;
    IQ_WIDTH      : integer := 16;
    COUNTER_WIDTH : integer := 32;
    PHASE_WIDTH   : integer := 14


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
    
    -- data output:
    DACout1               : out std_logic_vector(16-1 downto 0);
    DACout2               : out std_logic_vector(16-1 downto 0);
    
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
    signal iq_clk_enable : std_logic := '0';
    signal IQ1, IQ2, IQ3, IQ4 : std_logic_vector(IQ_WIDTH-1 downto 0) := (others => '0');

    signal DACout1_int, DACout2_int : std_logic_vector(DACout1'length-1 downto 0) := (others => '0');

    signal selected_output : std_logic_vector(LoggerData'length+1-1 downto 0) := (others => '0');

    -- config registers:
    signal freq1_in : std_logic_vector(FREQ_WIDTH-1 downto 0) := (others => '0');
    signal freq2_in : std_logic_vector(FREQ_WIDTH-1 downto 0) := (others => '0');
    signal freq3_in : std_logic_vector(FREQ_WIDTH-1 downto 0) := (others => '0');
    signal freq4_in : std_logic_vector(FREQ_WIDTH-1 downto 0) := (others => '0');
    signal freq1_in_lsbs : std_logic_vector(32-1 downto 0) := (others => '0');
    signal freq2_in_lsbs : std_logic_vector(32-1 downto 0) := (others => '0');
    signal freq3_in_lsbs : std_logic_vector(32-1 downto 0) := (others => '0');
    signal freq4_in_lsbs : std_logic_vector(32-1 downto 0) := (others => '0');

    signal n_cycles : std_logic_vector(COUNTER_WIDTH-1 downto 0) := std_logic_vector(to_unsigned(208333, 32)); -- ~100 Hz nominal update rate at 125/6 MS/s input clk

    signal logger_mux_selector : std_logic_vector(5-1 downto 0) := (others => '0');
    signal trigger_identification : std_logic := '0';
    signal positive_limit_dac0, positive_limit_dac1 : std_logic_vector(16-1 downto 0) := ('0', others => '1');
    signal negative_limit_dac0, negative_limit_dac1 : std_logic_vector(16-1 downto 0) := ('1', others => '0');
    signal manual_offset_dac0, manual_offset_dac1 : std_logic_vector(16-1 downto 0) := (others => '0');

    signal DDS_cosine1     : std_logic_vector(16-1 downto 0);
    signal DDS_sine1       : std_logic_vector(16-1 downto 0);
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
        clk_enable_IQ_out => iq_clk_enable,
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
        N_bits_per_signal => LoggerData'length+1 -- 1 more signal for the clk enable
    ) port map (
        clk             => clk,
        in0             => ('1' & std_logic_vector(resize(signed(data1_in), LoggerData'length))),
        in1             => ('1' & std_logic_vector(resize(signed(data2_in), LoggerData'length))),
        in2             => (iq_clk_enable & IQ1),
        in3             => (iq_clk_enable & IQ2),
        in4             => (iq_clk_enable & IQ3),
        in5             => (iq_clk_enable & IQ4),
        in6             => ('1', others => '0'),
        in7             => ('1', others => '0'),
        in8             => ('1', others => '0'),
        in9             => ('1', others => '0'),
        in10            => ('1', others => '0'),
        selector        => logger_mux_selector,
        selected_output => selected_output
    );
    LoggerData_clk_enable <= selected_output(LoggerData'length-1+1);
    LoggerData            <= selected_output(LoggerData'range);


    -------------------------------------------------
    -- config registers
    process(clk)
    begin
        if rising_edge(clk) then
            -- Note: sys_ack is generated inside registers_read, and is strobed by default in response to all reads/writes

            -- defaults, for implementing strobes on writes:
            trigger_identification <= '0';

            if sys_wen = '1' then
                case sys_addr(16-1+2 downto 2) is -- note that we divide the Zynq addresses by 4 when mapping to the DPLL addresses.  This is because the Zynq cannot address memory locations that are not on 32-bits boundaries, but the legacy bus didn't have this restriction.
                    when x"1" => logger_mux_selector <= sys_wdata(logger_mux_selector'range);
                    when x"2" => manual_offset_dac0 <= sys_wdata(manual_offset_dac0'range);
                    when x"3" => manual_offset_dac1 <= sys_wdata(manual_offset_dac0'range);
                    when x"4" => positive_limit_dac0 <= sys_wdata(16-1+16 downto 16); negative_limit_dac0 <= sys_wdata(16-1 downto 0);
                    when x"5" => positive_limit_dac1 <= sys_wdata(16-1+16 downto 16); negative_limit_dac1 <= sys_wdata(16-1 downto 0);
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

                    when x"F" => n_cycles <= sys_wdata(n_cycles'range);

                    when others => 
                end case;
            end if;

        end if;
    end process;

    ---- debugging output
    --DACout1_int <= std_logic_vector(shift_right(signed(DDS_cosine1), 1));
    --DACout2_int <= std_logic_vector(shift_right(signed(DDS_sine1), 1));

    --DACout1_int <= freq1_in(freq1_in'left downto freq1_in'left-16+1);
    --DACout2_int <= freq1_in(freq1_in'left-16 downto freq1_in'left-16-16+1);

    DACout1_int <= manual_offset_dac0;
    DACout2_int <= manual_offset_dac1;

    DACout1 <= DACout1_int;
    DACout2 <= DACout2_int;

end;
