library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


entity registers_read  is
--Generic (
--	DATA_WIDTH			: integer := 16;
--);
port (
	
    clk                                    : in  std_logic;
    

    -- Registers inputs (to be read)
    status_flags                           : in  std_logic_vector(32-1 downto 0);
    -- these get sampled internally together even though they go through multiple reads by the CPU
    dither0_lockin_output                  : in  std_logic_vector(64-1 downto 0);
    -- these get sampled internally together even though they go through multiple reads by the CPU
    dither1_lockin_output                  : in  std_logic_vector(64-1 downto 0);

    -- these get sampled internally together even though they go through multiple reads by the CPU
    zdtc_samples_number_counter            : in  std_logic_vector(32-1 downto 0);
    counter0_out                           : in  std_logic_vector(64-1 downto 0);
    counter1_out                           : in  std_logic_vector(64-1 downto 0);
    DAC0_out                               : in  std_logic_vector(32-1 downto 0);
    DAC1_out                               : in  std_logic_vector(32-1 downto 0);
    DAC2_out                               : in  std_logic_vector(32-1 downto 0);


    -- internal configuration bus
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

architecture Behavioral of registers_read is

    signal dither0_lockin_output_reg   : std_logic_vector(64-1 downto 0) := (others => '0');
    signal dither1_lockin_output_reg   : std_logic_vector(64-1 downto 0) := (others => '0');
    
    signal counter0_out_reg            : std_logic_vector(64-1 downto 0) := (others => '0');
    signal counter1_out_reg            : std_logic_vector(64-1 downto 0) := (others => '0');
    signal DAC0_out_reg                : std_logic_vector(32-1 downto 0) := (others => '0');
    signal DAC1_out_reg                : std_logic_vector(32-1 downto 0) := (others => '0');
    signal DAC2_out_reg                : std_logic_vector(32-1 downto 0) := (others => '0');

    -- this is for a throughput test, a simple counter at 100 MHz
    signal counter_for_throughput_test  : std_logic_vector(32-1 downto 0) := (others => '0');
    signal data_counter_for_throughput_test : std_logic_vector(32-1 downto 0) := (others => '0');
    signal bWritesEnabled : std_logic := '0';

    -- coregen fifo
    component fifo_generator_0 
    PORT (
        clk : IN STD_LOGIC;
        srst : IN STD_LOGIC;
        din : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
        wr_en : IN STD_LOGIC;
        rd_en : IN STD_LOGIC;
        dout : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
        full : OUT STD_LOGIC;
        empty : OUT STD_LOGIC;
        data_count : OUT STD_LOGIC_VECTOR(10 DOWNTO 0);
        prog_empty : OUT STD_LOGIC
    );
    END component;

    -- fifo signals

    signal fifo_srst       : std_logic := '0';
    signal fifo_wr_en      : std_logic := '0';
    signal fifo_rd_en      : std_logic := '0';
    signal fifo_prog_empty : std_logic := '0';

    signal fifo_dout : std_logic_vector(32-1 downto 0) := (others => '0');
    signal fifo_data_count : std_logic_vector(11-1 downto 0) := (others => '0');

    signal fifo_data_count_max : std_logic_vector(11-1 downto 0) := (others => '0');
    signal fifo_rd_en_d1  : std_logic := '0';
begin

    -- fifo for continuous logging
    -- max performance seems to be around ~5e6 reads/sec, 32 bits for each read
    -- 2 MS/s at 32 bits/sample, fifo_data_count reaches around 400 worst case.
    fifo_generator_0_inst : fifo_generator_0 
    port map (
        clk        => clk,
        -- write port
        srst       => fifo_srst,
        din        => data_counter_for_throughput_test,
        wr_en      => fifo_wr_en,
        
        -- read port
        rd_en      => fifo_rd_en,
        dout       => fifo_dout,
        
        -- status signals
        full       => open,
        empty      => open,    -- we don't use this, instead we only use the prog_empty signal and read 10 samples at a time to minimize the overhead of checking fifo status
        data_count => fifo_data_count,
        prog_empty => fifo_prog_empty
    );

    -- process which controls the fifo (also fills the fifo with test data for the throughput test)
    process (clk)
    begin
        if rising_edge(clk) then
            -- fills the fifo with test data for the throughput test
            if fifo_srst = '1' then
                fifo_wr_en <= '0';
                data_counter_for_throughput_test <= (others => '0');
            else
                -- 100 MHz/50 = 2 MHz data rate
                -- 100 MHz/25 = 4 MHz data rate
                if unsigned(counter_for_throughput_test) < 25-1 then
                    counter_for_throughput_test <= std_logic_vector(unsigned(counter_for_throughput_test) + 1);
                    fifo_wr_en <= '0';
                else
                    counter_for_throughput_test <= (others => '0');
                    if bWritesEnabled = '1' then
                        data_counter_for_throughput_test <= std_logic_vector(unsigned(data_counter_for_throughput_test) + 1);
                    else
                        data_counter_for_throughput_test <= (others => '0');
                    end if;
                    fifo_wr_en <= bWritesEnabled;
                end if;
                
            end if;



            -- running max of the data count:
            if fifo_srst = '1' then
                fifo_data_count_max <= (others => '0');
            else
                if unsigned(fifo_data_count) > unsigned(fifo_data_count_max) then
                    fifo_data_count_max <= fifo_data_count;
                end if;
            end if;

            -- delay line from sys_ren (at the right address) to sys_ack which matches the read latency
            if sys_ren = '1' and sys_addr(20-1 downto 0) = x"00039" then
                fifo_rd_en <= '1';
            else
                fifo_rd_en <= '0';
            end if;
            fifo_rd_en_d1 <= fifo_rd_en;

        end if;
    end process;

    -----------------------------------------
    -- registers

    ibus_manager : process (clk) is
        variable sys_en : std_logic := '0';
    begin
        if rising_edge(clk) then
            sys_err <= '0';
            sys_en := sys_wen or sys_ren;
            

            -- Write
            if sys_wen = '1' then
                case sys_addr(20-1 downto 0) is
                    when x"00041" => bWritesEnabled   <= sys_wdata(0);
                    when x"00042" => fifo_srst        <= sys_wdata(0);

                    when others => 
                end case;
            end if;

            -- this is for a throughput test, a simple counter at 100 MHz
            --counter_for_throughput_test <= std_logic_vector(unsigned(counter_for_throughput_test) + 1);



            -- Read
            -------------------------------------------------------------
            -- Note that the addresses do not follow the Zynq-imposed requirement of falling on 32-bits boundaries,
            -- because it is used inside the DPLL module which has a divide by four compared to the Zynq addresses.
            -- This is to allow re-using the same addresses as the legacy code (avoids changing every address manually)
            if sys_ren = '1' then
                case sys_addr(20-1 downto 0) is

                    when x"00025" =>
                        sys_rdata <= status_flags;
                        sys_ack   <= sys_en;

                    -- these two should always be read sequentially, in this order, so that we sample all bits at exactly the same time
                    when x"00026" =>
                        sys_rdata <= dither0_lockin_output(32-1 downto 0);
                        dither0_lockin_output_reg <= dither0_lockin_output;
                        sys_ack                   <= sys_en;
                    when x"00027" =>
                        sys_rdata <= dither0_lockin_output_reg(32+32-1 downto 32);               -- dither0_lockin_output MSB
                        sys_ack   <= sys_en;

                    -- these two should always be read sequentially, in this order, so that we sample all bits at exactly the same time
                    when x"00029" =>
                        sys_rdata                 <= dither1_lockin_output(32-1 downto 0);
                        dither1_lockin_output_reg <= dither1_lockin_output;
                        sys_ack                   <= sys_en;
                    when x"0002A" =>
                        sys_rdata <= dither1_lockin_output_reg(32+32-1 downto 32);                -- dither1_lockin_output MSB
                        sys_ack   <= sys_en;

                    -- we sample all five next signals when we read at this address:
                    when x"00030" =>                                                       -- zdtc_samples_number_counter
                        sys_rdata           <= zdtc_samples_number_counter;
                        counter0_out_reg    <= counter0_out;
                        counter1_out_reg    <= counter1_out;
                        DAC0_out_reg        <= DAC0_out;
                        DAC1_out_reg        <= DAC1_out;
                        DAC2_out_reg        <= DAC2_out;
                        sys_ack             <= sys_en;

                    when x"00031" => sys_ack <= sys_en; sys_rdata <= counter0_out_reg(32-1    downto  0);     -- counter 0 LSBs
                    when x"00032" => sys_ack <= sys_en; sys_rdata <= counter0_out_reg(32+32-1 downto 32);     -- counter 0 MSBs
                    when x"00033" => sys_ack <= sys_en; sys_rdata <= counter1_out_reg(32-1    downto  0);     -- counter 1 LSBs
                    when x"00034" => sys_ack <= sys_en; sys_rdata <= counter1_out_reg(32+32-1 downto 32);     -- counter 1 MSBs
                    when x"00035" => sys_ack <= sys_en; sys_rdata <= DAC0_out_reg(32-1 downto 0);             -- DAC 0
                    when x"00036" => sys_ack <= sys_en; sys_rdata <= DAC1_out_reg(32-1 downto 0);             -- DAC 1
                    when x"00037" => sys_ack <= sys_en; sys_rdata <= DAC2_out_reg(32-1 downto 0);             -- DAC 2


                    --when x"00037" => sys_ack <= sys_en; sys_rdata <= counter_for_throughput_test;             -- this is for a throughput test, a simple counter at 100 MHz

                    -- FIFO addresses
                    when x"00038" => sys_ack <= sys_en;     sys_rdata <= std_logic_vector(to_unsigned(0, 31)) &  fifo_prog_empty;             -- fifo has at least 10 samples to be read?
                    --when x"00039" => sys_ack <= fifo_rd_en_d1; sys_rdata <= fifo_dout;             -- fifo read
                    when x"00039" => sys_ack <= sys_en; sys_rdata <= fifo_dout;             -- fifo read

                    when x"00040" => sys_ack <= sys_en;     sys_rdata <= std_logic_vector(resize(unsigned(fifo_data_count_max), 32));             -- max of fifo data_count

                    when others   => sys_ack <= sys_en;     sys_rdata <=  (others => '0');
                end case;
            else
                sys_ack <= sys_en;
            end if;

        end if;
    end process;

end;
