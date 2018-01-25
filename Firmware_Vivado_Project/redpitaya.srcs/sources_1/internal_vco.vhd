library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


entity internal_vco  is
Generic (
	DATA_WIDTH			: integer := 16;	-- this cannot be changed without recompiling the DDS core
	AMPLITUDE_WIDTH : integer := 16			-- this should fit in a DSP47 mult
);
port (
	
    clk                                    : in  std_logic;

    -- frequency in counts: analog frequency is equal to: frequency/2^48*clock frequency (currently 125 MHz)
    frequency                              : in  std_logic_vector(48-1 downto 0);
    
    -- internal configuration bus
    sys_addr                               : in  std_logic_vector(32-1 downto 0);   -- bus address
    sys_wdata                              : in  std_logic_vector(32-1 downto 0);   -- bus write data
    sys_sel                                : in  std_logic_vector(4-1 downto 0);   -- bus write byte select
    sys_wen                                : in  std_logic;   -- bus write enable
    sys_ren                                : in  std_logic;   -- bus read enable
    sys_rdata                              : out std_logic_vector(32-1 downto 0);  -- bus read data
    sys_err                                : out std_logic;  -- bus error indicator
    sys_ack                                : out std_logic;  -- bus acknowledge signal
    
    
    -- Complex exponential output:
    cosine_out                             : out std_logic_vector (DATA_WIDTH-1 downto 0);
    sine_out                               : out std_logic_vector (DATA_WIDTH-1 downto 0)
	);
end entity;

architecture Behavioral of internal_vco is

    -- Coregen IP
    component LO_DDS
        port (
        aclk : IN STD_LOGIC;
        s_axis_phase_tvalid : IN STD_LOGIC;
        s_axis_phase_tdata : IN STD_LOGIC_VECTOR(47 DOWNTO 0);  -- phase increments
        m_axis_data_tvalid : OUT STD_LOGIC;
        m_axis_data_tdata : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);  -- cos and sine (16 bits signed each)
        m_axis_phase_tvalid : OUT STD_LOGIC;
        m_axis_phase_tdata : OUT STD_LOGIC_VECTOR(47 DOWNTO 0)  -- output phase, not used in this module
        );
    end component;
    signal s_axis_phase_tvalid                    : std_logic                                      := '1';  -- compiler complains otherwise
    signal lo_dds_m_axis_data_tdata               : std_logic_vector(31 DOWNTO 0)                  := (others => '0');
    
    
    -- internal signals
    signal DDS_cosine_tmp                         : std_logic_vector(DATA_WIDTH-1 downto 0)        := (others => '0');
    signal DDS_sine_tmp                           : std_logic_vector(DATA_WIDTH-1 downto 0)        := (others => '0');
    
    signal cos_times_amplitude_wide               : signed(DATA_WIDTH+AMPLITUDE_WIDTH-1 downto 0)  := (others => '0');
    signal sin_times_amplitude_wide               : signed(DATA_WIDTH+AMPLITUDE_WIDTH-1 downto 0)  := (others => '0');
    
    signal cos_times_amplitude                    : std_logic_vector(DATA_WIDTH-1 downto 0)        := (others => '0');
    signal sin_times_amplitude                    : std_logic_vector(DATA_WIDTH-1 downto 0)        := (others => '0');
    
    constant BIT_SHIFT_AFTER_MULT                 : positive                                       := AMPLITUDE_WIDTH-1;    -- Divides the output of the filter by 2^BIT_SHIFT_AFTER_MULT to keep max amplitude at maximum possible size at 16 bits.
    
    
    -- registers
    --signal frequency                              :  std_logic_vector (48-1 downto 0)              := b"001101011100001010001111010111000010100011110110"; -- dec2bin(round(2^48*21e6/100e6), 48)
    signal amplitude                              :  std_logic_vector (AMPLITUDE_WIDTH-1 downto 0) := std_logic_vector(to_signed(1638, AMPLITUDE_WIDTH)); -- round(0.05*(2**15-1))
    --

begin

-- Compute cos() and sin(), or more precisely, round((2^15-1)*cos()) and round((2^15-1)*sin())
    LO_DDS_inst : LO_DDS
    port map (
    
        aclk                    => clk,
        s_axis_phase_tvalid     => s_axis_phase_tvalid,
        s_axis_phase_tdata      => frequency,
        m_axis_data_tvalid      => open,
        m_axis_data_tdata       => lo_dds_m_axis_data_tdata,
        m_axis_phase_tvalid     => open,
        m_axis_phase_tdata      => open
    );
    DDS_cosine_tmp  <= lo_dds_m_axis_data_tdata(15 downto 0);
    DDS_sine_tmp    <= lo_dds_m_axis_data_tdata(31 downto 16);

    
    process (clk)
    begin
        if rising_edge(clk) then
        	-- multiply by amplitude, result has a max value of (2^15-1)*(2^(AMPLITUDE_WIDTH-1)-1)
        	cos_times_amplitude_wide <= signed(DDS_cosine_tmp) * signed(amplitude);
        	sin_times_amplitude_wide <= signed(DDS_sine_tmp)   * signed(amplitude);

        	-- Cancel the multiplier gain and round the multiplication product.
    		-- we want to make the result fit in max of 2^(DATA_WIDTH-1) = 2^15 = (2^15-1)*(2^(AMPLITUDE_WIDTH-1)-1)*2^-BIT_SHIFT_AFTER_MULT
        	-- so we want: 15 = (15)+(AMPLITUDE_WIDTH-1)-BIT_SHIFT_AFTER_MULT (where we neglected some -1s when we took the log)
        	-- BIT_SHIFT_AFTER_MULT = (AMPLITUDE_WIDTH-1)
            cos_times_amplitude <= std_logic_vector(resize(shift_right(
                                        cos_times_amplitude_wide + to_signed(2**(BIT_SHIFT_AFTER_MULT-1), cos_times_amplitude_wide'length)
                                        , BIT_SHIFT_AFTER_MULT), cos_times_amplitude'length));

            sin_times_amplitude <= std_logic_vector(resize(shift_right(
                                        sin_times_amplitude_wide + to_signed(2**(BIT_SHIFT_AFTER_MULT-1), sin_times_amplitude_wide'length)
                                        , BIT_SHIFT_AFTER_MULT), sin_times_amplitude'length));
        end if;
    end process;


	cosine_out <= cos_times_amplitude;
	sine_out   <= sin_times_amplitude;



    -----------------------------------------
    -- registers

    ibus_manager : process (clk) is
    begin
        if rising_edge(clk) then
            sys_err <= '0';
            sys_ack <= sys_wen or sys_ren;

            -- Write
            if sys_wen = '1' then
                case sys_addr(20-1 downto 0) is
                    when x"00000" => amplitude <= sys_wdata(amplitude'range);
                    when others => 
                end case;
            end if;

            -- Read
            if sys_ren = '1' then
                case sys_addr(20-1 downto 0) is
                    when x"00000" => sys_rdata <= std_logic_vector(resize(  signed(amplitude), 32));
                    when others => sys_rdata <=  (others => '0');
                end case;
            end if;

        end if;
    end process;

end;
