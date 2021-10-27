library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- super simple module, just used for scaling from inst_frequency1 (10 bits) to to_vco0_frequency (48 bits),
-- because I hate Verilog's loose arithmetic syntax rules.
-- 1 clk cycle of latency
entity vco_freq_scaling is
Generic (
    INPUT_WIDTH  : integer := 10;
    OUTPUT_WIDTH : integer := 48
);
port (
    clk      : in  std_logic;
    data_in  : in  std_logic_vector(INPUT_WIDTH-1 downto 0);
    data_out : out std_logic_vector(OUTPUT_WIDTH-1 downto 0)
    );
end entity;

architecture Behavioral of vco_freq_scaling is

    --type state_type is (STATE_IDLE, STATE_POS_OFFSET, STATE_ZERO1, STATE_NEG_OFFSET, STATE_ZERO2);
    --signal FSM_state      : state_type := STATE_IDLE;

    signal data_out_reg : signed(data_out'length-1 downto 0) := (others => '0');
begin

    process( clk )
    begin
        if rising_edge(clk) then
            data_out_reg <= shift_left(resize(signed(data_in), OUTPUT_WIDTH), OUTPUT_WIDTH-INPUT_WIDTH);
        end if;
    end process;

    data_out <= std_logic_vector(data_out_reg);

    ---- FSM process example
    --process (clk)
    --begin
    --  if rising_edge(clk) then
    --      case FSM_state is
    --          when STATE_IDLE =>
    --          when others =>
    --              FSM_state <= STATE_IDLE;
    --      end case;
    --  end if;
    --end process;

end;
