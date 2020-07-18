library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

library work;
use work.maths_helper.all;

entity ddc_multichannel_tb is
end ddc_multichannel_tb;

architecture behavior of ddc_multichannel_tb is

    -- ddc_multichannel signals
    -- Generics as constants
    constant DATA_WIDTH  : integer := 14;
    constant FREQ_WIDTH  : integer := 48;
    constant IQ_WIDTH    : integer := 16;
    constant PHASE_WIDTH : integer := 14;

    -- Inputs
    signal clk         : std_logic                               := '0';
    signal clk_times_N : std_logic                               := '0';
    signal data1_in    : std_logic_vector(DATA_WIDTH-1 downto 0) := (others => '0');
    signal data2_in    : std_logic_vector(DATA_WIDTH-1 downto 0) := (others => '0');
    signal data3_in    : std_logic_vector(DATA_WIDTH-1 downto 0) := (others => '0');
    signal data4_in    : std_logic_vector(DATA_WIDTH-1 downto 0) := (others => '0');
    signal freq1_in    : std_logic_vector(FREQ_WIDTH-1 downto 0) := x"19DB22D0E560"; -- dec2hex(round((1/10 + 1/1000) * 2^48), 12)
    signal freq2_in    : std_logic_vector(FREQ_WIDTH-1 downto 0) := x"33B645A1CAC1"; -- dec2hex(round((2/10 + 2/1000) * 2^48), 12)
    signal freq3_in    : std_logic_vector(FREQ_WIDTH-1 downto 0) := x"4D916872B021"; -- dec2hex(round((3/10 + 3/1000) * 2^48), 12)
    signal freq4_in    : std_logic_vector(FREQ_WIDTH-1 downto 0) := x"676C8B439581"; -- dec2hex(round((4/10 + 4/1000) * 2^48), 12)
    -- Outputs
    signal clk_enable_IQ_out : std_logic;
    signal IQ1_out           : std_logic_vector(IQ_WIDTH-1 downto 0);
    signal IQ2_out           : std_logic_vector(IQ_WIDTH-1 downto 0);
    signal IQ3_out           : std_logic_vector(IQ_WIDTH-1 downto 0);
    signal IQ4_out           : std_logic_vector(IQ_WIDTH-1 downto 0);
    signal clk_enable_out    : std_logic;
    signal sync_IQ_out       : std_logic;
    signal phi1              : std_logic_vector(PHASE_WIDTH-1 downto 0);
    signal phi2              : std_logic_vector(PHASE_WIDTH-1 downto 0);
    signal phi3              : std_logic_vector(PHASE_WIDTH-1 downto 0);
    signal phi4              : std_logic_vector(PHASE_WIDTH-1 downto 0);

    signal I1, Q1 : signed(IQ_WIDTH-1 downto 0) := (others => '0');
    signal I2, Q2 : signed(IQ_WIDTH-1 downto 0) := (others => '0');
    signal I3, Q3 : signed(IQ_WIDTH-1 downto 0) := (others => '0');
    signal I4, Q4 : signed(IQ_WIDTH-1 downto 0) := (others => '0');
    -- Clock period definition
    constant clk_period : time := 5 ns;
    constant clk_times_two_period : time := 2.5 ns;
begin

    -- Unit under test
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
        data2_in          => data2_in,
        data3_in          => data3_in,
        data4_in          => data4_in,
        freq1_in          => freq1_in,
        freq2_in          => freq2_in,
        freq3_in          => freq3_in,
        freq4_in          => freq4_in,
        clk_enable_IQ_out => clk_enable_IQ_out,
        IQ1_out           => IQ1_out,
        IQ2_out           => IQ2_out,
        IQ3_out           => IQ3_out,
        IQ4_out           => IQ4_out,
        clk_enable_out    => clk_enable_out,
        sync_IQ_out       => sync_IQ_out,
        phi1              => phi1,
        phi2              => phi2,
        phi3              => phi3,
        phi4              => phi4
    );

    -- Clock process definition for "clk" and clk_times_N
    process
    begin
        clk_times_N <= '1';
        clk <= '0';
        wait for clk_times_two_period/2;
        clk_times_N <= '0';
        clk <= '0';
        wait for clk_times_two_period/2;
        clk_times_N <= '1';
        clk <= '1';
        wait for clk_times_two_period/2;
        clk_times_N <= '0';
        clk <= '1';
        wait for clk_times_two_period/2;
    end process;

    process( clk )
    begin
        if rising_edge(clk) then
            if clk_enable_IQ_out = '1' then
                if sync_IQ_out='1' then
                    I1 <= signed(IQ1_out);
                    I2 <= signed(IQ2_out);
                    I3 <= signed(IQ3_out);
                    I4 <= signed(IQ4_out);
                else
                    Q1 <= signed(IQ1_out);
                    Q2 <= signed(IQ2_out);
                    Q3 <= signed(IQ3_out);
                    Q4 <= signed(IQ4_out);
                end if;
            end if;
        end if;
    end process;

    -- Stimulus process
    process
    begin
        for I in 0 to 10-1 loop
            wait until rising_edge(clk);
                data1_in <= std_logic_vector(shift_right(cos_fixed(I, 10, data1_in'length), 1));
        end loop;
    end process;

    process
    begin
        for I in 0 to 10-1 loop
            wait until rising_edge(clk);
                data2_in <= std_logic_vector(shift_right(cos_fixed(2*I, 10, data1_in'length), 1));
        end loop;
    end process;

    process
    begin
        for I in 0 to 10-1 loop
            wait until rising_edge(clk);
                data3_in <= std_logic_vector(shift_right(cos_fixed(3*I, 10, data1_in'length), 1));
        end loop;
    end process;

    process
    begin
        for I in 0 to 10-1 loop
            wait until rising_edge(clk);
                data4_in <= std_logic_vector(shift_right(cos_fixed(4*I, 10, data1_in'length), 1));
        end loop;
    end process;

    
end;
