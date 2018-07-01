----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    20:37:21 02/24/2014 
-- Design Name: 
-- Module Name:    triangular_frequency_counter - Behavioral 
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

entity triangular_frequency_counter is
	Generic (
		N_BITS_INPUT : integer := 10					-- changing this will require changing the size of the integrators or lowering the maximum gate time
	);
    Port ( 
		clk                        : in  std_logic;
		rst_integration            : in  std_logic;
		integration_halfway        : in  std_logic;                                        -- used to change the sign of the second integrator's input
		data_input                 : in  std_logic_vector (N_BITS_INPUT-1 downto 0);
		data_output_rect           : out std_logic_vector (64-1 downto 0);
		output_clk_enable_rect     : out std_logic;
		data_output_triangle       : out std_logic_vector (64-1 downto 0);
		output_clk_enable_triangle : out std_logic

	);
end triangular_frequency_counter;

architecture Behavioral of triangular_frequency_counter is

	-- 1st Integrator (from frequency to phase)
	-- scaled appropriately for no wrapping for 200e6 accumulated samples:
	signal phase_accumulator               : signed(10+28-1 downto 0) := (others => '0');
	
	-- 2nd Integrator, used to average over phase values
	signal rst_integration_delayed         : std_logic := '0';
	signal bPositiveSign                   : std_logic := '0';
	signal phase_2nd_accumulator           : signed(64-1 downto 0) := (others => '0');
	
	-- Output stages
	signal output_register_rect            : signed(64-1 downto 0) := (others => '0');
	signal output_register_clk_enable_rect : std_logic := '0';
	
	signal output_register_tri             : signed(64-1 downto 0) := (others => '0');
	signal output_register_clk_enable_tri  : std_logic := '0';
	
begin

	
	-- Integrator from frequency to phase:
	process (clk)
	begin
		if rising_edge(clk) then

			if rst_integration = '1' then
				-- restart integration:
				phase_accumulator <= resize(signed(data_input), phase_accumulator'length);

			else
				-- integrate normally:
				phase_accumulator <= phase_accumulator + resize(signed(data_input), phase_accumulator'length);
				output_register_clk_enable_rect <= '0';
			end if;
			
			if integration_halfway = '1' then
				-- dump output for "type Pi" or "rectangular averaging" counter:
				output_register_rect <= resize(phase_accumulator, output_register_rect'length);
				output_register_clk_enable_rect <= '1';
			end if;
				
		end if;
	end process;
	data_output_rect <= std_logic_vector(output_register_rect);
	output_clk_enable_rect <= output_register_clk_enable_rect;
	
	-- Integrator to average over phase values.
	-- Changes integration sign in the middle of the integration window
	process (clk)
	begin
		if rising_edge(clk) then
			-- 
			rst_integration_delayed <= rst_integration;
--			integration_halfway_delayed <= integration_halfway;
			
			if rst_integration_delayed = '1' then
				-- restart integration:
				phase_2nd_accumulator <= -resize(phase_accumulator, phase_2nd_accumulator'length);
				bPositiveSign <= '0';
			else
				-- integrate normally:
				if integration_halfway = '0' then
					if bPositiveSign = '0' then
						phase_2nd_accumulator <= phase_2nd_accumulator - resize(phase_accumulator, phase_2nd_accumulator'length);
					else
						phase_2nd_accumulator <= phase_2nd_accumulator + resize(phase_accumulator, phase_2nd_accumulator'length);
					end if;
				else
					-- the midpoint is special: we don't run the second integrator. this is to give the correct scaling
					
				end if;
				-- change sign if we have reached the middle of the integration window:
				if integration_halfway = '1' then
					bPositiveSign <= '1';
				end if;
			end if;
			
		end if;
	end process;
	
	-- Output register, samples the output result at the right moment:
	process (clk)
	begin
		if rising_edge(clk) then
		
			if rst_integration_delayed = '1' then
				-- restart integration:
				output_register_tri <= phase_2nd_accumulator;
				output_register_clk_enable_tri <= '1';
			else
				output_register_clk_enable_tri <= '0';
			end if;
			
		end if;
	end process;
	data_output_triangle <= std_logic_vector(output_register_tri);
	output_clk_enable_triangle <= output_register_clk_enable_tri;

end Behavioral;

