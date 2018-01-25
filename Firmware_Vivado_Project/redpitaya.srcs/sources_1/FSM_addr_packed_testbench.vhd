library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity FSM_addr_packed_testbench is
end FSM_addr_packed_testbench;

architecture behavior of FSM_addr_packed_testbench is

constant clock_period : time := 8 ns;
signal clk : STD_LOGIC := '0';
signal stop_the_clock: boolean;

component FSM_addr_packed  is
    port (
            clk             : in  std_logic;                        --clock
            read_fifo       : out std_logic;                        -- pulse to read data from fifo
            data_in         : in  std_logic_vector(64-1 downto 0);  -- Data input from FIFO
            sys_ren         : in  std_logic;                        -- read pulse --if computer want to read data
            addrAsk         : in  std_logic_vector(32-1 downto 0);  -- Addr at which the computer want to read
            FIFO_empty      : in  std_logic;                        -- 1 if FIFO is empty
            data_out        : out std_logic_vector(32-1 downto 0);  -- Data to send to the computer
            ack             : out std_logic                         -- Ack to send to the computer
        );
end component;

signal data_in : std_logic_vector (64-1 downto 0) := (others => '0');

signal FIFO_empty : std_logic := '1';


signal data_out : std_logic_vector (32-1 downto 0) := (others => '0');
signal ack : std_logic := '0';
signal addrAsk : std_logic_vector (32-1 downto 0) := (others => '0');
signal sys_ren : std_logic := '0';


begin

FSM_inst : FSM_addr_packed
port map (	clk 		=> clk,
			data_in 	=> data_in,
			read_fifo 	=> open,
			sys_ren		=> sys_ren,
			addrAsk 	=> addrAsk,
			FIFO_empty 	=> FIFO_empty,
			data_out	=> data_out,
			ack 		=> ack
);


 stimulus: process
    begin
        wait for clock_period;

        data_in <= x"0000000100000001";
        FIFO_empty <= '0';
        wait for clock_period * 2;
		FIFO_empty <= '1';
        wait for clock_period * 20;

        data_in <= x"0000000200000002";
        FIFO_empty <= '0';
        wait for clock_period * 2;
		FIFO_empty <= '1';
		wait for clock_period * 20;

        data_in <= x"0000000100000003";
        FIFO_empty <= '0';
        wait for clock_period * 2;
		FIFO_empty <= '1';
		wait for clock_period * 20;

        data_in <= x"0000000300000004";
        FIFO_empty <= '0';
        wait for clock_period * 2;
		FIFO_empty <= '1';
		wait for clock_period * 20;

		data_in <= x"0000000200000004";
        FIFO_empty <= '0';
        wait for clock_period * 2;
		FIFO_empty <= '1';
		wait for clock_period * 20;

        data_in <= x"0000000400000005";
        FIFO_empty <= '0';
        wait for clock_period * 2;
		FIFO_empty <= '1';
		wait for clock_period * 20;

        data_in <= x"0000000500000006";
        FIFO_empty <= '0';
        wait for clock_period * 2;
		FIFO_empty <= '1';
		wait for clock_period * 20;

        data_in <= x"0000000600000007";
        FIFO_empty <= '0';
        wait for clock_period * 2;
		FIFO_empty <= '1';
		wait for clock_period * 20;

        data_in <= x"0000000400000008";
        FIFO_empty <= '0';
        wait for clock_period * 2;
		FIFO_empty <= '1';
		wait for clock_period * 20;

        sys_ren <= '1';
        addrAsk <= x"00000004";
        wait for clock_period * 2;
        sys_ren <= '0';
        wait for clock_period * 20;

        sys_ren <= '1';
        addrAsk <= x"00000002";
        wait for clock_period * 2;
        sys_ren <= '0';
        wait for clock_period * 20;

        sys_ren <= '1';
        addrAsk <= x"00000012";
        wait for clock_period * 2;
        sys_ren <= '0';
        wait for clock_period * 20;

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