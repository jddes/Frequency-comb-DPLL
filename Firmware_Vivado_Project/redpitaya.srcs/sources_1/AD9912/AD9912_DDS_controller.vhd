library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity AD9912_DDS_controller is
    port 
    ( 
        clk                        : in  std_logic;
        freq_word                  : in  std_logic_vector(48-1 downto 0);
        freq_word_delay_only       : in  std_logic_vector(48-1 downto 0);
        update_freq                : in  std_logic;

        -- this is used to update AD9912 registers directly
        register_write             : in  std_logic; -- rising edge on this starts the transfer at the next opportuinity
        register_address           : in  std_logic_vector(13-1 downto 0);
        register_value             : in  std_logic_vector( 8-1 downto 0);

        current_dds_freq           : out std_logic_vector(48-1 downto 0);
        timestamp_in               : in  std_logic_vector(64-1 downto 0);
        timestamp_at_freq_update   : out std_logic_vector(64-1 downto 0);
        clk_div                    : in  std_logic_vector(16-1 downto 0);
        SPI_SCLK                   : out std_logic;
        SPI_SDIO                   : out std_logic;
        SPI_CSB                    : out std_logic
    );
end entity;

architecture behavioral of AD9912_DDS_controller is

    -- State machine signals
    type fsm_state_type is (FSM_WAIT, 
                            FSM_WAIT_FOR_CORE1, 
                            FSM_WAIT_FOR_CORE2,
                            FSM_SEND_FREQ_WORD, 
                            FSM_SEND_UPDATE_BIT,
                            FSM_SEND_USER_CONFIG
                            );
    signal FSM_state                    : fsm_state_type                    := FSM_WAIT;
    signal FSM_next_state               : fsm_state_type                    := FSM_WAIT;
    
    -- Configuration signals
    signal register_write_d1      : std_logic := '0';
    signal pending_register_write : std_logic := '0';
    signal register_address_reg   : std_logic_vector(register_address'length-1 downto 0) := (others => '0');
    signal register_value_reg     : std_logic_vector(register_value'length-1 downto 0) := (others => '0');
    
    signal freq_reg                     : std_logic_vector(48-1 downto 0)   := (others => '0');
    
    -- Signals to communicate with the SPI core:

    signal data_input                   : std_logic_vector(47 downto 0)     := (others => '0');
    signal reg_address                  : std_logic_vector(12 downto 0)     := (others => '0');
    signal reg_size_in_bits             : std_logic_vector(5 downto 0)      := (others => '0');
    signal send_reg                     : std_logic                         := '0';
   
    -- This is used to synchronize the update of the dds frequency 
    signal bWasSendingUpdate            : std_logic                         := '0';    
   
    signal current_dds_freq_internal    : std_logic_vector(48-1 downto 0)   := (others => '0');
    signal timestamp_at_freq_update_int : std_logic_vector(64-1 downto 0)    := (others => '0');

    
    -- Outputs
    signal core_ready                   : std_logic                         := '0';

begin

    --------------------------------------------------------------------------------------------------------------------------------
    -- The controller FSM for the whole module.
    --------------------------------------------------------------------------------------------------------------------------------
    fsm : process (clk) is
    begin
        if rising_edge(clk) then
            -- remember register writes until we actually have a chance to commit them
            register_write_d1 <= register_write;
            if register_write = '1' and register_write_d1 = '0' then
                pending_register_write <= '1';
                register_address_reg   <= register_address;
                register_value_reg     <= register_value;
            end if;

            case FSM_state is
            
                when FSM_WAIT =>
                    send_reg <= '0';
                    --if do_config_internal = '1' then
                    --    FSM_state <= FSM_WAIT_FOR_CORE1;
                    --    FSM_next_state <= FSM_SEND_REG1;
                    if pending_register_write = '1' then
                        pending_register_write <= '0';
                        FSM_state <= FSM_WAIT_FOR_CORE1;
                        FSM_next_state <= FSM_SEND_USER_CONFIG;
                        
                    elsif update_freq = '1' then
                        FSM_state <= FSM_WAIT_FOR_CORE1;
                        FSM_next_state <= FSM_SEND_FREQ_WORD;
                        freq_reg <= freq_word;
                    end if;

                -- these are the configuration states:
                ---------------------------------------
                
--                -- this either disables the internal PLL so that the external clock drives the DDS core directly, or enables it so that the SYSCLK input frequency can be multiplied up.
--                when FSM_SEND_REG1 =>    

--                    reg_address <= b"0" & x"010";
--                    reg_size_in_bits <= std_logic_vector(to_unsigned(8, reg_size_in_bits'length));
--                    data_input <= (x"D0" & std_logic_vector(to_unsigned(0, 48-8)));    -- Power-down SYSCLK PLL
----                    data_input <= (x"C0" & std_logic_vector(to_unsigned(0, 48-8)));    -- Enable SYSCLK PLL
--                    send_reg <= '1';
                    
--                    FSM_state <= FSM_WAIT_FOR_CORE1;
--                    FSM_next_state <= FSM_SEND_REG2;
                    
                    
--                -- sets the N-divider value (register 0x0020)
--                when FSM_SEND_REG2 =>    
--                    reg_address <= b"0" & x"020";
--                    reg_size_in_bits <= std_logic_vector(to_unsigned(8, reg_size_in_bits'length));
--                    data_input <= (x"00" & std_logic_vector(to_unsigned(0, 48-8)));    -- a value of 0 in this register means a division ratio of (0+2)*2 = 4 of the internal VCO, meaning a multiplication of the input clock by 4
--                    send_reg <= '1';
                    
--                    FSM_state <= FSM_WAIT_FOR_CORE1;
--                    FSM_next_state <= FSM_SEND_REG3;
                    
--                -- sets the VCO range register (register 0x0022)
--                when FSM_SEND_REG3 =>    
--                    reg_address <= b"0" & x"022";
--                    reg_size_in_bits <= std_logic_vector(to_unsigned(8, reg_size_in_bits'length));
--                    data_input <= (b"0000_0011" & std_logic_vector(to_unsigned(0, 48-8)));    -- VCO range to low-band (700-810 MHz), Charge-pump current of 125 uA (the lowest setting)
--                    send_reg <= '1';
                    
--                    FSM_state <= FSM_WAIT_FOR_CORE1;
--                    FSM_next_state <= FSM_WAIT;
                    
--                    initial_config_done <= '1';

                when FSM_SEND_USER_CONFIG =>
                    reg_address <= register_address_reg;
                    data_input <= register_value_reg & x"00_0000_0000"; -- data is padded from 8 bits to 48 bits, value stuffed in MSBs
                    reg_size_in_bits <= std_logic_vector(to_unsigned(8, reg_size_in_bits'length));
                    send_reg <= '1';
                    FSM_state <= FSM_WAIT_FOR_CORE1;
                    FSM_next_state <= FSM_WAIT;

                ----------------------------------------
                    
                -- This programs a new frequency, which is loaded when we write a 1 to the 'update' register (0x0005)    
                when FSM_SEND_FREQ_WORD =>
                    reg_address <= b"0" & x"1AB";
                    reg_size_in_bits <= std_logic_vector(to_unsigned(48, reg_size_in_bits'length));
                    data_input <= freq_reg;
                    send_reg <= '1';
                    
                    FSM_state <= FSM_WAIT_FOR_CORE1;
                    FSM_next_state <= FSM_SEND_UPDATE_BIT;
                    
                -- This update strobe makes the DDS load the new frequency word (amongst other things, see datasheet for exactly which ones)
                when FSM_SEND_UPDATE_BIT =>
                    reg_address <= b"0" & x"005";
                    data_input <= (x"01" & std_logic_vector(to_unsigned(0, 48-8)));
                    reg_size_in_bits <= std_logic_vector(to_unsigned(8, reg_size_in_bits'length));
                    send_reg <= '1';
                    bWasSendingUpdate <= '1';
                    
                    FSM_state <= FSM_WAIT_FOR_CORE1;
                    FSM_next_state <= FSM_WAIT;
                    
                when FSM_WAIT_FOR_CORE1 =>    -- this extra wait state is to wait for the internal core to get a chance to signal that it is busy
                    FSM_state <= FSM_WAIT_FOR_CORE2;
                when FSM_WAIT_FOR_CORE2 =>
                    send_reg <= '0';
                    if core_ready = '1' then
                        FSM_state <= FSM_next_state;
                        if bWasSendingUpdate = '1' then
                            bWasSendingUpdate <= '0';
                            -- accept the new frequency value:
                            
                            -- Change by HB 3/31/2015
                            current_dds_freq_internal <= freq_word_delay_only;
                            timestamp_at_freq_update_int <= timestamp_in;
                            --current_dds_freq_internal <= freq_word;
                        end if;
                    end if;
                    
                when others =>
                    FSM_state <= FSM_WAIT;
            end case;
            
        end if;
    end process;
    
    --------------------------------------------------------------------------------------------------------------------------------
    -- SPI bus master
    --------------------------------------------------------------------------------------------------------------------------------
    
    SPI_master_write_only_inst: entity work.SPI_master_write_only
    port map (
        clk                 => clk,
        data_input          => data_input,
        reg_address         => reg_address,
        reg_size_in_bits    => reg_size_in_bits,
        send_reg            => send_reg,
        clk_div             => clk_div,
        core_ready          => core_ready,
        SPI_SCLK            => SPI_SCLK,
        SPI_SDIO            => SPI_SDIO,
        SPI_CSB             => SPI_CSB
    );
    
    --------------------------------------------------------------------------------------------------------------------------------
    -- Connect the output signals
    --------------------------------------------------------------------------------------------------------------------------------
    current_dds_freq         <= current_dds_freq_internal;
    timestamp_at_freq_update <= timestamp_at_freq_update_int;
          
end architecture;

