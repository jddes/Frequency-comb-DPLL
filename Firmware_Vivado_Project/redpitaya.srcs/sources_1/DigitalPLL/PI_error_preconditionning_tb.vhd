library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

entity PI_error_preconditionning_tb is
end PI_error_preconditionning_tb;

architecture behavior of PI_error_preconditionning_tb is

	-- PI_error_preconditionning signals
	-- Generics as constants
	constant INPUT_WIDTH  : integer := 8+10;
	constant OUTPUT_WIDTH : integer := 8;
	constant LOG2_DIVIDE  : integer := 4;
	-- Inputs
	signal clk                : std_logic                                := '0';
	signal input_clk_enable   : std_logic                                := '0';
	signal unwrapped_phase_in : std_logic_vector(INPUT_WIDTH-1 downto 0) := (others => '0');
	-- Outputs
	signal output_clk_enable : std_logic;
	signal data_out          : std_logic_vector(OUTPUT_WIDTH-1 downto 0);

	-- Clock period definition
	constant clk_period : time := 5 ns;
begin

	-- Unit under test
	PI_error_preconditionning_inst : entity work.PI_error_preconditionning
	generic map (
		INPUT_WIDTH  => INPUT_WIDTH,
		OUTPUT_WIDTH => OUTPUT_WIDTH,
		LOG2_DIVIDE  => LOG2_DIVIDE
	) port map (
		clk                => clk,
		input_clk_enable   => input_clk_enable,
		unwrapped_phase_in => unwrapped_phase_in,
		output_clk_enable  => output_clk_enable,
		data_out           => data_out
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

		-- test #1: check clk enable propagation with inputs at low rates
		wait until rising_edge(clk);
			input_clk_enable <= '1';
			unwrapped_phase_in <= std_logic_vector(to_signed(1000, unwrapped_phase_in'length));
		wait until rising_edge(clk);
			input_clk_enable <= '0';
			unwrapped_phase_in <= std_logic_vector(to_signed(0, unwrapped_phase_in'length));
		wait for clk_period*100;
		wait until rising_edge(clk);
			input_clk_enable <= '1';
			unwrapped_phase_in <= std_logic_vector(to_signed(2000, unwrapped_phase_in'length));
		wait until rising_edge(clk);
			input_clk_enable <= '0';
			unwrapped_phase_in <= std_logic_vector(to_signed(0, unwrapped_phase_in'length));
		wait for clk_period*100;


		wait for clk_period*1000;
		-- test #2: make sure the LSBs which get quantized are always 0,
		-- so we never get carries messing with the values,
		-- and exhaustively test the saturation behavior, looking for signs of wrapping
	    for I in 0 to 2**(INPUT_WIDTH-LOG2_DIVIDE)-1 loop
	        wait until rising_edge(clk);
		--		-- I(LOG2_DIVIDE-1 downto 0) <= (others => '0');
	            input_clk_enable <= '1';
				unwrapped_phase_in <= std_logic_vector(to_signed(-2**(INPUT_WIDTH-1)+I*2**LOG2_DIVIDE, INPUT_WIDTH));
				unwrapped_phase_in(LOG2_DIVIDE-1 downto 0) <= (others => '0');

	    end loop;


	    input_clk_enable <= '0';
		wait for clk_period*1000;
		-- test #3: add values in the LSBs which get quantized,
		-- while making the input values close to the limits,
		-- to check that no wrapping is seen when using the carry mechanism
		-- of quantize_with_accurate_integral
		for k in 0 to 10*2**LOG2_DIVIDE loop
	        wait until rising_edge(clk);
				input_clk_enable <= '1';
				unwrapped_phase_in <= ('0', others => '1');
		end loop;

		for k in 0 to 10*2**LOG2_DIVIDE loop
	        wait until rising_edge(clk);
				input_clk_enable <= '1';
				unwrapped_phase_in <= ('1', others => '0');
		end loop;

		for k in 0 to 10*2**LOG2_DIVIDE loop
	        wait until rising_edge(clk);
				input_clk_enable <= '1';
				unwrapped_phase_in <= ('1', others => '0');
				unwrapped_phase_in(LOG2_DIVIDE downto 0) <= (others => '1');
		end loop;

		wait;

    end process;
    
end;
