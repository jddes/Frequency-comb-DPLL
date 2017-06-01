library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity internal_vco_testbench is
end internal_vco_testbench;

architecture behavior of internal_vco_testbench is
	constant DATA_WIDTH            : integer := 16;    -- this cannot be changed without recompiling the DDS core
	constant AMPLITUDE_WIDTH       : integer := 16;            -- this should fit in a DSP47 mult


	-- Inputs
	signal clk :  std_logic;
	signal frequency :  std_logic_vector (47 downto 0) := ('0', '0', '0', '0', '0', '0', '0', '0', '1', others => '0');
	signal amplitude : std_logic_vector (amplitude_width-1 downto 0) := std_logic_vector(to_signed((2**15)-1, 16));
	
	-- Outputs
	signal cosine_out : std_logic_vector (data_width-1 downto 0);
	signal sine_out : std_logic_vector (data_width-1 downto 0);
	
	-- Clock period definition
	constant clk_period : time := 5 ns;
begin

	-- Unit under test
	internal_vco_inst : entity work.internal_vco
	port map (
		clk => clk,
		frequency => frequency,
		amplitude => amplitude,
		cosine_out => cosine_out,
		sine_out => sine_out
	);

	-- Clock process definition for "clk"
	process
	begin
		clk <= '0';
		wait for clk_period/2;
		clk <= '1';
		wait for clk_period/2;
	end process;

	-- Stimulus process
	process
	begin
		wait for clk_period*10;
		wait until rising_edge(clk);
		wait for 12 us;
		wait until rising_edge(clk);
		amplitude <= std_logic_vector(to_signed( 2**14, 16));
		wait;
	end process;
end;
