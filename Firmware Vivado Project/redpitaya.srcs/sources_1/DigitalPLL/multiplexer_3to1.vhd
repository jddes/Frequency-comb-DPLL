library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


entity multiplexer_3to1 is
Generic (
	SIGNAL_LENGTH	: integer := 10
);

port (
	clk										: in  std_logic;
	selector_mux							: in  std_logic_vector(2-1 downto 0);
    
    -- mux
	in0_mux							 	    : in  std_logic_vector(SIGNAL_LENGTH-1 downto 0);
	in1_mux							 	    : in  std_logic_vector(SIGNAL_LENGTH-1 downto 0);
    in2_mux                                 : in  std_logic_vector(SIGNAL_LENGTH-1 downto 0);
	out_mux							     	: out std_logic_vector(SIGNAL_LENGTH-1 downto 0)
	);
end entity;

architecture Behavioral of multiplexer_3to1 is

    signal output_mux   : std_logic_vector(SIGNAL_LENGTH-1 downto 0) := (others  => '0') ;

begin
    process (clk)
	begin
		if rising_edge(clk) then
			if      selector_mux = "00" then output_mux <= in0_mux;
            elsif   selector_mux = "01" then output_mux <= in1_mux;
            elsif   selector_mux = "10" then output_mux <= in2_mux;
            else                             output_mux <= in0_mux;
			end if;
		end if;
	end process;

    out_mux <= output_mux;
end;
