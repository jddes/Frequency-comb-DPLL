library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- Four-bits gray-to-binary code conversion
-- one cycle of latency from input to output
-- code is taken from wikipedia: https://en.wikipedia.org/wiki/Gray_code
entity gray_to_binary_4bits  is
port (
    clk : in  std_logic;

    data_in  : in  std_logic_vector(4-1 downto 0);
    data_out : out std_logic_vector(4-1 downto 0)

    );
end entity;

architecture Behavioral of gray_to_binary_4bits is

    signal data_out_reg : std_logic_vector(4-1 downto 0) := (others => '0');

begin
--Decimal Binary  Gray
--0   0000    0000
--1   0001    0001
--2   0010    0011
--3   0011    0010
--4   0100    0110
--5   0101    0111
--6   0110    0101
--7   0111    0100
--8   1000    1100
--9   1001    1101
--10  1010    1111
--11  1011    1110
--12  1100    1010
--13  1101    1011
--14  1110    1001
--15  1111    1000

    process (clk)
    begin
        if rising_edge(clk) then
            case data_in is
                when b"0000" => data_out_reg <= b"0000";
                when b"0001" => data_out_reg <= b"0001";
                when b"0011" => data_out_reg <= b"0010";
                when b"0010" => data_out_reg <= b"0011";
                when b"0110" => data_out_reg <= b"0100";
                when b"0111" => data_out_reg <= b"0101";
                when b"0101" => data_out_reg <= b"0110";
                when b"0100" => data_out_reg <= b"0111";
                when b"1100" => data_out_reg <= b"1000";
                when b"1101" => data_out_reg <= b"1001";
                when b"1111" => data_out_reg <= b"1010";
                when b"1110" => data_out_reg <= b"1011";
                when b"1010" => data_out_reg <= b"1100";
                when b"1011" => data_out_reg <= b"1101";
                when b"1001" => data_out_reg <= b"1110";
                when b"1000" => data_out_reg <= b"1111";
                when others  => data_out_reg <= b"0000"; -- this seems required even though all numeric values are covered, probably to account for X's, U's etc (in simulation only)
            end case;
        end if;
    end process;

    data_out <= data_out_reg;
end;
