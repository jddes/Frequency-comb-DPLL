-------------------------------------------------------
-- Design Name : lfsr
-- File Name   : lfsr.vhd
-- Function    : Linear feedback shift register
-- Coder       : Deepak Kumar Tala (Verilog)
-- Translator  : Alexander H Pham (VHDL)
-- Modified by: JDD (modified the taps because it didn't seem to work as it was (8 bits, many-to-one configuration, input = xnor(taps(7), taps(3)), starting from 0).
-------------------------------------------------------
library ieee;
    use ieee.std_logic_1164.all;

entity lfsr_8bits is
  port (
    cout   :out std_logic_vector (6 downto 0);-- Output of the counter
    enable :in  std_logic;                    -- Enable counting
    clk    :in  std_logic;                    -- Input rlock
    reset  :in  std_logic                     -- Input reset
  );
end entity;

architecture rtl of lfsr_8bits is
    signal count           :std_logic_vector (6 downto 0) := (others => '1');
    signal linear_feedback :std_logic := '0';

begin
	linear_feedback <= (count(6) xor count(5));


	process (clk, reset)
	begin
		if rising_edge(clk) then
			if reset = '1' then
				count <= (others => '1');
			else
				if (enable = '1') then
--					count <= (count(6) & count(5) & count(4) & count(3) 
--								& count(2) & count(1) & count(0) & 
--								linear_feedback);
					count <= (count(5 downto 0) & linear_feedback);

				end if;
			end if;
		end if;
	end process;

	cout <= count;
end architecture;