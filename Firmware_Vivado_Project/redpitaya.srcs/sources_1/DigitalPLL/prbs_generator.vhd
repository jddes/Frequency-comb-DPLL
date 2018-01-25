----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    13:30:40 05/05/2014 
-- Design Name: 
-- Module Name:    prbs_generator - Behavioral 
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

entity prbs_generator is
    Port ( clk : in  STD_LOGIC;
           trigger : in  STD_LOGIC;
			  chip_duration : in std_logic_vector(16-1 downto 0);
			  number_of_chips : in std_logic_vector(16-1 downto 0);
			  bSequencePolarityInvert : in std_logic;
           prbs_out : out  STD_LOGIC);
end prbs_generator;

architecture Behavioral of prbs_generator is
	signal clk_enable_counter : unsigned(32-1 downto 0) := (others => '0');
	signal clk_enable : std_logic := '0';
	
	signal bStateWaiting : std_logic := '1';
	signal chips_counter : unsigned(32-1 downto 0) := (others => '0');
	signal trigger_last : std_logic := '0';
	
	signal lfsr_reset : std_logic := '1';
	signal lfsr_out : std_logic_vector(7-1 downto 0);
begin


	-- Clock enable counter
	process (clk)
	begin
		if rising_edge(clk) then
			trigger_last <= trigger;
			
			if bStateWaiting = '1' then
				if trigger = '1' and trigger_last = '0' then
					clk_enable_counter <= (others => '0');
					chips_counter <= (others => '0');
					bStateWaiting <= '0';
				end if;
				lfsr_reset <= '1';
				clk_enable <= '0';
				
			else
				-- we are outputing the sequence
				lfsr_reset <= '0';
				
				-- Clk enable generation
				if clk_enable_counter >= unsigned(chip_duration)-1 then
					clk_enable <= '1';
					clk_enable_counter <= (others => '0');
				else
					clk_enable <= '0';
					clk_enable_counter <= clk_enable_counter + 1;
				end if;
				
				-- count the bits and stop the LFSR when we are done:
				if clk_enable = '1' then
					
					if chips_counter < unsigned(number_of_chips) then
						chips_counter <= chips_counter + 1;
					else
						-- sequence is finished.
						bStateWaiting <= '1';
					end if;
					
				end if;
			end if;

		end if;
	end process;


	-- PRN generator, 7 bits:
	-- The name says 8 bits, but its really a 7 bits counter (2^7-1 sequence length)
	lfsr_8bits_inst : entity work.lfsr_8bits
	port map (
		 cout   => lfsr_out,						-- lfsr output
		 enable => clk_enable,					-- Enable counting
		 clk    => clk,                    		-- Input clock
		 reset  => lfsr_reset                  -- Input reset
	  );
--	lfsr_enable_actual <= (lfsr_enable and clk_enable);
--	prbs_out <= (lfsr_out(lfsr_out'left) xor bSequencePolarityInvert);
	prbs_out <= (lfsr_out(0) xor bSequencePolarityInvert);

end Behavioral;

