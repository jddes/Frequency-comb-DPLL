library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

entity linear_ramp_gen_tb is
end linear_ramp_gen_tb;

architecture behavior of linear_ramp_gen_tb is

	-- linear_ramp_gen signals
	-- Generics as constants
    constant INPUT_DATA_WIDTH  : integer := 64;
    constant OUTPUT_DATA_WIDTH : integer := 48;
    constant RIGHTSHIFT        : integer := 16;
	constant COUNTER_WIDTH : integer := 32;
	-- Inputs
	signal clk           : std_logic                               := '0';
	signal reset_ramp    : std_logic                               := '0';
	signal clk_enable_in : std_logic                               := '0';
	signal ramp_slope    : std_logic_vector(INPUT_DATA_WIDTH-1 downto 0) := (others => '0');
	-- Outputs
	signal data_out : std_logic_vector(OUTPUT_DATA_WIDTH-1 downto 0);

	signal counter : unsigned(COUNTER_WIDTH-1 downto 0) := (others => '0');
	-- Clock period definition
	constant clk_period : time := 5 ns;
begin

	-- Unit under test
	linear_ramp_gen_inst : entity work.linear_ramp_gen
	generic map (
		INPUT_DATA_WIDTH  => INPUT_DATA_WIDTH,
		OUTPUT_DATA_WIDTH => OUTPUT_DATA_WIDTH,
		RIGHTSHIFT        => RIGHTSHIFT
	) port map (
		clk           => clk,
		reset_ramp    => reset_ramp,
		clk_enable_in => clk_enable_in,
		ramp_slope    => ramp_slope,
		data_out      => data_out
	);

	-- Clock process definition for "clk"
	process
	begin
		clk <= '0';
		wait for clk_period/2;
		clk <= '1';
		wait for clk_period/2;
	end process;

	process (clk)
	begin
		if rising_edge(clk) then
			clk_enable_in <= '0';
			if counter < 100-1 then
				counter <= counter + 1;
			else
				counter <= (others => '0');
				clk_enable_in <= '1';
			end if;
		end if;
	end process;

	-- Stimulus process
	process
	begin
		wait until rising_edge(clk);
			ramp_slope <= std_logic_vector(to_signed(10000, ramp_slope'length));
		wait for clk_period*10000;
		wait until rising_edge(clk);
			ramp_slope <= std_logic_vector(to_signed(-1000, ramp_slope'length));
		wait for clk_period*10000;
		wait until rising_edge(clk);
			reset_ramp <= '1';
		wait for clk_period*10000;
		wait until rising_edge(clk);
			reset_ramp <= '0';
		wait for clk_period*10000;

		wait until rising_edge(clk);
		wait;

    end process;
    
end;
