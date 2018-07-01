library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


entity ram_data_logger  is
Generic (
    ADDRESS_WIDTH   : integer := 15;
    DATA_WIDTH      : integer := 16
);
port (
    clk                                    : in  std_logic;
    
    -- data input interface
    data_in                                : in  std_logic_vector(16-1 downto 0);
    data_in_clk_enable                     : in  std_logic;
    -- control interface
    is_writing                             : out std_logic;
    
    -- CPU interface
    sys_addr                               : in  std_logic_vector(32-1 downto 0);   -- bus address
    sys_wdata                              : in  std_logic_vector(32-1 downto 0);   -- bus write data
    sys_sel                                : in  std_logic_vector(4-1 downto 0);   -- bus write byte select
    sys_wen                                : in  std_logic;   -- bus write enable
    sys_ren                                : in  std_logic;   -- bus read enable
    sys_rdata                              : out std_logic_vector(32-1 downto 0);  -- bus read data
    sys_err                                : out std_logic;  -- bus error indicator
    sys_ack                                : out std_logic   -- bus acknowledge signal


    );
end entity;

architecture Behavioral of ram_data_logger is

    type state_type is (STATE_IDLE, STATE_START, STATE_WRITE);
    signal FSM_state      : state_type := STATE_IDLE;
    signal bWriting       : std_logic  := '0';
    
    signal write_enable   : std_logic  := '0';
    signal write_address  : std_logic_vector (ADDRESS_WIDTH-1 downto 0) := (others => '0');
    signal write_data     : std_logic_vector (DATA_WIDTH-1    downto 0) := (others => '0');
    
    signal read_enable    : std_logic  := '1';
    signal read_address   : std_logic_vector (ADDRESS_WIDTH-1 downto 0) := (others => '0');
    signal read_data      : std_logic_vector (DATA_WIDTH-1    downto 0) := (others => '0');
    
    signal sys_ren_d1     : std_logic  := '0';
    signal data_valid     : std_logic  := '0';
    signal start_write_d1 : std_logic  := '0';
    signal start_write    : std_logic  := '0';
begin


    -- the actual ram
    ram_inst : entity work.simple_dualport_ram
    generic map (
        ADDRESS_WIDTH => ADDRESS_WIDTH,
        DATA_WIDTH    => DATA_WIDTH

    ) port map (
        clk_write     => clk,
        write_enable  => write_enable,
        write_address => write_address,
        write_data    => write_data,
        
        clk_read      => clk,
        read_enable   => read_enable,
        read_address  => read_address,
        read_data     => read_data
    );

    write_enable <= data_in_clk_enable and bWriting;
    write_data   <= data_in;
    read_enable  <= '1'; -- no point in using this feature since we don't care about power consumption

    -- FSM process which controls the writing to the ram
    process (clk)
    begin
        if rising_edge(clk) then
            start_write_d1 <= start_write;  -- rising edge detection
            if start_write = '1' and start_write_d1 = '0' then  -- a rising edge on start_write starts the writing process
                FSM_state <= STATE_START;

            else
                case FSM_state is
                    when STATE_IDLE =>
                        -- writes are disabled
                        bWriting <= '0';

                    when STATE_START =>
                        bWriting <= '1';    -- next data point will be written, unless this is the last
                        write_address <= (others => '0');
                        FSM_state <= STATE_WRITE;
                        
                    when STATE_WRITE =>
                        bWriting <= '1';    -- next data point will be written, unless this is the last
                        if data_in_clk_enable = '1' then
                            
                            if write_address = (write_address'range => '1') then
                                -- we are done, stop writing
                                bWriting <= '0';
                                FSM_state <= STATE_IDLE;
                                
                            else
                                -- still filling up the ram
                                write_address <= std_logic_vector(unsigned(write_address)+1);
                            end if;
                        end if;
                    when others =>
                        FSM_state <= STATE_IDLE;
                end case;
            end if;

        end if;
    end process;

    is_writing <= bWriting;

    -- process which handles reading the ram and sending the results to the cpu
    -- also handles the registers reads and writes
    ibus_manager : process (clk) is
        variable sys_en : std_logic := '0';
    begin
        if rising_edge(clk) then
            sys_err <= '0';
            sys_en := sys_wen or sys_ren;

            read_address <= sys_addr(read_address'length-1+2 downto 2);   -- we divide the sys_addr by 4 because the CPU has restrictions: it cannot access memory that is not aligned on 32-bits boundary (4 bytes)
            -- small delay line to match ram latency
            sys_ren_d1 <= sys_ren;
            data_valid <= sys_ren_d1;

            -- default values:
            start_write <= '0';

            -- Write
            if sys_wen = '1' then
                case sys_addr(20-1 downto 0) is
                    -- this acts as a one cycle-long trigger since the default value is 0
                    when x"1004" => start_write <= '1'; 
                    --when x"000" => amplitude                     <= sys_wdata(amplitude'range);

                    when others => 
                end case;
            end if;

            -- Read
            -- we use the full 20 bits address-space for the ram, hence no read registers.
            sys_ack <= data_valid or sys_wen; sys_rdata <= std_logic_vector(resize(  signed(read_data), 32));
            ---- read specific registers
            --if sys_addr(20-1 downto 0) = x"000" then
            --    sys_ack <= sys_en; sys_rdata <= std_logic_vector(resize(unsigned(write_address), 32));
            ---- read from the ram
            --elsif sys_addr(20-1) = '1' then
            --    sys_ack <= data_valid; sys_rdata <= std_logic_vector(resize(  signed(read_data), 32));
            ---- this is used on either reads or writes, we just ack
            --else
            --    sys_ack <= sys_en; sys_rdata <=  (others => '0');
            --end if;


                
        end if;
    end process;


end;
