----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    20:54:28 02/19/2014 
-- Design Name: 
-- Module Name:    Status_LED_driver - Behavioral 
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

entity Status_LED_driver is
	Generic (
		N_BITS_COUNTER : integer := 22	-- 100 MHz/4194304 = 23 Hz
	);
	Port (
		clk                       : in   STD_LOGIC;
		lock_on                   : in   STD_LOGIC;
		residuals_above_threshold : in   STD_LOGIC;
		railed                    : in   STD_LOGIC;
		red_LED                   : out  STD_LOGIC;
		green_LED                 : out  STD_LOGIC
	);
end Status_LED_driver;

architecture Behavioral of Status_LED_driver is
	type fsm_state_type is (FSM_OFF, FSM_LOCK, FSM_RAILED, FSM_UNLOCKED);
	signal FSM_state, next_state        : fsm_state_type := FSM_OFF;
	
	signal inhibit_counter              : unsigned(N_BITS_COUNTER-1 downto 0) := (others => '0');
	constant counter_max                : unsigned(N_BITS_COUNTER-1 downto 0) := (others => '1');
	
	signal red_internal, green_internal : std_logic := '0';
begin

	-- state machine:
	-- pretty much only consists of a counter which inhibits transitions until it reaches its maximum,
	-- otherwise the transitions follow the rules laid out in the next process
	-- (the next state computation is synchronous to make achieving timing closure very easy)
	process (clk)
	begin
		if rising_edge(clk) then
			case FSM_state is
				when FSM_OFF =>
					-- can always transition
					FSM_state <= next_state;
					if FSM_state /= next_state then
						inhibit_counter <= (others => '0');
					end if;
						
				when FSM_LOCK =>
					-- can always transition
					FSM_state <= next_state;
					if FSM_state /= next_state then
						inhibit_counter <= (others => '0');
					end if;
						
				when FSM_RAILED =>
					-- this state has to stay for at least one full cycle of the counter:
					if inhibit_counter = counter_max then
						-- can transition
						FSM_state <= next_state;
						if FSM_state /= next_state then
							inhibit_counter <= (others => '0');
						end if;
					elsif railed = '1' then
						-- reset counter if condition is met
						inhibit_counter <= (others => '0');
					else
						-- count up
						inhibit_counter <= inhibit_counter + 1;
					end if;
					
				when FSM_UNLOCKED =>
					if inhibit_counter = counter_max then
						-- can transition
						FSM_state <= next_state;
						if FSM_state /= next_state then
							inhibit_counter <= (others => '0');
						end if;
						
					elsif residuals_above_threshold = '1' then
						-- reset counter if condition is met
						inhibit_counter <= (others => '0');
					else
						-- count up
						inhibit_counter <= inhibit_counter + 1;
					end if;
					
				when others =>
					-- shouldn't be possible, but just to make sure
			end case;
				
		end if;
	end process;
	
	-- Next state:
	-- simple priority encoder:
	process (clk)
	begin
		if rising_edge(clk) then
			if residuals_above_threshold = '1' then
				next_state <= FSM_UNLOCKED;
			elsif railed = '1' then
				next_state <= FSM_RAILED;
			elsif lock_on = '1' then
				next_state <= FSM_LOCK;
			else
				next_state <= FSM_OFF;
			end if;
				
		end if;
	end process;

	
	-- output decoder:
	process (clk)
	begin
		if rising_edge(clk) then
			case FSM_state is
				when FSM_OFF =>
					red_internal     <= '0';
					green_internal   <= '0';
				when FSM_LOCK =>
					red_internal     <= '0';
					green_internal   <= '1';
				when FSM_RAILED =>
					red_internal     <= '1';
					green_internal   <= '1';
				when FSM_UNLOCKED =>
					red_internal     <= '1';
					green_internal   <= '0';
				when others =>
					-- shouldn't be possible, but just to make sure
					red_internal     <= '0';
					green_internal   <= '0';
			end case;
				
		end if;
	end process;
	
	red_LED   <= red_internal;
	green_LED <= green_internal;

end Behavioral;

