----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    23:21:11 11/25/2013 
-- Design Name: 
-- Module Name:    aux_data_mux - Behavioral 
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
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity aux_data_mux is
	Port (
		clk              : in  std_logic;
		write_mode       : in  std_logic;
		ADC0             : in  std_logic_vector (15 downto 0);
		ADC1             : in  std_logic_vector (15 downto 0);
		ref_cosine_0     : in  std_logic_vector (15 downto 0);
		ref_sine_0       : in  std_logic_vector (15 downto 0);
		ref_cosine_1     : in  std_logic_vector (15 downto 0);
		ref_sine_1       : in  std_logic_vector (15 downto 0);
		ADC0_multiplexed : out std_logic_vector (15 downto 0);
		ADC1_multiplexed : out std_logic_vector (15 downto 0)
	);
end aux_data_mux;

architecture Behavioral of aux_data_mux is
	signal write_mode_last : std_logic := '0';
	
	type FSM_state_type is (FSM_IDLE, FSM_COS, FSM_SIN, FSM_MAGIC_BYTES);
	signal fsm_state : FSM_state_type;
	
	signal ADC0_next, ADC1_next : std_logic_vector(15 downto 0) := (others => '0');
	
begin

	-- Implement as a very simple state machine: We wait until the DDR2Logger starts logging, then
	-- we sample the reference cosine and sine, and put the on the put one after the other, going back to waiting after.
	-- The last state is used to put magic bytes on the data stream, so that we can detect loss of bytes synchronization on the link (this happens at random due to a bug in Opal Kelly's library I think)
	process (clk)
	begin
		if rising_edge(clk) then
			write_mode_last <= write_mode;
		
			case fsm_state is
				when FSM_IDLE =>
					ADC0_multiplexed <= ADC0;
					ADC1_multiplexed <= ADC1;
					-- Rising edge detector:
					if write_mode = '1' and write_mode_last = '0' then
						fsm_state <= FSM_COS;
					end if;
					
				when FSM_COS =>
					ADC0_multiplexed <= ref_cosine_0;
					ADC1_multiplexed <= ref_cosine_1;
					ADC0_next        <= ref_sine_0;        -- We are sampling both the cos and the sin at the same time so that we can simply use the phase of this vector as a reference
					ADC1_next        <= ref_sine_1; 
					
					fsm_state        <= FSM_SIN;
					
				when FSM_SIN =>
					ADC0_multiplexed <= ADC0_next;
					ADC1_multiplexed <= ADC1_next;
					
					fsm_state <= FSM_MAGIC_BYTES;
					
				when FSM_MAGIC_BYTES =>
					ADC0_multiplexed <= b"1010_1000_1000_1111";
					ADC1_multiplexed <= b"1010_1000_1000_1111";
					
					fsm_state <= FSM_IDLE;
					
				when others =>
					fsm_state <= FSM_IDLE;
			end case;
		end if;
	end process;

end Behavioral;

