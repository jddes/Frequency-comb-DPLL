library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


entity new_vhdl_module is
Generic (
    N_BITS_PER_TRANSFER : integer := 16;
    CLK_DIV : integer := 7;	-- needs to be equal to ceil(system clock/SPI clock/2)
    GENERIC3 : integer := 64
);
port (
    clk   : in  std_logic



    );
end entity;

architecture Behavioral of new_vhdl_module is

    type state_type is (STATE_IDLE, STATE_POS_OFFSET, STATE_ZERO1, STATE_NEG_OFFSET, STATE_ZERO2);
    signal FSM_state : state_type := STATE_IDLE;

    signal DATA_SRL : std_logic_vector(N_BITS_PER_TRANSFER-1 downto 0) := (others => '0');
    signal DATA_SRL : std_logic_vector(N_BITS_PER_TRANSFER-1 downto 0) := (others => '0');

begin

    -- FSM process example
    process (clk)
    begin
        if rising_edge(clk) then
            case FSM_state is
                when STATE_IDLE =>
                when others =>
                    FSM_state <= STATE_IDLE;
            end case;
        end if;
    end process;

end;
