----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    19:53:15 02/09/2014 
-- Design Name: 
-- Module Name:    dither_lockin_wrapper - Behavioral 
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
-- Description: 
--
-- Dependencies: 
--
-- Revision: 
-- Revision 0.01 - File Created
-- Additional Comments: 
--
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity dither_lockin_wrapper is
	Generic (
		BASE_ADDRESS     : integer := 0;
		CMD_BUS_BITS     : integer := 16;
		N_BITS_INPUT     : integer := 10;
		N_BITS_OUTPUT    : integer := 16;
		COUNTER_BITS     : integer := 27;    -- 27 bits gives ~ 134 Millions clock cycles, or 1.34 seconds at 100 MHz clock rate
		SYNC_DELAY       : integer := 50;        -- should be approximately equal to the known system delay, from output to input, so that most of the signal shows up in the real part
		INTEGRATORS_BITS : integer := 16*3    -- should be set to a high enough value to hold the result without wrapping (total size required is log2((N_periods_integration_minus_one+1) * 4*(modulation_period_divided_by_4_minus_one+1)) + N_BITS_INPUT)
		-- but should also be a multiple of 16 bits, since this is the size of the Opal Kelly wires which will be used to read out the result.
		-- initial estimation of worst case: log2(100e6 integration cycles)+10 bits input = 37 bits
		-- so we'll go for 3 Wires, or a total of 48 bits for each integrator.
	);
	Port ( 
			clk           : in  std_logic;
		data_input        : in  std_logic_vector (N_BITS_INPUT-1       downto 0);
		cmd_trig          : in  std_logic;
		cmd_addr          : in  std_logic_vector (CMD_BUS_BITS-1       downto 0);
		cmd_data1         : in  std_logic_vector (CMD_BUS_BITS-1       downto 0);
		cmd_data2         : in  std_logic_vector (CMD_BUS_BITS-1       downto 0);
		output_to_dac     : out std_logic_vector (N_BITS_OUTPUT-1      downto 0);
		results_output_I  : out std_logic_vector (INTEGRATORS_BITS-1   downto 0);
		results_output_Q  : out std_logic_vector (INTEGRATORS_BITS-1   downto 0);
		output_clk_enable : out std_logic
	);
end dither_lockin_wrapper;

architecture Behavioral of dither_lockin_wrapper is
	-- local buffered copy of the cmd bus:
	signal cmd_trig_internal                            : std_logic        := '0';
	signal cmd_addr_internal                            : std_logic_vector (CMD_BUS_BITS-1   downto 0) := (others => '0');
	signal cmd_data_internal                            : std_logic_vector (2*CMD_BUS_BITS-1 downto 0) := (others => '0');
	
	-- parallel bus registers:
	signal bOutputEnable                                : std_logic        := '0';
	signal modulation_period_divided_by_4_minus_one     : std_logic_vector(COUNTER_BITS-1  downto 0)   := std_logic_vector(to_unsigned(100e6/1e3/4-1, COUNTER_BITS));    -- about 1 kHz
	signal modulation_amplitude                         : std_logic_vector(N_BITS_OUTPUT-1 downto 0)   := std_logic_vector(to_unsigned(2*2**6       , N_BITS_OUTPUT));
	signal N_periods_integration_minus_one              : std_logic_vector(COUNTER_BITS-1  downto 0)   := std_logic_vector(to_unsigned(100-1        , COUNTER_BITS));    -- 100 periods at 1 kHz, to give 10 Hz update rate, or 0.1 sec integration time
	signal bOutputEnable_vector                         : std_logic_vector(0               downto 0);
	
	
	-- results output
	signal result_I, result_Q                           : std_logic_vector (INTEGRATORS_BITS-1 downto 0) := (others => '0');
begin

	-- Buffer the cmd bus:
	process (clk)
	begin
		if rising_edge(clk) then
			cmd_trig_internal <= cmd_trig;
			cmd_addr_internal <= cmd_addr;
			cmd_data_internal <= (cmd_data2 & cmd_data1);
		end if;
	end process;
	
	-- parallel bus registers:
	parallel_bus_register_enable: entity work.parallel_bus_register_32bits_or_less
	Generic map (
		REGISTER_SIZE => bOutputEnable_vector'length,
		REGISTER_DEFAULT_VALUE => 0,
		ADDRESS => BASE_ADDRESS+0
	)
	Port map (
		clk => clk,
		bus_strobe => cmd_trig_internal,
		bus_address => cmd_addr_internal,
		bus_data => cmd_data_internal,
		register_output => bOutputEnable_vector
	);
	bOutputEnable <= bOutputEnable_vector(0);
	
	parallel_bus_register_period: entity work.parallel_bus_register_32bits_or_less
	Generic map (
		REGISTER_SIZE => modulation_period_divided_by_4_minus_one'length,
		REGISTER_DEFAULT_VALUE => 100e6/1e3/4-1,	-- about 1 kHz
		ADDRESS => BASE_ADDRESS+1
	)
	Port map (
		clk => clk,
		bus_strobe => cmd_trig_internal,
		bus_address => cmd_addr_internal,
		bus_data => cmd_data_internal,
		register_output => modulation_period_divided_by_4_minus_one
	);
	
	parallel_bus_register_N_periods: entity work.parallel_bus_register_32bits_or_less
	Generic map (
		REGISTER_SIZE => N_periods_integration_minus_one'length,
		REGISTER_DEFAULT_VALUE => 100-1,	-- 100 periods at 1 kHz, to give 10 Hz update rate, or 0.1 sec integration time
		ADDRESS => BASE_ADDRESS+2
	)
	Port map (
		clk => clk,
		bus_strobe => cmd_trig_internal,
		bus_address => cmd_addr_internal,
		bus_data => cmd_data_internal,
		register_output => N_periods_integration_minus_one
	);

	parallel_bus_register_amplitude: entity work.parallel_bus_register_32bits_or_less
	Generic map (
		REGISTER_SIZE => modulation_amplitude'length,
		REGISTER_DEFAULT_VALUE => 1,
		ADDRESS => BASE_ADDRESS+3
	)
	Port map (
		clk => clk,
		bus_strobe => cmd_trig_internal,
		bus_address => cmd_addr_internal,
		bus_data => cmd_data_internal,
		register_output => modulation_amplitude
	);
	
   dither_lockin_inst: entity work.dither_lockin
	GENERIC MAP (
		N_BITS_INPUT => N_BITS_INPUT,
		N_BITS_OUTPUT => N_BITS_OUTPUT,
		COUNTER_BITS => COUNTER_BITS,
		SYNC_DELAY => SYNC_DELAY,
		INTEGRATORS_BITS => INTEGRATORS_BITS
	
	)
	PORT MAP (
          clk => clk,
          data_input => data_input,
          bOutputEnable => bOutputEnable,
          N_periods_integration_minus_one => N_periods_integration_minus_one,
          modulation_period_divided_by_4_minus_one => modulation_period_divided_by_4_minus_one,
          modulation_amplitude => modulation_amplitude,
          output_to_dac => output_to_dac,
          result_I => result_I,
          result_Q => result_Q,
          output_clk_enable => output_clk_enable
        );

	results_output_I <= result_I;
	results_output_Q <= result_Q;
	--results_output <= result_Q & result_I;
	
	
end Behavioral;

