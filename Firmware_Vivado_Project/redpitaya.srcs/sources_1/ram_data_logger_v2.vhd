library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


entity ram_data_logger_v2 is
Generic (
    ADDRESS_WIDTH   : integer := 15;
    DATA_WIDTH      : integer := 16;
    CHUNK_SIZE      : integer := 10 -- optional, to be used with new_data_chunk
);
port (
    clk                : in  std_logic;
    
    -- data input interface
    data_in            : in  std_logic_vector(DATA_WIDTH-1 downto 0);
    data_in_clk_enable : in  std_logic;
    new_data_chunk     : in  std_logic; -- optional: asserting this moves the write pointer in increments of chunk_size, in order to enforce writing in this chunk size
    
    -- register interface
    start_write        : in  std_logic; -- strobe 1 on this to set the core to write mode, which resets the write address to 0, and starts accepting data until full
    start_read         : in  std_logic; -- strobe 1 on this to set the read address to 0
    read_ack           : in  std_logic; -- strobe 1 on this to acknowledge receipt of the current read_data, and force the read address to advance
    wraparound_mode    : in  std_logic; -- setting this to 1 means that the core doesn't stop writing when it reaches the last address, instead the write address just wraps around
    read_data          : out std_logic_vector(   DATA_WIDTH-1 downto 0);
    write_address      : out std_logic_vector(ADDRESS_WIDTH-1 downto 0); -- to monitor the current fill state of the ram
    read_start_address : in  std_logic_vector(ADDRESS_WIDTH-1 downto 0) -- this is the address that gets loaded when "start_read" gets asserted

    );
end entity;

architecture Behavioral of ram_data_logger_v2 is

    constant CHUNK_WRAP_ADDR : integer := (2**ADDRESS_WIDTH/CHUNK_SIZE-1)*CHUNK_SIZE;

    type state_type is (STATE_IDLE, STATE_FIRST_PT, STATE_WRITE);
    signal FSM_state         : state_type := STATE_IDLE;
    
    signal write_enable      : std_logic  := '0';
    signal write_address_int : std_logic_vector (ADDRESS_WIDTH-1 downto 0) := (others => '0');
    signal write_address_reg : std_logic_vector (ADDRESS_WIDTH-1 downto 0) := (others => '0');
    signal write_data        : std_logic_vector (   DATA_WIDTH-1 downto 0) := (others => '0');
    
    signal read_enable       : std_logic  := '1';
    signal read_address      : std_logic_vector (ADDRESS_WIDTH-1 downto 0) := (others => '0');
    
    -- for rising edge detection:
    signal start_read_d1      : std_logic  := '0';
    signal start_write_d1     : std_logic  := '0';
    signal new_data_chunk_d1 : std_logic  := '0';

    -- for writing in fixed chunk size:
    signal next_chunk_addr : unsigned(ADDRESS_WIDTH-1 downto 0) := (others => '0');
begin


    -- the actual ram
    ram_inst : entity work.simple_dualport_ram
    generic map (
        ADDRESS_WIDTH => ADDRESS_WIDTH,
        DATA_WIDTH    => DATA_WIDTH
    ) port map (
        clk_write      => clk,
        write_enable   => write_enable,
        write_address  => write_address_int,
        write_data     => write_data,
        --user_data_in_a => (others => '0'),
        
        clk_read      => clk,
        read_enable   => read_enable,
        read_address  => read_address,
        read_data     => read_data
        --user_data_in  => (others => '0')
    );

    read_enable  <= '1'; -- no point in using this feature since we don't care about power consumption

    -- FSM process which controls the writing to the ram
    process (clk)
    begin
        if rising_edge(clk) then
            -- registers for rising edge detection
            start_write_d1    <= start_write;  
            new_data_chunk_d1 <= new_data_chunk;

            case FSM_state is
                when STATE_IDLE =>
                    -- writes are disabled
                    write_enable <= '0';

                when STATE_FIRST_PT =>
                    write_address_int <= (others => '0');
                    write_enable      <= data_in_clk_enable;
                    write_data        <= data_in;
                    next_chunk_addr   <= to_unsigned(chunk_size, ADDRESS_WIDTH);
                    if data_in_clk_enable = '1' then
                        FSM_state <= STATE_WRITE;
                    end if;
                    
                when STATE_WRITE =>
                    write_enable      <= data_in_clk_enable;
                    write_data        <= data_in;

                    -- advance the write address if necessary
                    if new_data_chunk='1' and new_data_chunk_d1='0' then
                        -- advance to next chunk
                        write_address_int <= std_logic_vector(next_chunk_addr);
                        if next_chunk_addr < CHUNK_WRAP_ADDR then
                            next_chunk_addr <= next_chunk_addr + to_unsigned(CHUNK_SIZE, ADDRESS_WIDTH);
                        else
                            next_chunk_addr <= (others => '0');
                        end if;
                    else

                        if data_in_clk_enable = '1' then
                            -- advance by 1 only
                            if wraparound_mode='1' then
                                write_address_int <= std_logic_vector(unsigned(write_address_int)+1);
                            else
                                -- stop if ram is full
                                if write_address_int = (write_address_int'range => '1') then
                                    -- we are done, stop writing
                                    FSM_state <= STATE_IDLE;
                                    write_enable <= '0';
                                    
                                else
                                    -- still filling up the ram
                                    write_address_int <= std_logic_vector(unsigned(write_address_int)+1);
                                end if;

                            end if;

                            -- update next_chunk_addr if necessary:
                            if unsigned(write_address_int)+1 = next_chunk_addr then
                                if next_chunk_addr < CHUNK_WRAP_ADDR then
                                    next_chunk_addr <= next_chunk_addr + to_unsigned(CHUNK_SIZE, ADDRESS_WIDTH);
                                else
                                    next_chunk_addr <= (others => '0');
                                end if;
                            end if;

                        end if;
                    end if;



                when others =>
                    FSM_state <= STATE_IDLE;
            end case;


            -- write this here so it takes precedance; effectively resets the writing process
            if start_write = '1' and start_write_d1 = '0' then  -- a rising edge on start_write starts the writing process
                FSM_state         <= STATE_FIRST_PT;
            end if;

        end if;
    end process;

    -- one register on the write_address before sending this out to decouple the timing a bit
    process(clk)
    begin
        if rising_edge(clk) then
            write_address_reg <= write_address_int;
        end if;
    end process;
    write_address <= write_address_reg;

    -- generate the read address:
    process( clk )
    begin
        if rising_edge(clk) then
            start_read_d1 <= start_read;
            if start_read = '1' and start_read_d1 = '0' then
                read_address <= read_start_address;
            else
                if read_ack = '1' then
                    read_address <= std_logic_vector(unsigned(read_address) + 1);
                end if;
            end if;
        end if;
    end process;


end;
