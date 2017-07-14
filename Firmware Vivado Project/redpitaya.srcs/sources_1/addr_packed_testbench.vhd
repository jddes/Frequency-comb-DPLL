library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity addr_packed_testbench is
end addr_packed_testbench;


architecture behavior of addr_packed_testbench is

constant clock_period : time := 8 ns;
signal clk : STD_LOGIC := '0';
signal stop_the_clock: boolean;

component addr_packed is
	port(
			clk 		: in std_logic;
			rst 		: in std_logic;
			sys_addr	: in std_logic_vector (32-1 downto 0);
			sys_wdata	: in std_logic_vector (32-1 downto 0);
			sys_wen 	: in std_logic;
			sys_ren		: in std_logic;
			sys_rdata   : out std_logic_vector(32-1 downto 0);  -- bus read data
			sys_ack		: out std_logic  -- bus acknowledge signal
		);
end component;

signal sys_addr 	: std_logic_vector (32-1 downto 0)	:= (others => '0');
signal sys_wdata 	: std_logic_vector (32-1 downto 0)	:= (others => '0');
signal sys_wen 		: std_logic 						:= '0';
signal sys_ren 		: std_logic 						:= '0';
signal sys_rdata 	: std_logic_vector (32-1 downto 0)	:= (others => '0');
signal sys_ack 		: std_logic 						:= '0';


begin

addr_packed_inst : addr_packed
port map (
			clk 		=> clk,
			rst 		=> '0',
			sys_addr 	=> sys_addr,
			sys_wdata 	=> sys_wdata,
			sys_wen 	=> sys_wen,
			sys_ren		=> sys_ren,
			sys_rdata 	=> sys_rdata,
			sys_ack 	=> sys_ack
	);

stimulus: process
    begin
	    wait for clock_period * 20;	

	    sys_addr 	<= x"00000001";
		sys_wdata 	<= x"00001122";
		sys_wen 	<= '1';
		sys_ren 	<= '0';
		wait for clock_period * 2;
		sys_wen 	<= '0';
		sys_ren 	<= '0';
		
		wait until falling_edge(sys_ack);
		wait until rising_edge(clk);

	    sys_addr 	<= x"00000020";
		sys_wdata 	<= x"00001123";
		sys_wen 	<= '1';
		sys_ren 	<= '0';
		wait for clock_period * 2;
		sys_wen 	<= '0';
		sys_ren 	<= '0';
		
		wait until falling_edge(sys_ack);
		wait until rising_edge(clk);

	    sys_addr 	<= x"00000002";
		sys_wdata 	<= x"00001212";
		sys_wen 	<= '1';
		sys_ren 	<= '0';
		wait for clock_period * 2;
		sys_wen 	<= '0';
		sys_ren 	<= '0';
		
		wait until falling_edge(sys_ack);
		wait until rising_edge(clk);

	    sys_addr 	<= x"00000020";
		sys_wdata 	<= x"00001515";
		sys_wen 	<= '1';
		sys_ren 	<= '0';
		wait for clock_period * 2;
		sys_wen 	<= '0';
		sys_ren 	<= '0';
		
		wait until falling_edge(sys_ack);
		wait until rising_edge(clk);

		sys_addr 	<= x"00000004";
		sys_wdata 	<= x"00000123";
		sys_wen 	<= '1';
		sys_ren 	<= '0';
		wait for clock_period * 2;
		sys_wen 	<= '0';
		sys_ren 	<= '0';
		
		wait until falling_edge(sys_ack);
		wait until rising_edge(clk);

		wait for clock_period * 100;
		------------------------------ READ data from here -------------------------------------------
		sys_addr 	<= x"00000020";
		sys_wdata 	<= x"00000000";
		sys_wen 	<= '0';
		sys_ren 	<= '1';
		wait for clock_period * 2;
		sys_wen 	<= '0';
		sys_ren 	<= '0';
		
		wait until falling_edge(sys_ack);
		wait for clock_period * 6;
		wait until rising_edge(clk);

		sys_addr 	<= x"00000004";
		sys_wdata 	<= x"00000000";
		sys_wen 	<= '0';
		sys_ren 	<= '1';
		wait for clock_period * 2;
		sys_wen 	<= '0';
		sys_ren 	<= '0';
		
		wait until falling_edge(sys_ack);
		wait for clock_period * 6;
		wait until rising_edge(clk);

		sys_addr 	<= x"00000001";
		sys_wdata 	<= x"00000000";
		sys_wen 	<= '0';
		sys_ren 	<= '1';
		wait for clock_period * 2;
		sys_wen 	<= '0';
		sys_ren 	<= '0';
		
		wait until falling_edge(sys_ack);
		wait for clock_period * 6;
		wait until rising_edge(clk);

		sys_addr 	<= x"00000007";
		sys_wdata 	<= x"00000000";
		sys_wen 	<= '0';
		sys_ren 	<= '1';
		wait for clock_period * 2;
		sys_wen 	<= '0';
		sys_ren 	<= '0';
		
		wait until falling_edge(sys_ack);
		wait for clock_period * 6;
		wait until rising_edge(clk);

		stop_the_clock <= true;

    	wait;
end process;

clocking: process
    begin
      while not stop_the_clock loop
        clk <= '0', '1' after clock_period / 2;
        wait for clock_period;
      end loop;
      wait;
    end process;

end;