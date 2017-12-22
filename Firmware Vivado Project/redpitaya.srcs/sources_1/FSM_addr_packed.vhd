library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library std;
use std.textio.all;

entity FSM_addr_packed  is
    port (
            clk				: in  std_logic; 						-- Clock
            rst 			: in  std_logic; 						-- Reset (active low)
            read_fifo       : out std_logic; 						-- pulse to read data from fifo
            data_in			: in  std_logic_vector(64-1 downto 0);	-- Data input from FIFO
            sys_ren 		: in  std_logic; 						-- read pulse --if computer want to read data
            addrAsk			: in  std_logic_vector(32-1 downto 0);	-- Addr at which the computer want to read
            FIFO_empty		: in  std_logic; 						-- 1 if FIFO is empty
            data_out		: out std_logic_vector(32-1 downto 0); 	-- Data to send to the computer
            sys_err 		: out std_logic;						-- Error indicator
            ack 			: out std_logic 						-- Ack to send to the computer
        );
end entity;


architecture Behavioral of FSM_addr_packed is

	type state_type is (
					STATE_IDLE,					-- IDLE
					STATE_SEARCH_READ, 			-- Computer want to read, look for data in addr_packed
					STATE_VERIFY_READ,			-- Verify if the data we just read in the ram is the data wanted by the computer
					STATE_READ_NOT_FOUND, 		-- Addr does not exist in addr_packed, return what??
					STATE_READ_FOUND, 			-- Addr exist in addr_packed, return data
					STATE_READING_FIFO, 		
					STATE_FIFO_READ, 			-- FIFO not empty, read one data from it
					STATE_LOOP_READ_RAM, 		-- Loop through RAM Block; is addr already in addr_packed
					STATE_LOOP_VERIFY_RAM, 		-- Loop through RAM Block; is addr already in addr_packed
					STATE_REPLACE_RAM, 			-- Addr is in addr_packed, replace his value
					STATE_NEW_RAM				-- Addr is not in addr_packed, create new entry
					);			
	signal FSM_state : state_type := STATE_IDLE;



	signal sys_addr_to_save : std_logic_vector (16-1 downto 0) := (others => '0'); 		--sys_addr we want to save

	signal write_ram 			: std_logic := '0';										--signal to write in the RAM block
	signal write_ram_addr 		: std_logic_vector(8-1 downto 0) := (others => '0');	--addr at which we want to write in RAM Block
	signal write_ram_data 		: std_logic_vector(64-1 downto 0) := (others => '0');	--data to write in the RAM
	signal read_ram 			: std_logic := '0';										--signal to read in the RAM Block
	signal read_address 		: std_logic_vector (8-1 downto 0) := (others => '0');	--addr at which we want to read in RAM Block
	signal read_ram_data		: std_logic_vector (64-1 downto 0) := (others => '0');	--data we read from the RAM

	signal data_ram_sys_addr 	: std_logic_vector (16-1 downto 0) := (others => '0');	--sys_addr read from the RAM Block (bits 64-1 to 32)
	signal data_ram_sys_data 	: std_logic_vector (32-1 downto 0) := (others => '0');	--sys_data read from the RAM Block (bits 32-1 to 0)

	signal computer_want_data 	: std_logic := '0'; 									--signal if the computer ask for data
	signal searching_data		: std_logic := '0'; 									--signal if the the FSM is searching for data in the RAM (to turn off computer_want_data signal)
	signal wanted_sys_addr		: std_logic_vector (16-1 downto 0) := (others => '0');	--sys_addr from which the computer want the data
	--signal data_out 			: std_logic_vector (32-1 downto 0) := (others => '0');	--data we send back to the computer


	signal last_addr_with_data 	: std_logic_vector (8-1 downto 0) := x"34";	--last addr at which we save data to the RAM Block (initial value is hardcode according to the number of non-zero initial values in the DATA_FILE (0 to 52 -> 0x00 to 0x34))

	signal enable_new_entries	: std_logic := '1';

begin

    -- the actual ram
    ram_inst : entity work.simple_dualport_ram_with_init
    generic map (
        ADDRESS_WIDTH => 8,
        DATA_WIDTH    => 64,
        DATA_FILE 	  => "ram_init_file.txt"
		) 
    port map (
        clk_write     => clk,
        write_enable  => write_ram,
        write_address => write_ram_addr,
        write_data    => write_ram_data,
        
        clk_read      => clk,
        read_enable   => read_ram,
        read_address  => read_address,
        read_data     => read_ram_data
    );

	-- FSM process example
	data_ram_sys_addr  <= read_ram_data(48-1+2 downto 34);
	data_ram_sys_data <= read_ram_data(32-1 downto 0);

	sys_addr_to_save <= data_in (48-1+2 downto 34);

	-------------------------------------------------------------------
	-- Finite State Machine (FSM)
	process (clk)
	begin
		if rising_edge(clk) then
			case FSM_state is
				when STATE_IDLE =>						--If there are data in the FIFO, read them. Otherwise, check if computer want data
					-- we set back all data to nominal value to be sure they stay high at least one clock cycle
					write_ram <= '0';					--stop writing in the RAM block
					read_ram <= '0';					--stop reading the RAM
					
					read_fifo <= '0'; 					--stop reading the FIFO
					ack <= '0';							--put the ack to '0'
					searching_data <= '0';

					if last_addr_with_data = x"FF" then
						enable_new_entries <= '0';
					end if;

					if computer_want_data = '1' then
						read_address <= x"00";			--Reset the first address to read to 0000_0000
						read_ram <= '1';
						searching_data <= '1';
						FSM_state <= STATE_SEARCH_READ;
					elsif FIFO_empty = '0' then			--If FIFO is not empty, read data
						FSM_state <= STATE_FIFO_READ;
						read_fifo <= '1';
                    end if;

--------------------------------------------------Computer want data-------------------------------------------------------
				when STATE_SEARCH_READ => 				--This state only wait for 1 clock cycle to read data from RAM Block
					FSM_state <= STATE_VERIFY_READ;

				when STATE_VERIFY_READ =>
					if to_integer(unsigned(data_ram_sys_addr)) = to_integer(unsigned(wanted_sys_addr)) then --verify if the last addr from RAM is the addr we want
						data_out <= data_ram_sys_data;
						ack <= '1';
						read_ram <= '0';
						FSM_state <= STATE_READ_FOUND;
					-- verifier, cette LED est allumée ...
					elsif to_integer(unsigned(read_address)) = to_integer(unsigned(last_addr_with_data)) then --verify if the addr at which we wearch is the last addr at which we saved data
						data_out <= x"EFFFFFFF"; 	--value we send to the computer to tell we have not find anything
						ack <= '1';
						read_ram <= '0';
						FSM_state <= STATE_READ_NOT_FOUND;
					else --otherwise, increment the addr at which we read and try again
						read_address <= std_logic_vector(unsigned(read_address)+1);
						FSM_state <= STATE_SEARCH_READ;
					end if;
                    
				when STATE_READ_NOT_FOUND => 	--if we try all RAM addr at which we saved data and did not find anything
	 				--ack <= '1';				-- pusle ack to tell computer data are available
					FSM_state <= STATE_IDLE;


				when STATE_READ_FOUND =>		--wanted_sys_addr was find in RAM Block, send the corresponding data to the computer
                	 				-- pusle ack to tell computer data are available
                	FSM_state <= STATE_IDLE;


			 	-------------------------Fill RAM block with data from FIFO-------------------------
				when STATE_READING_FIFO =>
					FSM_state <= STATE_FIFO_READ;

				when STATE_FIFO_READ => --FIFO is not empty, read data and save in intermediate signals
             		read_fifo <= '0';
             		--prepare to read RAM
             		FSM_state <= STATE_LOOP_READ_RAM;
             		read_address <= x"00";			--Reset the first address to read to 0000_0000
             		read_ram <= '1'; 


				when STATE_LOOP_READ_RAM =>			--This state only wait for 1 clock cycle to read data from RAM Block
         			FSM_state <= STATE_LOOP_VERIFY_RAM;
				
				when STATE_LOOP_VERIFY_RAM =>
					if to_integer(unsigned(data_ram_sys_addr)) = to_integer(unsigned(sys_addr_to_save)) then 	--verify if the last sys_addr from RAM is the sys_addr we want to save
						FSM_state <= STATE_REPLACE_RAM;
						write_ram_addr <= read_address;
						write_ram_data <= data_in;
						write_ram <= '1';
						read_ram <= '0';
					elsif to_integer(unsigned(read_address)) = to_integer(unsigned(last_addr_with_data)) then --verify if the addr at which we wearched is the last addr at which we saved data
						read_ram <= '0';
						--if enable_new_entries = '1' then --If we reached the end of the RAM, we don't enable new entries (the maximum number of entries is 2**8 = 256)
						write_ram <= '1';
						write_ram_addr <= std_logic_vector(unsigned(last_addr_with_data)+1);
						last_addr_with_data <= std_logic_vector(unsigned(last_addr_with_data)+1);
						write_ram_data <= data_in;
						FSM_state <= STATE_NEW_RAM;
						--else
						--	FSM_state <= STATE_IDLE;
						--end if;
					else --otherwise, increment the addr at which we read and try again
						read_address <= std_logic_vector(unsigned(read_address)+1);
						FSM_state <= STATE_LOOP_READ_RAM;
					end if;
           
				when STATE_REPLACE_RAM => --we found sys_addr at which we want to save in RAM, overwrite sys_data
					write_ram <= '0';
					FSM_state <= STATE_IDLE;

				when STATE_NEW_RAM => --if the sys_addr was not in RAM, write addr & data at the next addr
					write_ram <= '0';
					FSM_state <= STATE_IDLE;

				when others =>
                    FSM_state <= STATE_IDLE;
			end case;
			end if;
	end process;
    -------------------------------------------------------------------
    -- registers

    ibus_manager : process (clk) is
    begin
    if rising_edge(clk) then
        --ack <= sys_ren;
        sys_err <= '0';
        if sys_ren='1' then
           	wanted_sys_addr <= addrAsk(16-1+2 downto 2);
            if (addrAsk(16-1+2 downto 2) < x"0025") or (x"0040" < addrAsk(16-1+2 downto 2)) then
                computer_want_data <= '1';
            end if;
        elsif searching_data = '1' then
           	computer_want_data <= '0';
        end if;
    end if;
    end process;
    -------------------------------------------------------------------
end;





--entity load_data_from_file is
--	Generic (
--		ADDRESS_WIDTH : positive := 15;
--		DATA_WIDTH : positive := 16;
--		DATA_FILE : string := "igm_rom.txt"
--	);
--	Port (
--		clk : in  STD_LOGIC;
--		read_address : in  STD_LOGIC_VECTOR (ADDRESS_WIDTH-1 downto 0);
--		data_out : out  STD_LOGIC_VECTOR (DATA_WIDTH-1 downto 0)
--	);
--end load_data_from_file;

--architecture Behavioral of load_data_from_file is
---- The libraries ieee.std_logic_unsigned and std.textio will need to be included
---- with this example
---- The following code will infer a Single port Block RAM and initialize it using a FILE
--    type ROM_TYPE is array(0 to 2**ADDRESS_WIDTH-1) of STD_LOGIC_VECTOR(DATA_WIDTH-1 downto 0);    
	 
--    impure function rom_function_name (rom_file_name : in string) return ROM_TYPE is                                                   
--       FILE rom_file         : text is in rom_file_name;                       
--       variable line_name : line;                                 
--       variable rom_name       : ROM_TYPE;
--       variable bitvec : bit_vector(DATA_WIDTH-1 downto 0);                                      
--    begin                                                        
--       for I in ROM_TYPE'range loop                                  
--           readline (rom_file, line_name);                             
--           read (line_name, bitvec);
--           rom_name(I) := to_stdlogicvector(bitvec);
--       end loop;                                                    
--       return rom_name;
--    end function;                                                

--    signal ROM : ROM_TYPE := rom_function_name(DATA_FILE);
	 
--	 signal data_out_tmp : STD_LOGIC_VECTOR (DATA_WIDTH-1 downto 0) := (others => '0');

--begin


--	process (clk)                                                
--	begin                                                        
--		if rising_edge(clk) then                              
--			--data_out_tmp <= to_stdlogicvector(ROM(conv_integer(read_address)));
--			data_out_tmp <= ROM(to_integer(unsigned(read_address)));
			
--		end if;
--	end process;
--	data_out <= data_out_tmp;

--end Behavioral;