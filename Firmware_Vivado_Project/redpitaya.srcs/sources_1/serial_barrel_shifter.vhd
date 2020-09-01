library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.maths_helper.all;

-- computes data_out = data_in * 2^shift_amount,
-- via sequential shifts by 1 bits,
-- latency is max_shift+1
-- thus the max throughput is clk/(max_shift+1)
-- output will saturate instead of overflowing

entity serial_barrel_shifter is
Generic (
    INPUT_WIDTH  : integer := 16;
    OUTPUT_WIDTH : integer := 48;
    MAX_SHIFT    : integer := 48
);
port (
    clk               : in  std_logic;
    input_clk_enable  : in  std_logic;
    data_in           : in  std_logic_vector(INPUT_WIDTH-1 downto 0); -- signed
    shift_amount      : in  std_logic_vector(clog2(MAX_SHIFT)-1 downto 0);
    
    output_clk_enable : out std_logic;
    railed_high       : out std_logic;
    railed_low        : out std_logic;
    data_out          : out std_logic_vector(OUTPUT_WIDTH-1 downto 0) -- signed
    );
end entity;

architecture Behavioral of serial_barrel_shifter is

    signal shift_counter : unsigned(clog2(MAX_SHIFT)-1 downto 0) := (others => '0');
    signal reg : signed(OUTPUT_WIDTH-1 downto 0) := (others => '0');

    type state_type is (STATE_IDLE, STATE_DECISION, STATE_SHIFTING, STATE_NEG_OFFSET, STATE_ZERO2);
    signal FSM_state      : state_type := STATE_IDLE;

    signal need_shift            : std_logic := '0';
    signal can_shift             : std_logic := '0';
    signal output_clk_enable_int : std_logic := '0';

    signal railed_high_int        : std_logic := '0';
    signal railed_low_int         : std_logic := '0';
begin

    -- flags just for readability
    -- shifting is allowed IIF shifting would not change the sign bit:
    can_shift <= '1' when reg(reg'left) = reg(reg'left-1)
                 else '0';
    need_shift <= '1' when shift_counter < unsigned(shift_amount)
                 else '0';

    -- FSM process
    process (clk)
    begin
        if rising_edge(clk) then
            output_clk_enable_int <= '0';
            
            case FSM_state is
                when STATE_IDLE =>
                    shift_counter <= (others => '0');
                    if input_clk_enable = '1' then
                        reg             <= resize(signed(data_in), reg'length);
                        FSM_state       <= STATE_SHIFTING;
                        railed_high_int <= '0';
                        railed_low_int  <= '0';
                    end if;

                when STATE_SHIFTING =>
                    if need_shift = '1' then
                        if can_shift = '1' then
                            reg <= shift_left(reg, 1);
                        else
                            -- if we can't shift but want to, this means that we should saturate to either rail:
                            if reg < 0 then
                                reg <= min_int(reg'length); -- saturated low
                                railed_low_int <= '1';
                            else
                                reg <= max_int(reg'length); -- saturated high
                                railed_high_int <= '1';
                            end if;
                        end if;
                        
                    end if;
                    shift_counter <= shift_counter + 1;
                    if shift_counter = max_shift-1 then
                        FSM_state <= STATE_IDLE;
                        output_clk_enable_int <= '1';
                    end if;

                when others =>
                    FSM_state <= STATE_IDLE;
            end case;
        end if;
    end process;

    output_clk_enable <= output_clk_enable_int;
    railed_high       <= railed_high_int;
    railed_low        <= railed_low_int;
    data_out          <= std_logic_vector(reg);

end;
