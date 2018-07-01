----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    17:38:05 02/09/2014 
-- Design Name: 
-- Module Name:    dither_lockin - Behavioral 
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

entity dither_lockin is
	Generic (
		N_BITS_INPUT : integer := 10;
		N_BITS_OUTPUT : integer := 16;
		COUNTER_BITS : integer := 27;	-- 27 bits gives ~ 134 Millions clock cycles, or 1.34 seconds at 100 MHz clock rate
		SYNC_DELAY : integer := 50;		-- should be approximately equal to the known system delay, from output to input, so that most of the signal shows up in the real part
		INTEGRATORS_BITS : integer := 16*3	-- should be set to a high enough value to hold the result without wrapping (total size required is log2((N_periods_integration_minus_one+1) * 4*(modulation_period_divided_by_4_minus_one+1)) + N_BITS_INPUT)
			-- but should also be a multiple of 16 bits, since this is the size of the Opal Kelly wires which will be used to read out the result.
			-- initial estimation of worst case: log2(100e6 integration cycles)+10 bits input = 37 bits
			-- so we'll go for 3 Wires, or a total of 48 bits for each integrator.
	);
    Port ( clk : in  STD_LOGIC;
				data_input : std_logic_vector(N_BITS_INPUT-1 downto 0);
	 
           bOutputEnable : in  STD_LOGIC;
			  N_periods_integration_minus_one : in  STD_LOGIC_VECTOR (COUNTER_BITS-1 downto 0);
           modulation_period_divided_by_4_minus_one : in  STD_LOGIC_VECTOR (COUNTER_BITS-1 downto 0);
			  
           modulation_amplitude : in  STD_LOGIC_VECTOR (N_BITS_OUTPUT-1 downto 0);
           output_to_dac : out  STD_LOGIC_VECTOR (N_BITS_OUTPUT-1 downto 0);
           result_I : out  STD_LOGIC_VECTOR (INTEGRATORS_BITS-1 downto 0);
           result_Q : out  STD_LOGIC_VECTOR (INTEGRATORS_BITS-1 downto 0);
           output_clk_enable : out  STD_LOGIC);
end dither_lockin;

architecture Behavioral of dither_lockin is
	-- register stage for the input signal:
	signal data_input_reg : signed(N_BITS_INPUT-1 downto 0) := (others => '0');
	-- delay line for the sync signals:
	signal sync_I, sync_Q, sync_I_delayed, sync_I_delayed_last, sync_Q_delayed, sync_Q_delayed_last : std_logic := '0';
	signal sync_I_srl, sync_Q_srl : std_logic_vector(SYNC_DELAY-1 downto 0) := (others => '0');
	
	signal integrator_I, integrator_Q, result_I_internal, result_Q_internal : signed(INTEGRATORS_BITS-1 downto 0) := (others => '0');
	signal output_clk_enable_internal : std_logic := '0';
	
	-- counter which counts the modulation periods:
	signal modulation_periods_counter : unsigned(COUNTER_BITS-1 downto 0) := (others => '0');
begin

   quadrature_dither_generator_inst: entity work.quadrature_dither_generator
	GENERIC MAP (
		N_BITS_OUTPUT => N_BITS_OUTPUT,
		COUNTER_BITS => COUNTER_BITS
	
	)
	PORT MAP (
          clk => clk,
          modulation_period_divided_by_4_minus_one => modulation_period_divided_by_4_minus_one,
          modulation_amplitude => modulation_amplitude,
          bOutputEnable => bOutputEnable,
          output_to_dac => output_to_dac,
          sync_I => sync_I,
          sync_Q => sync_Q
        );
		  
	-- delay line for the sync signals:
	process (clk)
	begin
		if rising_edge(clk) then
			sync_I_srl <= sync_I_srl(sync_I_srl'left-1 downto 0) & sync_I;
			sync_Q_srl <= sync_Q_srl(sync_Q_srl'left-1 downto 0) & sync_Q;
			
			sync_I_delayed <= sync_I_srl(sync_I_srl'left);
			sync_Q_delayed <= sync_Q_srl(sync_Q_srl'left);
			
			sync_I_delayed_last <= sync_I_delayed;
			sync_Q_delayed_last <= sync_Q_delayed;
			
			-- register for the input data (to make achieving timing closure easier):
			data_input_reg <= signed(data_input);
		end if;
	end process;
	
	-- This process counts the number of modulation period.
	-- Counts every rising edge of sync_I_delayed, from 0 to 
	process (clk)
	begin
		if rising_edge(clk) then
			if sync_I_delayed = '1' and sync_I_delayed_last = '0' then
				if modulation_periods_counter < unsigned(N_periods_integration_minus_one) then
					modulation_periods_counter <= modulation_periods_counter + 1;
				else
					modulation_periods_counter <= (others => '0');
				end if;
			end if;
		end if;
	end process;
	
	-- Integrators, synchronized to sync_I_delayed
	process (clk)
	begin
		if rising_edge(clk) then
			if sync_I_delayed = '1' and sync_I_delayed_last = '0' then
				if modulation_periods_counter = 0 then
					-- dump results:
					result_I_internal <= integrator_I;
					result_Q_internal <= integrator_Q;
					output_clk_enable_internal <= '1';
					-- Immediately start integrating the next sample:
					-- since we know that we are on a rising edge of sync_I, we know that we should integrate positively for I and negatively for Q:
					integrator_I <=  resize(data_input_reg, INTEGRATORS_BITS);
					integrator_Q <= -resize(data_input_reg, INTEGRATORS_BITS);
				else
					-- normal mode: integrate, except that we know the signs:
					-- since we know that we are on a rising edge of sync_I, we know that we should integrate positively for I and negatively for Q:
					integrator_I <= integrator_I + resize(data_input_reg, INTEGRATORS_BITS);
					integrator_Q <= integrator_Q - resize(data_input_reg, INTEGRATORS_BITS);
					output_clk_enable_internal <= '0';
				end if;
			else
				-- integrate, with a positive or a negative sign
				if sync_I_delayed = '1' then
					integrator_I <= integrator_I + resize(data_input_reg, INTEGRATORS_BITS);
				else
					integrator_I <= integrator_I - resize(data_input_reg, INTEGRATORS_BITS);
				end if;
				
				if sync_Q_delayed = '1' then
					integrator_Q <= integrator_Q + resize(data_input_reg, INTEGRATORS_BITS);
				else
					integrator_Q <= integrator_Q - resize(data_input_reg, INTEGRATORS_BITS);
				end if;
				
				output_clk_enable_internal <= '0';
				
			end if;
		end if;
	end process;
	result_I <= std_logic_vector(result_I_internal);
	result_Q <= std_logic_vector(result_Q_internal);
	output_clk_enable <= output_clk_enable_internal;
	
end Behavioral;

