


library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity SPI_master_write_only is
    port ( 
        clk                 : in    std_logic;
        data_input          : in    std_logic_vector(47 downto 0);  -- warning: if transfers smaller than 48 bits are used, the data should be stuffed in the msbs
        reg_address         : in    std_logic_vector(12 downto 0);
        reg_size_in_bits    : in    std_logic_vector(5 downto 0);   -- max is 48 bits, needs to be on 8-bits multiples
        send_reg            : in    std_logic;
        clk_div             : in    std_logic_vector(15 downto 0);
        core_ready          : out   std_logic;
        SPI_SCLK            : out   std_logic;
        SPI_SDIO            : out   std_logic;
        SPI_CSB             : out   std_logic
    );
end entity;

architecture behavioral of SPI_master_write_only is

    -- clock divider
    signal N_PER_CLK_CYCLES_HALF_MINUS_ONE : unsigned(15 downto 0)      := (others => '0');

    -- divided SPI clock counter and signals:
    signal SPI_clk_counter          : unsigned(15 downto 0)             := (others => '0');
    signal SPI_clk_state            : std_logic                         := '0';
    signal SPI_clk_state_dly        : std_logic                         := '0';
    signal SPI_falling_edge         : std_logic                         := '0'; 
    -- most of the state machine only runs on the falling edges of the clock
    
    -- State machine signals
    type fsm_state_type is (FSM_WAIT, 
                            FSM_WRITE_RW_BIT, 
                            FSM_WRITE_W1_BIT, 
                            FSM_WRITE_W0_BIT,
                            FSM_WRITE_ADDR, 
                            FSM_WRITE_DATA, 
                            FSM_WRITE_DONE);
    signal FSM_state : fsm_state_type := FSM_WAIT;
    
    -- this is used for the handshaking between the higher level controller and this low-level controller:
    signal data_to_send             : std_logic                         := '0';

    -- used for starting and stopping the clock so that our transfers always have the same latency from send_reg assertion
    signal bClkRunning : std_logic := '0';
    
    -- bit counters for address and data:
    signal bit_counter_for_addr     : unsigned(6-1 downto 0)            := (others => '0');
    signal bit_counter_for_data     : unsigned(6-1 downto 0)            := (others => '0');
    signal bit_counter_for_addr_reg : unsigned(6-1 downto 0)            := to_unsigned(13, bit_counter_for_addr'length);
    signal bit_counter_for_data_reg : unsigned(6-1 downto 0)            := (others => '0');
    
    -- shift registers for data and address:
    signal data_shift_register      : std_logic_vector(48-1 downto 0)   := (others => '0');
    signal data_shift_register_reg  : std_logic_vector(48-1 downto 0)   := (others => '0');
    signal addr_shift_register      : std_logic_vector(13-1 downto 0)   := (others => '0');
    signal addr_shift_register_reg  : std_logic_vector(13-1 downto 0)   := (others => '0');
    
    -- copy of output signals:
    signal spi_dout_internal        : std_logic                         := '1';
    signal spi_csb_internal         : std_logic                         := '1';
    signal core_ready_internal      : std_logic                         := '0';
    
    --attribute mark_debug : string;
    --attribute mark_debug of spi_dout_internal   : signal is "true";
    --attribute mark_debug of spi_csb_internal    : signal is "true";
    --attribute mark_debug of core_ready_internal : signal is "true";
    --attribute mark_debug of SPI_clk_state_dly   : signal is "true";
    
begin


    --------------------------------------------------------------------------------------------------------------------------------
    -- SPI clock generation
    --------------------------------------------------------------------------------------------------------------------------------
    
    -- The SPI clock counter. Counts only half cycles and toggles the clock state
    N_PER_CLK_CYCLES_HALF_MINUS_ONE <= shift_right(unsigned(clk_div),1) - to_unsigned(1, 16);
    
    spi_clock_gen : process (clk) is
    begin
        if rising_edge(clk) then
            if bClkRunning = '1' then
                if SPI_clk_counter < unsigned(N_PER_CLK_CYCLES_HALF_MINUS_ONE) then
                    SPI_falling_edge <= '0';
                    SPI_clk_counter <= SPI_clk_counter + 1;
                else
                    SPI_clk_counter <= (others => '0');
                    SPI_clk_state <= not SPI_clk_state;
                    if SPI_clk_state = '1' then
                        SPI_falling_edge <= '1';
                    else
                        SPI_falling_edge <= '0';
                    end if;
                end if;

                -- check if we need to stop the clock (this is to be able to do a transfer with reproducible timing from send_reg rising edge time)
                if spi_csb_internal = '1' and data_to_send = '0' then
                    bClkRunning <= '0';
                end if;
            else
                -- check if we need to start the clock (this is to be able to do a transfer with reproducible timing from send_reg rising edge time)
                if data_to_send = '1' then
                    bClkRunning <= '1';
                end if;
                -- set the SPI clock to a known state
                SPI_clk_counter <= (others => '0');
                SPI_clk_state <= '0';
            end if;
        end if;
    end process;
    
    
    --------------------------------------------------------------------------------------------------------------------------------
    -- Handshaking
    --------------------------------------------------------------------------------------------------------------------------------
    
    -- Implements a simple handshaking mecanism by generating the core_ready output, and monitoring the send_reg input.
    -- the difference is that this handshaker is clocked at the system clock rate rather than the SPI clock rate.
    handshaking : process (clk) is
    begin
        if rising_edge(clk) then
            if FSM_state = FSM_WAIT and send_reg = '1' and core_ready_internal = '1' then
                core_ready_internal <= '0';
                data_to_send <= '1';
--                read_not_write_reg <= read_not_write;

                -- register all signals
                bit_counter_for_addr_reg <= to_unsigned(13, bit_counter_for_addr'length);
                bit_counter_for_data_reg <= unsigned(reg_size_in_bits);
                addr_shift_register_reg <= reg_address;
                data_shift_register_reg <= data_input;
                
            --elsif FSM_state = FSM_WAIT and send_reg = '0' and data_to_send = '0' then
            elsif FSM_state = FSM_WAIT and data_to_send = '0' then
                core_ready_internal <= '1';
                
            elsif FSM_state = FSM_WRITE_DONE then
                data_to_send <= '0';
            end if;
        end if;
    end process;
    
    --------------------------------------------------------------------------------------------------------------------------------
    -- The controller FSM for the whole module.
    --------------------------------------------------------------------------------------------------------------------------------
    fsm : process (clk) is
    begin
        if rising_edge(clk) then
            if SPI_falling_edge = '1' then
                case FSM_state is
                    when FSM_WAIT =>
                        spi_csb_internal <= '1';
                        if data_to_send = '1' then
                            -- initiate the write
                            FSM_state <= FSM_WRITE_RW_BIT;
                            
                            -- register all signals, prepare counters and shift registers
                            bit_counter_for_addr <= bit_counter_for_addr_reg;
                            bit_counter_for_data <= bit_counter_for_data_reg;
                            addr_shift_register <= addr_shift_register_reg;
                            data_shift_register <= data_shift_register_reg;
                            
                        end if;
                        
                    when FSM_WRITE_RW_BIT =>
                        -- 0 means write, 1 means read
                        spi_dout_internal <= '0';
                        spi_csb_internal <= '0';    -- this means that the next rising_edge of the clock will be enabled
                        FSM_state <= FSM_WRITE_W1_BIT;
                        
                    when FSM_WRITE_W1_BIT =>
                        -- w1 = '1', and w0 = '1' means streaming mode
                        spi_dout_internal <= '1';
                        FSM_state <= FSM_WRITE_W0_BIT;
                        
                    when FSM_WRITE_W0_BIT =>
                        spi_dout_internal <= '1';
                        FSM_state <= FSM_WRITE_ADDR;
                        
                    when FSM_WRITE_ADDR =>
                        if bit_counter_for_addr = 1 then
                            FSM_state <= FSM_WRITE_DATA;
                        end if;
                        bit_counter_for_addr <= bit_counter_for_addr - 1;
                        spi_dout_internal <= addr_shift_register(addr_shift_register'left);
                        addr_shift_register <= (addr_shift_register(addr_shift_register'left-1 downto 0) & '0');
                        
                    when FSM_WRITE_DATA =>
                        if bit_counter_for_data = 1 then
                            FSM_state <= FSM_WRITE_DONE;
                        end if;
                        bit_counter_for_data <= bit_counter_for_data - 1;
                        spi_dout_internal <= data_shift_register(data_shift_register'left);
                        data_shift_register <= (data_shift_register(data_shift_register'left-1 downto 0) & '0');
                        
                    when FSM_WRITE_DONE =>
                        spi_csb_internal <= '1';
                        FSM_state <= FSM_WAIT;
                        
                    when others =>
                        FSM_state <= FSM_WAIT;
                end case;
            end if;
            
        end if;
    end process;
    
    --------------------------------------------------------------------------------------------------------------------------------
    -- Clock alignement
    --------------------------------------------------------------------------------------------------------------------------------
    
    -- add a one clock cycle delay to the clock, so that the data transitions are well centered:
    clock_align : process (clk)
    begin
        if rising_edge(clk) then
            SPI_clk_state_dly <= SPI_clk_state;
        end if;
    end process;
    
    --------------------------------------------------------------------------------------------------------------------------------
    -- Connect the output ports
    --------------------------------------------------------------------------------------------------------------------------------
    core_ready <= core_ready_internal;
    spi_csb <= spi_csb_internal;
    SPI_SDIO <= spi_dout_internal;    -- this could be a three-state driver at some point if we implement register reads
    SPI_SCLK <= SPI_clk_state_dly;
    

end architecture;

