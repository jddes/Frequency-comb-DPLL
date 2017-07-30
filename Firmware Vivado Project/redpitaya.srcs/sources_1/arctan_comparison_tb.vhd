library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

entity arctan_comparison_tb is
end arctan_comparison_tb;

architecture behavior of arctan_comparison_tb is
	component fast_arctan is
	port (
	    clk          : in  std_logic;
	    ce           : in  std_logic;
	    input_x      : in  std_logic_vector(16-1 downto 0);
	    input_y      : in  std_logic_vector(16-1 downto 0);
	    angle        : out std_logic_vector(20-1 downto 0)
	);
	end component;


	-- Inputs
	signal clk     : std_logic := '0';
	signal ce      : std_logic := '1';
	signal input_x : std_logic_vector(16-1 downto 0) := (others => '0');
	signal input_y : std_logic_vector(16-1 downto 0) := (others => '0');
	
	-- Outputs
	signal angle_fast : std_logic_vector(20-1 downto 0);
	signal angle_fast_narrow : std_logic_vector (10 downto 0);


    signal ramp : std_logic_vector(16-1 downto 0) := (others => '0');

	signal reg0_input_x : std_logic_vector(16-1 downto 0) := (others => '0');
	signal reg1_input_x : std_logic_vector(16-1 downto 0) := (others => '0');
	signal reg2_input_x : std_logic_vector(16-1 downto 0) := (others => '0');
	signal reg3_input_x : std_logic_vector(16-1 downto 0) := (others => '0');
	signal reg4_input_x : std_logic_vector(16-1 downto 0) := (others => '0');
	signal reg5_input_x : std_logic_vector(16-1 downto 0) := (others => '0');
	signal reg6_input_x : std_logic_vector(16-1 downto 0) := (others => '0');

	signal reg0_input_y : std_logic_vector(16-1 downto 0) := (others => '0');
	signal reg1_input_y : std_logic_vector(16-1 downto 0) := (others => '0');
	signal reg2_input_y : std_logic_vector(16-1 downto 0) := (others => '0');
	signal reg3_input_y : std_logic_vector(16-1 downto 0) := (others => '0');
	signal reg4_input_y : std_logic_vector(16-1 downto 0) := (others => '0');
	signal reg5_input_y : std_logic_vector(16-1 downto 0) := (others => '0');
	signal reg6_input_y : std_logic_vector(16-1 downto 0) := (others => '0');

	signal input_x_real : real := 0.0;
	signal input_y_real : real := 0.0;

	signal angle_real : real := 0.0;
	signal angle_wide : std_logic_vector(32-1 downto 0) := (others => '0');
	signal angle_ref : std_logic_vector(20-1 downto 0) := (others => '0');
	signal angle_error : std_logic_vector(20-1 downto 0) := (others => '0');
	
	signal angle : std_logic_vector(20-1 downto 0) := (others => '0');

	-- Clock period definition
	constant clk_period : time := 8 ns;
begin

	-- Unit under test
	--fast_arctan_inst : fast_arctan
	--port map (
	--	clk => clk,
	--	ce => ce,
	--	input_x => input_x,
	--	input_y => input_y,
	--	angle => angle
	--);

	process (clk) is

	begin
		if rising_edge(clk) then
			ramp <= std_logic_vector(signed(ramp) + 1);
		end if;
	end process;

	process (clk) is
	begin
		if rising_edge(clk) then
			reg0_input_x <= input_x;
			reg1_input_x <= reg0_input_x;
			reg2_input_x <= reg1_input_x;
			reg3_input_x <= reg2_input_x;
			reg4_input_x <= reg3_input_x;
			reg5_input_x <= reg4_input_x;
			reg6_input_x <= reg5_input_x;

			reg0_input_y <= input_y;
			reg1_input_y <= reg0_input_y;
			reg2_input_y <= reg1_input_y;
			reg3_input_y <= reg2_input_y;
			reg4_input_y <= reg3_input_y;
			reg5_input_y <= reg4_input_y;
			reg6_input_y <= reg5_input_y;
		end if;
	end process;

	input_x_real <= real(to_integer(signed(reg4_input_x)));
	input_y_real <= real(to_integer(signed(reg4_input_y)));
	angle_real <= ARCTAN(input_y_real, input_x_real);
	angle_wide <= std_logic_vector(to_signed(integer(angle_real*1048576.0/6.283185307179586), 32));
	angle_ref <= angle_wide(20-1 downto 0);

	angle_error <= std_logic_vector(signed(angle) - signed(angle_ref));

	-- Clock process definition for "clk"
	process
	begin
		clk <= '0';
		wait for clk_period/2;
		clk <= '1';
		wait for clk_period/2;
	end process;


	input_y <= ramp;
	input_x <= std_logic_vector(to_signed(3456, 16));

	-- Stimulus process
	process
	begin
		wait for clk_period*10;
		wait until rising_edge(clk);
		
		--wait for clk_period*30;
		--wait until rising_edge(clk);
		--ce <= '0';

		--wait for clk_period*30;
		--wait until rising_edge(clk);
		--ce <= '1';

		wait;
	end process;
	
end architecture;
