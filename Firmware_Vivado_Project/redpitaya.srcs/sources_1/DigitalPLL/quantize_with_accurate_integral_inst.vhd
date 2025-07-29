---- quantize_with_accurate_integral signals
---- Generics as constants
--constant INPUT_WIDTH  : integer := 16;
--constant OUTPUT_WIDTH : integer := 10;
--type two_dim_array is array (natural range <>, natural range <>) of std_logic;
---- Inputs
--signal clk     : std_logic                                := '0';
--signal data_in : std_logic_vector(INPUT_WIDTH-1 downto 0) := (others => '0');
---- Outputs
--signal data_out : std_logic_vector(OUTPUT_WIDTH-1 downto 0);
--
quantize_with_accurate_integral_inst : entity work.quantize_with_accurate_integral
generic map (
	INPUT_WIDTH  => INPUT_WIDTH,
	OUTPUT_WIDTH => OUTPUT_WIDTH
) port map (
	clk      => clk,
	data_in  => data_in,
	data_out => data_out
);