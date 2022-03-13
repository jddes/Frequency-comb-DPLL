library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


entity registers_read  is
--Generic (
--	DATA_WIDTH			: integer := 16;
--);
port (
	
    clk                                    : in  std_logic;
    
    -- status registers inputs:
    -- monitors actual clock mode:
    clk_int_or_ext_actual   : in  std_logic;
    clk_int_or_ext_desired  : in  std_logic;
    clk_ext_good            : in  std_logic;

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

    -- results of counting the external clock on exp_p_in[2] = DIN1 vs the adc clock:
    counter_new_data                       : in  std_logic;
    counter_reg_to_dpll                    : in  std_logic_vector(64-1 downto 0);

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
    signal bWritesEnabled : std_logic := '0';

    signal have_counter : std_logic := '0';
    signal counter_read : std_logic := '0';
    signal counter_reg : std_logic_vector(64-1 downto 0) := (others => '0');

    signal loss_of_clk_detected      : std_logic := '0';
    signal loss_of_clk_detected_reg  : std_logic := '0';
    signal loss_of_clk_detected_last : std_logic := '0';

    -- clock-domain crossing registers:
    signal clk_int_or_ext_actual_reg1, clk_int_or_ext_actual_reg2    : std_logic := '0';
    signal clk_int_or_ext_desired_reg1, clk_int_or_ext_desired_reg2  : std_logic := '0';
    signal clk_ext_good_reg1, clk_ext_good_reg2                      : std_logic := '0';

    attribute ASYNC_REG : string;
    attribute ASYNC_REG of clk_int_or_ext_actual_reg1  : signal is "TRUE";
    attribute ASYNC_REG of clk_int_or_ext_actual_reg2  : signal is "TRUE";
    attribute ASYNC_REG of clk_int_or_ext_desired_reg1 : signal is "TRUE";
    attribute ASYNC_REG of clk_int_or_ext_desired_reg2 : signal is "TRUE";
    attribute ASYNC_REG of clk_ext_good_reg1           : signal is "TRUE";
    attribute ASYNC_REG of clk_ext_good_reg2           : signal is "TRUE";
begin

    -- handle counter data,
    process( clk )
    begin
        if rising_edge(clk) then
            if have_counter = '1' then
                -- wait until user has read the value out, simply dropping new values that appear in between
                if counter_read='1' then
                    have_counter <= '0';
                end if;
            else
                -- wait for new data
                if counter_new_data='1' then
                    have_counter <= '1';
                    counter_reg <= counter_reg_to_dpll;
                end if;
            end if;
        end if;
    end process;

    process( clk )
    begin
        if rising_edge(clk) then
            -- clock domain crossing:
            clk_int_or_ext_actual_reg1 <= clk_int_or_ext_actual;
            clk_int_or_ext_actual_reg2 <= clk_int_or_ext_actual_reg1;
            clk_int_or_ext_desired_reg1 <= clk_int_or_ext_desired;
            clk_int_or_ext_desired_reg2 <= clk_int_or_ext_desired_reg1;
            clk_ext_good_reg1 <= clk_ext_good;
            clk_ext_good_reg2 <= clk_ext_good_reg1;
        end if;
    end process;

    -----------------------------------------
    -- registers

    loss_of_clk_detected <= '1' when clk_int_or_ext_desired_reg2 = '0' and clk_int_or_ext_actual_reg2 = '1' else '0';

    ibus_manager : process (clk) is
        variable sys_en : std_logic := '0';
    begin
        if rising_edge(clk) then
            sys_err <= '0';
            sys_en := sys_wen or sys_ren;

            -- defaults:
            counter_read <= '0';

            -- latch loss of ext clock events:
            loss_of_clk_detected_last <= loss_of_clk_detected;
            if loss_of_clk_detected = '1' and loss_of_clk_detected_last = '0' then
                loss_of_clk_detected_reg <= '1';
            end if;

            -- default
            sys_rdata <=  (others => '0');
            

            -- Write
            if sys_wen = '1' then
                case sys_addr(20-1 downto 0) is
                    when x"00041" => bWritesEnabled   <= sys_wdata(0);

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

                    -- these three registers are meant to be read sequentially, checking if have_counter='1' first,
                    -- then the last two can be read in sequence.  This guarantees a consistent set of values
                    when x"00041" => sys_ack <= sys_en; sys_rdata <= (others => '0'); sys_rdata(0) <= have_counter;
                    when x"00042" => sys_ack <= sys_en; sys_rdata <= counter_reg(32-1    downto  0);
                    when x"00043" => sys_ack <= sys_en; sys_rdata <= counter_reg(32+32-1 downto 32); counter_read <= '1';
                    when x"00046" => sys_ack <= sys_en; sys_rdata(4-1 downto 0) <= (loss_of_clk_detected_reg & clk_ext_good_reg2 & clk_int_or_ext_actual_reg2 & clk_int_or_ext_desired_reg2); loss_of_clk_detected_reg <= '0';

                    when others   => sys_ack <= sys_en; sys_rdata <=  (others => '0');
                end case;
            else
                sys_ack <= sys_en;
            end if;

        end if;
    end process;

end;
