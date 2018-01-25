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
			sys_ack		: out std_logic;  -- bus acknowledge signal
			out_empty 	: out std_logic;
			out_full 	: out std_logic
		);
end component;

signal sys_addr 	: std_logic_vector (32-1 downto 0)	:= (others => '0');
signal sys_wdata 	: std_logic_vector (32-1 downto 0)	:= (others => '0');
signal sys_wen 		: std_logic 						:= '0';
signal sys_ren 		: std_logic 						:= '0';
signal sys_rdata 	: std_logic_vector (32-1 downto 0)	:= (others => '0');
signal sys_ack 		: std_logic 						:= '0';

signal rst 			: std_logic 						:= '1';
signal waddr 		: std_logic_vector (32-1 downto 0)	:= (others => '0');
signal test 		: std_logic_vector (32-1 downto 0) 	:= (others => '0');
signal selector_vco : std_logic_vector (2-1 downto 0) 	:= (others => '0');


begin

addr_packed_inst : addr_packed
port map (
			clk 		=> clk,
			rst 		=> rst,
			sys_addr 	=> sys_addr,
			sys_wdata 	=> sys_wdata,
			sys_wen 	=> sys_wen,
			sys_ren		=> sys_ren,
			sys_rdata 	=> sys_rdata,
			sys_ack 	=> sys_ack,
			out_empty 	=> open,
			out_full 	=> open
			);

stimulus: process
    begin
	    wait for clock_period * 20;	


	    waddr 	<= x"00000001";
	    wait until rising_edge(clk);
	    sys_addr 	<= std_logic_vector(resize(unsigned(waddr)*4, sys_addr'length));

		--std_logic_vector(resize(shift_right(sin_times_amplitude_wide + to_signed(2**(BIT_SHIFT_AFTER_MULT-1), sin_times_amplitude_wide'length), BIT_SHIFT_AFTER_MULT), sin_times_amplitude'length));

		sys_wdata 	<= x"00001122";
		sys_wen 	<= '1';
		sys_ren 	<= '0';
		wait until rising_edge(clk);
		sys_wen 	<= '0';
		sys_ren 	<= '0';
		
		wait for clock_period * 10;
		wait until rising_edge(clk);

	 
	    waddr 	<= x"00000020";
	    wait until rising_edge(clk);
	    sys_addr 	<= std_logic_vector(resize(unsigned(waddr)*4, sys_addr'length));
		sys_wdata 	<= x"00001123";
		sys_wen 	<= '1';
		sys_ren 	<= '0';
		wait until rising_edge(clk);
		sys_wen 	<= '0';
		sys_ren 	<= '0';
		
		wait for clock_period * 10;
		wait until rising_edge(clk);

	 
	    waddr 	<= x"00009000";
	    wait until rising_edge(clk);
	    sys_addr 	<= std_logic_vector(resize(unsigned(waddr)*4, sys_addr'length));
		sys_wdata 	<= x"0000AAAA";
		sys_wen 	<= '1';
		sys_ren 	<= '0';
		wait until rising_edge(clk);
		sys_wen 	<= '0';
		sys_ren 	<= '0';
		
		wait for clock_period * 10;
		wait until rising_edge(clk);

	 
	    waddr 	<= x"00000020";
	    wait until rising_edge(clk);
	    sys_addr 	<= std_logic_vector(resize(unsigned(waddr)*4, sys_addr'length));
		sys_wdata 	<= x"00001515";
		sys_wen 	<= '1';
		sys_ren 	<= '0';
		wait until rising_edge(clk);
		sys_wen 	<= '0';
		sys_ren 	<= '0';
		
		wait for clock_period * 10;
		wait until rising_edge(clk);

	    waddr 	<= x"00000004";
	    wait until rising_edge(clk);
	    sys_addr 	<= std_logic_vector(resize(unsigned(waddr)*4, sys_addr'length));
		sys_wdata 	<= x"12345678";
		sys_wen 	<= '1';
		sys_ren 	<= '0';
		wait until rising_edge(clk);
		sys_wen 	<= '0';
		sys_ren 	<= '0';
		
		wait for clock_period * 10;
		wait until rising_edge(clk);

		wait for clock_period * 300;
		------------------------------ READ data from here -------------------------------------------
	    waddr 	<= x"00609000";
	    wait until rising_edge(clk);
	    sys_addr 	<= std_logic_vector(resize(unsigned(waddr)*4, sys_addr'length));
		sys_wdata 	<= x"00000000";
		sys_wen 	<= '0';
		sys_ren 	<= '1';
		wait until rising_edge(clk);
		sys_wen 	<= '0';
		sys_ren 	<= '0';
		
		wait until falling_edge(sys_ack);
		wait for clock_period * 6;
		wait until rising_edge(clk);

	    waddr 	<= x"00000004";
	    wait until rising_edge(clk);
	    sys_addr 	<= std_logic_vector(resize(unsigned(waddr)*4, sys_addr'length));
		sys_wdata 	<= x"00000000";
		sys_wen 	<= '0';
		sys_ren 	<= '1';
		wait until rising_edge(clk);
		sys_wen 	<= '0';
		sys_ren 	<= '0';

		wait until falling_edge(sys_ack);
		wait for clock_period * 6;
		wait until rising_edge(clk);

	    waddr 	<= x"00009001";
	    wait until rising_edge(clk);
	    sys_addr 	<= std_logic_vector(resize(unsigned(waddr)*4, sys_addr'length));
		sys_wdata 	<= x"00000000";
		sys_wen 	<= '0';
		sys_ren 	<= '1';
		wait until rising_edge(clk);
		sys_wen 	<= '0';
		sys_ren 	<= '0';
		

		wait until falling_edge(sys_ack);
		wait for clock_period * 6;
		wait until rising_edge(clk);

	    waddr 	<= x"00008001";
	    wait until rising_edge(clk);
	    sys_addr 	<= std_logic_vector(resize(unsigned(waddr)*4, sys_addr'length));
		sys_wdata 	<= x"00000000";
		sys_wen 	<= '0';
		sys_ren 	<= '1';
		wait until rising_edge(clk);
		sys_wen 	<= '0';
		sys_ren 	<= '0';

		wait until falling_edge(sys_ack);
		wait for clock_period * 6;
		wait until rising_edge(clk);

	    waddr 	<= x"00000001";
	    wait until rising_edge(clk);
	    sys_addr 	<= std_logic_vector(resize(unsigned(waddr)*4, sys_addr'length));
		sys_wdata 	<= x"00000000";
		sys_wen 	<= '0';
		sys_ren 	<= '1';
		wait until rising_edge(clk);
		sys_wen 	<= '0';
		sys_ren 	<= '0';
		
		wait until falling_edge(sys_ack);
		wait for clock_period * 6;
		wait until rising_edge(clk);

	    waddr 	<= x"00000007";
	    wait until rising_edge(clk);
	    sys_addr 	<= std_logic_vector(resize(unsigned(waddr)*4, sys_addr'length));
		sys_wdata 	<= x"00000000";
		sys_wen 	<= '0';
		sys_ren 	<= '1';
		wait until rising_edge(clk);
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