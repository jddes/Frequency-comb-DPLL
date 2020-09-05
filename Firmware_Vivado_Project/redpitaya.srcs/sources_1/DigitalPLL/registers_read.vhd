library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


entity registers_read  is
Generic (
	LOGGER_WIDTH : integer := 32
    
);
port (
	
    clk                                    : in  std_logic;
    
    -- status registers inputs:
    dither_results1   : in  std_logic_vector(64-1 downto 0);
    dither_results2   : in  std_logic_vector(64-1 downto 0);
    dither_results3   : in  std_logic_vector(64-1 downto 0);
    dither_results4   : in  std_logic_vector(64-1 downto 0);

    -- these get written to ram_data_logger_v2
    clk_enable_logger                      : in  std_logic;
    new_data_chunk                         : in  std_logic;
    data_logger                            : in  std_logic_vector(LOGGER_WIDTH-1 downto 0);


    -- internal configuration bus
    sys_addr                               : in  std_logic_vector(32-1 downto 0);   -- bus address
    sys_wdata                              : in  std_logic_vector(32-1 downto 0);   -- bus write data
    sys_wen                                : in  std_logic;   -- bus write enable
    sys_ren                                : in  std_logic;   -- bus read enable
    sys_rdata                              : out std_logic_vector(32-1 downto 0);  -- bus read data
    sys_err                                : out std_logic;  -- bus error indicator
    sys_ack                                : out std_logic   -- bus acknowledge signal
	);
end entity;

architecture Behavioral of registers_read is

    signal dither_results_reg   : std_logic_vector(64-1 downto 0) := (others => '0');
    


    ---- ram_data_logger_v2 signals

    -- Data logger rate:
    -- 32 bits/input word * 12 words/clk enable, ~100 clk enables/sec = 38.4e3 bits/sec = 1200 words/sec, so 10 address bits is just shy of 1 sec of recording
    -- in terms of BlockRAM (38K), assuming that we using use 32 bits wide (not sure how efficiently that gets packed in, so I assume the worst case)
    -- 2^13 adresses / 1000 words per BRAM = 2^3 = 8 BRAMS
    constant ADDRESS_WIDTH : integer := 13;
    constant CHUNK_SIZE    : integer := 12; -- 12 words per clk enable at the input of mux_phase_to_logger.vhd

    -- Inputs
    signal start_write        : std_logic                                  := '0';
    signal start_read         : std_logic                                  := '0';
    signal read_ack           : std_logic                                  := '0';
    signal read_start_address : std_logic_vector(ADDRESS_WIDTH-1 downto 0) := (others => '0');
    -- Outputs
    signal read_data     : std_logic_vector( LOGGER_WIDTH-1 downto 0);
    signal write_address : std_logic_vector(ADDRESS_WIDTH-1 downto 0);


begin

    ram_data_logger_inst : entity work.ram_data_logger_v2
    generic map (
        ADDRESS_WIDTH => ADDRESS_WIDTH,
        DATA_WIDTH    => LOGGER_WIDTH,
        CHUNK_SIZE    => CHUNK_SIZE
    ) port map (
        clk                => clk,
        data_in            => data_logger,
        data_in_clk_enable => clk_enable_logger,
        new_data_chunk     => new_data_chunk,
        start_write        => start_write,
        start_read         => start_read,
        read_ack           => read_ack,
        wraparound_mode    => '1',
        read_data          => read_data,
        write_address      => write_address,
        read_start_address => read_start_address
    );

    -----------------------------------------
    -- registers

    ibus_manager : process (clk) is
        variable sys_en : std_logic := '0';
    begin
        if rising_edge(clk) then
            sys_err <= '0';
            sys_en := sys_wen or sys_ren;

            -- default
            read_ack <= '0';
            sys_rdata <=  (others => '0');
            

            -- Write
            if sys_wen = '1' then
                case sys_addr(16-1+2 downto 2) is
                    when x"00041" => start_write        <= sys_wdata(0);
                    when x"00042" => start_read         <= sys_wdata(0);
                    when x"00043" => read_start_address <= sys_wdata(ADDRESS_WIDTH-1 downto 0);

                    when others => 
                end case;
            end if;

            -- Read
            -------------------------------------------------------------
            -- Note that sys_addr is divided by 4 in the case statement,
            -- in order to make it easy to enfore the Zynq-imposed requirement of falling on 32-bits boundaries
            if sys_ren = '1' then
                case sys_addr(16-1+2 downto 2) is

                    -- these pairs should always be read sequentially, in this order, so that we sample all bits at exactly the same time
                    when x"00030" => sys_ack <= sys_en; sys_rdata <= dither_results1(32-1 downto 0); dither_results_reg <= dither_results1;
                    when x"00031" => sys_ack <= sys_en; sys_rdata <= dither_results_reg(32+32-1 downto 32);
                        
                    -- these pairs should always be read sequentially, in this order, so that we sample all bits at exactly the same time
                    when x"00032" => sys_ack <= sys_en; sys_rdata <= dither_results2(32-1 downto 0); dither_results_reg <= dither_results2;
                    when x"00033" => sys_ack <= sys_en; sys_rdata <= dither_results_reg(32+32-1 downto 32);

                    -- these pairs should always be read sequentially, in this order, so that we sample all bits at exactly the same time
                    when x"00034" => sys_ack <= sys_en; sys_rdata <= dither_results3(32-1 downto 0); dither_results_reg <= dither_results3;
                    when x"00035" => sys_ack <= sys_en; sys_rdata <= dither_results_reg(32+32-1 downto 32);

                    -- these pairs should always be read sequentially, in this order, so that we sample all bits at exactly the same time
                    when x"00036" => sys_ack <= sys_en; sys_rdata <= dither_results4(32-1 downto 0); dither_results_reg <= dither_results4;
                    when x"00037" => sys_ack <= sys_en; sys_rdata <= dither_results_reg(32+32-1 downto 32);

                    when x"00044" => sys_ack <= sys_en; sys_rdata <= read_data;     read_ack <= '1';
                    when x"00045" => sys_ack <= sys_en; sys_rdata(write_address'range) <= write_address;
                    

                    when others   => sys_ack <= sys_en;     sys_rdata <=  (others => '0');
                end case;
            else
                sys_ack <= sys_en;
            end if;

        end if;
    end process;


end;
