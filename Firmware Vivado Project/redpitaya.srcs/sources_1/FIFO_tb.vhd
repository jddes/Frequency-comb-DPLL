library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;	

entity fifo_tb is
end fifo_tb;


architecture behavior of fifo_tb is

constant clock_period : time := 5 ns;
signal clk : STD_LOGIC := '0';
signal stop_the_clock: boolean;

component FIFO_addr_packed
  PORT (
    clk : IN STD_LOGIC;
    srst : IN STD_LOGIC;
    din : IN STD_LOGIC_VECTOR(63 DOWNTO 0);
    wr_en : IN STD_LOGIC;
    rd_en : IN STD_LOGIC;
    dout : OUT STD_LOGIC_VECTOR(63 DOWNTO 0);
    full : OUT STD_LOGIC;
    wr_ack : OUT STD_LOGIC;
    empty : OUT STD_LOGIC
  );
END component;

signal rst : std_logic;
signal wen : std_logic;
signal ren : std_logic;
signal data_in : std_logic_vector (63 downto 0) := (others => '0');
signal data_out : std_logic_vector (63 downto 0):= (others => '0');
signal fifo_full : std_logic;
signal fifo_wack : std_logic;
signal fifo_empty : std_logic;


begin

	fifo_inst : FIFO_addr_packed
	port map (
		clk 	=> clk,
		srst	=> rst,
		din		=> data_in,
		wr_en 	=> wen,
		rd_en 	=> ren,
		dout 	=> data_out,
		full 	=> fifo_full,
		wr_ack 	=> fifo_wack,
		empty 	=> fifo_empty
		);

	stimulus: process
	begin
		wait for clock_period * 10;
		rst <= '1';
		wen <= '0';
		ren <= '0';
		wait for clock_period * 5;
		rst <= '0';
		wait for clock_period * 5;

		data_in <= "0000000000000000000000000000000000000000000000000000000000000001";
		wait for clock_period * 5;
		wen <= '1';
        wait for clock_period * 5;
		wen <= '0';
		wait for clock_period * 5;
        wen <= '1';
		wait for clock_period * 5;
		wen <= '0';
		
		data_in <= "0000000000000000000000000000000000000000000000000000000000000010";
		wait for clock_period * 5;
		wen <= '1';
		wait for clock_period * 5;
		wen <= '0';
		
        data_in <= "0000000000000000000000000000000000000000000000000000000000000011";
        wait for clock_period * 5;
        data_in <= "0000000000000000000000000000000000000000000000000000000000000100";
        wait for clock_period * 5;
        wen <= '1';
        wait for clock_period * 5;
        wen <= '0';
		
		
		
		wait for clock_period * 5;
		ren <= '1';
		wait for clock_period * 5;
		ren <= '0';
		wait for clock_period * 5;
		ren <= '1';
		wait for clock_period * 5;
		ren <= '0';
        wait for clock_period * 5;
        ren <= '1';
        wait for clock_period * 5;
        ren <= '0';
        wait for clock_period * 5;
        ren <= '1';
        wait for clock_period * 5;
        ren <= '0';
        wait for clock_period * 5;
        ren <= '1';
        wait for clock_period * 5;
        ren <= '0';
		
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



