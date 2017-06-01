----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    14:20:09 02/15/2014 
-- Design Name: 
-- Module Name:    crash_monitor_v1 - Behavioral 
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

entity crash_monitor_v1 is
	Generic (
		N_BITS_DATA : integer := 16;
		ADDRESS_BITS : integer := 8
	);
    Port ( clk : in  STD_LOGIC;
           input1 : in  STD_LOGIC_VECTOR (N_BITS_DATA-1 downto 0);
			  input2 : in  STD_LOGIC_VECTOR (N_BITS_DATA-1 downto 0);
			  input3 : in  STD_LOGIC_VECTOR (N_BITS_DATA-1 downto 0);
           trigger_input : in  STD_LOGIC;
			  ready_for_dump : in std_logic;
			  has_data : out std_logic;
           pretrigger_samples : in  STD_LOGIC_VECTOR (ADDRESS_BITS-1 downto 0);
           output_to_logger : out  STD_LOGIC_VECTOR (N_BITS_DATA-1 downto 0);
           output_to_logger_clk_enable : out  STD_LOGIC
);
end crash_monitor_v1;

architecture Behavioral of crash_monitor_v1 is
	constant N_SAMPLES_PER_PACKET : integer := 2**ADDRESS_BITS-1;

	type fsm_state_type is (FSM_RST, FSM_PRETRIGGER_LOAD, FSM_WAITING_FOR_TRIGGER, FSM_TRIGGERED, FSM_WAITING_FOR_DUMP,
									FSM_DUMP_TO_OUTPUT1, FSM_DUMP_TO_OUTPUT2, FSM_DUMP_TO_OUTPUT3);
	signal FSM_state : fsm_state_type := FSM_RST;
	
	signal samples_counter : unsigned(ADDRESS_BITS-1 downto 0) := (others => '0');
	
	signal read_address1, read_address2, read_address3, write_address : std_logic_vector(ADDRESS_BITS-1 downto 0) := (others => '0');
	signal ram_output1, ram_output2, ram_output3 : std_logic_vector(N_BITS_DATA-1 downto 0) := (others => '0');
	signal rst_ram, write_enable, read_enable1, read_enable2, read_enable3 : std_logic := '0';
	--signal rst_fifo, memory_write_enable, fifo_read_enable : std_logic := '0';
	
	signal output_clk_enable_register, output_clk_enable_register2, output_clk_enable_internal, has_data_internal : std_logic := '0';
	signal output_register : std_logic_vector(N_BITS_DATA-1 downto 0) := (others => '0');
begin
	
	-- Dual-port RAM to hold the data
	dualport_ram_for_monitor_inst1 : entity work.dualport_ram_for_monitor
	Generic map (
		DATA_BITS => N_BITS_DATA,
		ADDRESS_BITS => ADDRESS_BITS
	) port map (
		clk => clk,
		read_address => read_address1,
		write_address => write_address,
		write_enable => write_enable,
		data_in => input1,
		data_out => ram_output1
	);
	
	dualport_ram_for_monitor_inst2 : entity work.dualport_ram_for_monitor
	Generic map (
		DATA_BITS => N_BITS_DATA,
		ADDRESS_BITS => ADDRESS_BITS
	) port map (
		clk => clk,
		read_address => read_address2,
		write_address => write_address,
		write_enable => write_enable,
		data_in => input2,
		data_out => ram_output2
	);
	
	dualport_ram_for_monitor_inst3 : entity work.dualport_ram_for_monitor
	Generic map (
		DATA_BITS => N_BITS_DATA,
		ADDRESS_BITS => ADDRESS_BITS
	) port map (
		clk => clk,
		read_address => read_address3,
		write_address => write_address,
		write_enable => write_enable,
		data_in => input3,
		data_out => ram_output3
	);
	
	-- Drives the read and write addresses of the RAM:
	process (clk)
	begin
		if rising_edge(clk) then
			if rst_ram = '1' then
				read_address1  <= (others => '0');
				read_address2  <= (others => '0');
				read_address3  <= (others => '0');
				
				write_address <= (others => '0');
			else
				if write_enable = '1' then
					write_address <= std_logic_vector(unsigned(write_address) + 1);
				end if;
				
				if read_enable1 = '1' then
					read_address1  <= std_logic_vector(unsigned(read_address1) + 1);
				end if;
				if read_enable2 = '1' then
					read_address2  <= std_logic_vector(unsigned(read_address2) + 1);
				end if;
				if read_enable3 = '1' then
					read_address3  <= std_logic_vector(unsigned(read_address3) + 1);
				end if;
				
			end if;
		end if;
	end process;
	
	-------------------------------------------------------------------------------	
	-- The controller FSM for the whole module.
	-------------------------------------------------------------------------------
	process (clk)
	begin
		if rising_edge(clk) then
			rst_ram <= '0';
			output_clk_enable_register <= '0';

			case FSM_state is
				when FSM_RST =>
					rst_ram <= '1';
					samples_counter <= (others => '0');
					FSM_state <= FSM_PRETRIGGER_LOAD;
					has_data_internal <= '0';
					
				when FSM_PRETRIGGER_LOAD =>
					write_enable <= '1';
					read_enable1 <= '0';
					read_enable2 <= '0';
					read_enable3 <= '0';
			
					samples_counter <= samples_counter + 1;
					
					if samples_counter >= unsigned(pretrigger_samples) then
						FSM_state <= FSM_WAITING_FOR_TRIGGER;
					end if;
					
				when FSM_WAITING_FOR_TRIGGER =>
					write_enable <= '1';
					read_enable1 <= '1';
					read_enable2 <= '1';
					read_enable3 <= '1';
					if trigger_input = '1' then
						FSM_state <= FSM_TRIGGERED;
					end if;
				
				when FSM_TRIGGERED =>
					write_enable <= '1';
					read_enable1 <= '0';
					read_enable2 <= '0';
					read_enable3 <= '0';
					
					if samples_counter < N_SAMPLES_PER_PACKET-1 then
						samples_counter <= samples_counter + 1;
					else
						FSM_state <= FSM_WAITING_FOR_DUMP;
						samples_counter <= (others => '0');
					end if;
					
				when FSM_WAITING_FOR_DUMP =>
					write_enable <= '0';
					read_enable1 <= '0';
					read_enable2 <= '0';
					read_enable3 <= '0';
					
					has_data_internal <= '1';
					
					if ready_for_dump = '1' then
						FSM_state <= FSM_DUMP_TO_OUTPUT1;
					end if;
					
				when FSM_DUMP_TO_OUTPUT1 =>
				
					write_enable <= '0';
					read_enable1 <= '1';
					read_enable2 <= '0';
					read_enable3 <= '0';
					output_clk_enable_register <= '1';
					
					output_register <= ram_output1;
					
					-- wait until the fifo is empty
					samples_counter <= samples_counter + 1;
					
					if samples_counter = N_SAMPLES_PER_PACKET then
						-- Could go to FSM_DUMP_TO_OUTPUT2 instead
						FSM_state <= FSM_DUMP_TO_OUTPUT2;
						samples_counter <= (others => '0');
					end if;
					
				when FSM_DUMP_TO_OUTPUT2 =>
				
					write_enable <= '0';
					read_enable1 <= '0';
					read_enable2 <= '1';
					read_enable3 <= '0';
					output_clk_enable_register <= '1';
					
					output_register <= ram_output2;
					
					-- wait until the fifo is empty
					samples_counter <= samples_counter + 1;
					
					if samples_counter = N_SAMPLES_PER_PACKET then
						-- Could go to FSM_DUMP_TO_OUTPUT2 instead
						FSM_state <= FSM_DUMP_TO_OUTPUT3;
						samples_counter <= (others => '0');
					end if;
					
				when FSM_DUMP_TO_OUTPUT3 =>
				
					write_enable <= '0';
					read_enable1 <= '0';
					read_enable2 <= '0';
					read_enable3 <= '1';
					output_clk_enable_register <= '1';
					
					output_register <= ram_output3;
					
					-- wait until the fifo is empty
					samples_counter <= samples_counter + 1;
					
					if samples_counter = N_SAMPLES_PER_PACKET then
						-- Could go to FSM_DUMP_TO_OUTPUT2 instead
						FSM_state <= FSM_RST;
						samples_counter <= (others => '0');
						
					end if;
					
				when others =>
					FSM_state <= FSM_RST;
			end case;
			
			
		end if;	-- rising_edge(clk)
	end process;

	process (clk)
	begin
		if rising_edge(clk) then
			output_clk_enable_register2 <= output_clk_enable_register;
			output_clk_enable_internal <= output_clk_enable_register2;
			
			
		end if;	-- rising_edge(clk)
	end process;
	output_to_logger <= output_register;
	output_to_logger_clk_enable <= output_clk_enable_internal;
	has_data <= has_data_internal;

end Behavioral;

