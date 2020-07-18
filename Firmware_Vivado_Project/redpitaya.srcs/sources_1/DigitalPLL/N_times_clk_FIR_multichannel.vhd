library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- takes in data at the clk_times_1 rate, always enabled,
-- filters it in the clk_times_N clk domain,
-- this filter currently includes decimation by 6 (relative to the clk_times_1 rate)
-- and finally converts it back to the clk_times_1 rate,
-- with the net output being decimated by 6 compared to the input data

entity N_times_clk_FIR_multichannel  is
Generic (
    -- these need to match what was put in the FIR compiler
    N_BITS_IN       : integer := 14;
    N_BITS_OUT      : integer := 16
);
port (
    -- these two clocks need to be phase-locked to have a common edge (0 phase difference at the rising edges of clk_times_1)
    clk_times_1    : in  std_logic;
    clk_times_N    : in  std_logic;
    
    -- these signals are all on the clk_times_1 clock domain,
    -- but the outputs are now decimated by 6
    data1_in        : in  std_logic_vector(N_BITS_IN-1 downto 0);
    data2_in        : in  std_logic_vector(N_BITS_IN-1 downto 0);
    data3_in        : in  std_logic_vector(N_BITS_IN-1 downto 0);
    data4_in        : in  std_logic_vector(N_BITS_IN-1 downto 0);
    data5_in        : in  std_logic_vector(N_BITS_IN-1 downto 0);
    data6_in        : in  std_logic_vector(N_BITS_IN-1 downto 0);
    data7_in        : in  std_logic_vector(N_BITS_IN-1 downto 0);
    data8_in        : in  std_logic_vector(N_BITS_IN-1 downto 0);

    clk_enable_out  : out std_logic;
    data1_out       : out std_logic_vector(N_BITS_OUT-1 downto 0);
    data2_out       : out std_logic_vector(N_BITS_OUT-1 downto 0);
    data3_out       : out std_logic_vector(N_BITS_OUT-1 downto 0);
    data4_out       : out std_logic_vector(N_BITS_OUT-1 downto 0);
    data5_out       : out std_logic_vector(N_BITS_OUT-1 downto 0);
    data6_out       : out std_logic_vector(N_BITS_OUT-1 downto 0);
    data7_out       : out std_logic_vector(N_BITS_OUT-1 downto 0);
    data8_out       : out std_logic_vector(N_BITS_OUT-1 downto 0)

    );
end entity;

architecture Behavioral of N_times_clk_FIR_multichannel is

    -- FIR compiler component:
    component fir_lpf_decim_by_6 is
    port (
        aclk               : in  std_logic;
        s_axis_data_tvalid : in  std_logic;
        s_axis_data_tready : out std_logic;
        s_axis_data_tdata  : in  std_logic_vector(127 downto 0);
        m_axis_data_tvalid : out std_logic;
        m_axis_data_tdata  : out std_logic_vector(127 downto 0)
    );
    end component;


    signal data_in_wide  : std_logic_vector(128-1 downto 0);
    signal m_axis_data_tvalid : std_logic;
    signal m_axis_data_tvalid_last : std_logic;
    signal m_axis_data_tdata  : std_logic_vector(128-1 downto 0);

    -- Flags used to transfer data between the two domains:
    signal flag_times_1                : std_logic                               := '0';
    signal flag_times_N_d1             : std_logic                               := '0';
    -- Data when first transfered to the "times N" clk domain
    signal data_times_N_clk_enable     : std_logic                               := '0';
    signal data_times_N                : std_logic_vector(128-1 downto 0)  := (others => '0');
    
    -- extra register stage to improve timings, since we are trying to reach as close as possible to the full rate of the DSP48 blocks.
    signal data_times_N_clk_enable_reg : std_logic                               := '0';
    signal data_times_N_reg            : std_logic_vector(128-1 downto 0)  := (others => '0');


    signal data_out_times_N_clken      : std_logic := '0';
    signal data_out_times_1_clken      : std_logic := '0';
    signal data_out_times_N_clken_d1   : std_logic := '0';
    
    -- output data
    signal data_out_times_N            : std_logic_vector(128-1 downto 0) := (others => '0');
    signal data_out_times_N_reg        : std_logic_vector(128-1 downto 0) := (others => '0');
    signal data_out_times_1            : std_logic_vector(128-1 downto 0) := (others => '0');
    
begin

    -- this generates a toggling flag to sync the two domains (simply to resolve the N-cycle ambiguity between the two clks)
    process (clk_times_1)
    begin
        if rising_edge(clk_times_1) then
            flag_times_1 <= not flag_times_1;
        end if;
    end process;

    data_in_wide((1-1)*16+16-1 downto (1-1)*16) <= std_logic_vector(resize(signed(data1_in), 16)); -- the sign-extension here is not strictly necessary, but it's probably safer in case we change the core later
    data_in_wide((2-1)*16+16-1 downto (2-1)*16) <= std_logic_vector(resize(signed(data2_in), 16)); -- the sign-extension here is not strictly necessary, but it's probably safer in case we change the core later
    data_in_wide((3-1)*16+16-1 downto (3-1)*16) <= std_logic_vector(resize(signed(data3_in), 16)); -- the sign-extension here is not strictly necessary, but it's probably safer in case we change the core later
    data_in_wide((4-1)*16+16-1 downto (4-1)*16) <= std_logic_vector(resize(signed(data4_in), 16)); -- the sign-extension here is not strictly necessary, but it's probably safer in case we change the core later
    data_in_wide((5-1)*16+16-1 downto (5-1)*16) <= std_logic_vector(resize(signed(data5_in), 16)); -- the sign-extension here is not strictly necessary, but it's probably safer in case we change the core later
    data_in_wide((6-1)*16+16-1 downto (6-1)*16) <= std_logic_vector(resize(signed(data6_in), 16)); -- the sign-extension here is not strictly necessary, but it's probably safer in case we change the core later
    data_in_wide((7-1)*16+16-1 downto (7-1)*16) <= std_logic_vector(resize(signed(data7_in), 16)); -- the sign-extension here is not strictly necessary, but it's probably safer in case we change the core later
    data_in_wide((8-1)*16+16-1 downto (8-1)*16) <= std_logic_vector(resize(signed(data8_in), 16)); -- the sign-extension here is not strictly necessary, but it's probably safer in case we change the core later

    -- make the data cross to the higher clk rate domain:
    -- the crossing is simple because the domains are phase-locked to a known (to the synthesis tools) phase
    process (clk_times_N)
    begin
        if rising_edge(clk_times_N) then
            data_times_N_clk_enable <= '0'; -- default value
            -- we transfer the data at any toggle of the 1x flag
            flag_times_N_d1 <= flag_times_1;
            if flag_times_N_d1 /= flag_times_1 then
                data_times_N <= data_in_wide;
                data_times_N_clk_enable <= '1';
            end if;

            -- extra register stage to improve timings, since we are trying to reach as close as possible to the full rate of the DSP48 blocks.
            data_times_N_reg            <= data_times_N;
            data_times_N_clk_enable_reg <= data_times_N_clk_enable;
        end if;
    end process;


    -- FIR filter
    fir_lpf_decim_by_6_inst : fir_lpf_decim_by_6 
        port map (
            aclk               => clk_times_N,
            s_axis_data_tvalid => data_times_N_clk_enable_reg,
            s_axis_data_tready => open, -- we don't care, the core should always be ready
            s_axis_data_tdata  => data_times_N_reg,
            m_axis_data_tvalid => m_axis_data_tvalid,
            m_axis_data_tdata  => m_axis_data_tdata
        );

    -- Finally we bring the data back to the slower clock domain.
    -- This conversion is simpler since we simply have a clock enable signal
    -- First we capture the data out using m_axis_data_tvalid as a clock enable
    -- This simply ensures that the data is always valid, since we do not know what the FIR core will do in between valid output samples
    process (clk_times_N)
    begin
        if rising_edge(clk_times_N) then
            m_axis_data_tvalid_last <= m_axis_data_tvalid; -- stretch the times_2 clk enables to longer
            data_out_times_N_clken <= m_axis_data_tvalid or m_axis_data_tvalid_last;
            if m_axis_data_tvalid = '1' then
                data_out_times_N <= m_axis_data_tdata;
            end if;
            -- we add an extra register stage here to help timing
            data_out_times_N_clken_d1 <= data_out_times_N_clken;
            data_out_times_N_reg <= data_out_times_N;
        end if;
    end process;
    -- then we capture it in the slower clock domain
    process (clk_times_1)
    begin
        if rising_edge(clk_times_1) then
            data_out_times_1_clken <= data_out_times_N_clken_d1;
            data_out_times_1 <= data_out_times_N_reg;
        end if;
    end process;
    -- assign output:
    clk_enable_out <= data_out_times_1_clken;
    data1_out <= data_out_times_1((1-1)*16+N_BITS_OUT-1 downto (1-1)*16);
    data2_out <= data_out_times_1((2-1)*16+N_BITS_OUT-1 downto (2-1)*16);
    data3_out <= data_out_times_1((3-1)*16+N_BITS_OUT-1 downto (3-1)*16);
    data4_out <= data_out_times_1((4-1)*16+N_BITS_OUT-1 downto (4-1)*16);
    data5_out <= data_out_times_1((5-1)*16+N_BITS_OUT-1 downto (5-1)*16);
    data6_out <= data_out_times_1((6-1)*16+N_BITS_OUT-1 downto (6-1)*16);
    data7_out <= data_out_times_1((7-1)*16+N_BITS_OUT-1 downto (7-1)*16);
    data8_out <= data_out_times_1((8-1)*16+N_BITS_OUT-1 downto (8-1)*16);

end;
