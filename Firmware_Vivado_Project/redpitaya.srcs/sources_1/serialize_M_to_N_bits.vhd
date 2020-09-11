library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- Wrote this to take a 48-bits stream, and output it as a 16-bit stream (3 output words per input words)
entity serialize_M_to_N_bits is
Generic (
    INPUT_WIDTH  : integer := 48; -- can't change this without rewritting the core, unless OUTPUT_WIDTH/INPUT_WIDTH = 3
    OUTPUT_WIDTH : integer := 16 -- can't change this without rewritting the core, unless OUTPUT_WIDTH/INPUT_WIDTH = 3
);
port (
    clk               : in  std_logic;
    
    input_clk_enable  : in  std_logic;
    data_in           : in  std_logic_vector(INPUT_WIDTH-1 downto 0);
    output_clk_enable : out std_logic;
    output_sync       : out std_logic; -- this strobes to indicate the first 16 LSBs
    data_out          : out  std_logic_vector(OUTPUT_WIDTH-1 downto 0)

    );
end entity;

architecture Behavioral of serialize_M_to_N_bits is

    type state_type is (STATE1, STATE2, STATE3);
    signal FSM_state      : state_type := STATE1;
    signal output_sync_int : std_logic := '0';
begin

    process (clk)
    begin
        if rising_edge(clk) then
            output_sync_int <= '0';
            case FSM_state is
                when STATE1 =>
                    data_out <= data_in(OUTPUT_WIDTH-1+OUTPUT_WIDTH*0 downto OUTPUT_WIDTH*0);
                    output_clk_enable <= input_clk_enable;
                    output_sync_int <= input_clk_enable;
                    if input_clk_enable = '1' then
                        FSM_state <= STATE2;
                    end if;
                when STATE2 =>
                    data_out <= data_in(OUTPUT_WIDTH-1+OUTPUT_WIDTH*1 downto OUTPUT_WIDTH*1);
                    output_clk_enable <= '1';
                    FSM_state <= STATE3;
                when STATE3 =>
                    data_out <= data_in(OUTPUT_WIDTH-1+OUTPUT_WIDTH*2 downto OUTPUT_WIDTH*2);
                    output_clk_enable <= '1';
                    FSM_state <= STATE1;
                when others =>
                    FSM_state <= STATE1;
            end case;
        end if;
    end process;

    output_sync <= output_sync_int;
end;
