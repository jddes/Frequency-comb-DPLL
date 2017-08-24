library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity frequency_testbench is
end frequency_testbench;

architecture behavior of frequency_testbench is

	-- Inputs
	signal clk :  std_logic;
	signal data_in :  std_logic_vector(16-1 downto 0) := (others => '0');
	signal vco_input_voltage	: std_logic_vector (16-1 downto 0)  := "1000000000000000" ; -- intermediate signal to change the selected value that controls the frequency of the VCO
	
	-- Outputs
	signal vco_frequency 		: std_logic_vector (48-1 downto 0)  := (others => '0') ; -- signal that contains the value of the frequency of the vco
    signal intermediate         : std_logic_vector (48-1 downto 0)  := (others => '0') ; -- signal that contains the value of the frequency of the vco
	
	-- Clock period definition
	constant clk_period : time := 8 ns;
begin

	-- Clock process definition for "clk"
	process
	begin
		clk <= '0';
		wait for clk_period/2;
		clk <= '1';
		wait for clk_period/2;
	end process;
    intermediate  <= std_logic_vector(signed(vco_input_voltage & "0000000000000000000000000000000") + "000000000000000000000000000000000000000000000000");
	vco_frequency <= std_logic_vector(signed(vco_input_voltage & "0000000000000000000000000000000") + "010000000000000000000000000000000000000000000000") ;
	process (clk)
	begin
		if rising_edge(clk) then
		  vco_input_voltage <= std_logic_vector(to_signed(to_integer(signed( vco_input_voltage )) + 1000, 16));
		end if;
	end process;

	-- Stimulus process
	process
	begin
		wait for clk_period * 1000;
		
		wait;
	end process;
end;
