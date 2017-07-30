library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity addr_packed is
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
end addr_packed;

architecture Behavioral of addr_packed is

component FIFO_addr_packed is
	port (
		    clk : IN STD_LOGIC;
		    srst : IN STD_LOGIC;
		    din : IN STD_LOGIC_VECTOR(64-1 DOWNTO 0);
		    wr_en : IN STD_LOGIC;
		    rd_en : IN STD_LOGIC;
		    dout : OUT STD_LOGIC_VECTOR(64-1 DOWNTO 0);
		    full : OUT STD_LOGIC;
		    wr_ack : OUT STD_LOGIC;
		    empty : OUT STD_LOGIC
	  );
end component;

component FSM_addr_packed  is
    port (
            clk				: in  std_logic; 						--clock
            read_fifo       : out std_logic; 						-- pulse to read data from fifo
            data_in			: in  std_logic_vector(64-1 downto 0);	-- Data input from FIFO
            sys_ren 		: in  std_logic; 						-- read pulse --if computer want to read data
            addrAsk			: in  std_logic_vector(32-1 downto 0);	-- Addr at which the computer want to read
            FIFO_empty		: in  std_logic; 						-- 1 if FIFO is empty
            data_out		: out std_logic_vector(32-1 downto 0); 	-- Data to send to the computer
            ack 			: out std_logic 						-- Ack to send to the computer
        );
end component;

signal fifo_ack : STD_LOGIC := '0';
signal FSM_ack 	: STD_LOGIC := '0';

signal read_fifo : STD_LOGIC := '0';
signal data_exchange : std_logic_vector (64-1 downto 0) := (others => '0');
signal fifo_empty : STD_LOGIC := '0';

begin

FIFO_inst : FIFO_addr_packed
port map (
			clk 	=> clk,
		    srst 	=> rst,
		    din 	=> sys_addr & sys_wdata,
		    wr_en 	=> sys_wen,
		    rd_en 	=> read_fifo,
		    dout 	=> data_exchange,
		    full 	=> open,
		    wr_ack 	=> fifo_ack,
		    empty 	=> fifo_empty
	);


FSM_inst : FSM_addr_packed
port map (
			clk 		=> clk,
            read_fifo 	=> read_fifo,
            data_in 	=> data_exchange,
            sys_ren		=> sys_ren,
            addrAsk 	=> sys_addr,
            FIFO_empty 	=> fifo_empty,
            data_out 	=> sys_rdata,
            ack 		=> FSM_ack
	);

sys_ack <= fifo_ack or FSM_ack;


end;