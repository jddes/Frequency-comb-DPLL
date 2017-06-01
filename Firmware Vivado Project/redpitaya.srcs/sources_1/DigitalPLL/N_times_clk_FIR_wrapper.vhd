library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


entity N_times_clk_FIR_wrapper  is
Generic (
	-- these need to match what was put in the FIR compiler
	N_BITS_IN		: integer := 16;
	N_BITS_OUT 		: integer := 16
);
port (
	-- these two clocks need to be phase-locked to have a common edge (0 phase difference at the rising edges of clk_times_1)
	clk_times_1    : in  std_logic;
	clk_times_N    : in  std_logic;
	
	-- these two signals are on the clk_times_1 clock domain
	data_in        : in  std_logic_vector(N_BITS_IN-1 downto 0);
	data_out       : out std_logic_vector(N_BITS_OUT-1 downto 0)

	);
end entity;

architecture Behavioral of N_times_clk_FIR_wrapper is

	-- FIR compiler component:
	component fir_compiler_minimumphase_N_times_clk IS
		PORT (
			aclk               : IN STD_LOGIC;
			s_axis_data_tvalid : IN STD_LOGIC;
			s_axis_data_tready : OUT STD_LOGIC;
			s_axis_data_tdata  : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
			m_axis_data_tvalid : OUT STD_LOGIC;
			m_axis_data_tdata  : OUT STD_LOGIC_VECTOR(15 DOWNTO 0)
		);
	END component;

	signal m_axis_data_tvalid :  STD_LOGIC;
	signal m_axis_data_tdata  :  STD_LOGIC_VECTOR(15 DOWNTO 0);

	-- Flags used to transfer data between the two domains:
	signal flag_times_1                : std_logic                               := '0';
	signal flag_times_N_d1             : std_logic                               := '0';
	-- Data when first transfered to the "times N" clk domain
	signal data_times_N_clk_enable     : std_logic                               := '0';
	signal data_times_N                : std_logic_vector(N_BITS_IN-1 downto 0)  := (others => '0');
	
	-- extra register stage to improve timings, since we are trying to reach as close as possible to the full rate of the DSP48 blocks.
	signal data_times_N_clk_enable_reg : std_logic                               := '0';
	signal data_times_N_reg            : std_logic_vector(N_BITS_IN-1 downto 0)  := (others => '0');
	
	-- output data
	signal data_out_times_N            : std_logic_vector(N_BITS_OUT-1 downto 0) := (others => '0');
	signal data_out_times_N_reg        : std_logic_vector(N_BITS_OUT-1 downto 0) := (others => '0');
	signal data_out_times_1            : std_logic_vector(N_BITS_OUT-1 downto 0) := (others => '0');
	
begin

	-- this generates a toggling flag to sync the two domains (simply to resolve the N-cycle ambiguity between the two clks)
	process (clk_times_1)
	begin
		if rising_edge(clk_times_1) then
			flag_times_1 <= not flag_times_1;
		end if;
	end process;

	-- make the data cross to the higher clk rate domain:
	-- the crossing is simple because we 
	process (clk_times_N)
	begin
		if rising_edge(clk_times_N) then
			data_times_N_clk_enable <= '0';	-- default value
			-- we transfer the data at any toggle of the 1x flag
			flag_times_N_d1 <= flag_times_1;
			if flag_times_N_d1 /= flag_times_1 then
				data_times_N <= data_in;
				data_times_N_clk_enable <= '1';
			end if;

			-- extra register stage to improve timings, since we are trying to reach as close as possible to the full rate of the DSP48 blocks.
			data_times_N_reg <= data_times_N;
			data_times_N_clk_enable_reg <= data_times_N_clk_enable;
		end if;
	end process;

	-- FIR filter
	fir_compiler_minimumphase_N_times_clk_inst : fir_compiler_minimumphase_N_times_clk 
		port map (
			aclk               => clk_times_N,
			s_axis_data_tvalid => data_times_N_clk_enable_reg,
			s_axis_data_tready => open,	-- we don't care, the core should always be ready
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

			if m_axis_data_tvalid = '1' then
				data_out_times_N <= m_axis_data_tdata;
			end if;
			-- we add an extra register stage here to help timing
			data_out_times_N_reg <= data_out_times_N;
		end if;
	end process;
	-- then we capture it in the slower clock domain
	process (clk_times_1)
	begin
		if rising_edge(clk_times_1) then
			data_out_times_1 <= data_out_times_N_reg;
		end if;
	end process;
	-- assign output:
	data_out <= data_out_times_1;

end;
