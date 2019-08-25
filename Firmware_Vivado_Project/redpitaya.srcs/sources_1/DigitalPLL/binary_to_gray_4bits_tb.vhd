library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity binary_to_gray_4bits_tb is
end binary_to_gray_4bits_tb;

architecture behavior of binary_to_gray_4bits_tb is

    -- binary_to_gray_4bits signals
    -- Generics as constants
    
    -- Inputs
    signal clk     : std_logic                      := '0';
    signal data_in : std_logic_vector(4-1 downto 0) := (others => '0');
    -- Outputs
    signal data_out        : std_logic_vector(4-1 downto 0);
    signal data_out_binary : std_logic_vector(4-1 downto 0);
    signal data_in_d1      : std_logic_vector(4-1 downto 0) := (others => '0');
    signal data_in_d2      : std_logic_vector(4-1 downto 0) := (others => '0');
    

    -- testbench signals:
    signal data_out_d1      : std_logic_vector(4-1 downto 0) := (others => '0');
    signal data_diff        : std_logic_vector(4-1 downto 0) := (others => '0');
    signal hamming_distance :        unsigned(16-1 downto 0) := (others => '0');

    signal hamming_distance_is_one    : std_logic := '0';
    signal mapping_inverted_correctly : std_logic := '0';

    -- Clock period definition
    constant clk_period : time := 5 ns;
begin

    -- Unit under test
    binary_to_gray_4bits_inst : entity work.binary_to_gray_4bits
    port map (
        clk      => clk,
        data_in  => data_in,
        data_out => data_out
    );

    -- go through the reverse conversion:
    gray_to_binary_4bits_inst : entity work.gray_to_binary_4bits
    port map (
        clk      => clk,
        data_in  => data_out,
        data_out => data_out_binary
    );


    -- Clock process definition for "clk"
    process
    begin
        clk <= '0';
        wait for clk_period/2;
        clk <= '1';
        wait for clk_period/2;
    end process;

    -- just loop through all values:
    process( clk )
    begin
        if rising_edge(clk) then
            data_in <= std_logic_vector(unsigned(data_in) + 1);

            -- check that adjacent outputs different by one and only one bit:
            data_out_d1 <= data_out;

            -- check that the binary->gray -> binary conversion yields no change in values:
            data_in_d1 <= data_in;
            data_in_d2 <= data_in_d1;
        end if;
    end process;
 
    data_diff <= data_out xor data_out_d1;
    hamming_distance <= resize(unsigned(data_diff(0 downto 0)), 16) + 
                        resize(unsigned(data_diff(1 downto 1)), 16) + 
                        resize(unsigned(data_diff(2 downto 2)), 16) + 
                        resize(unsigned(data_diff(3 downto 3)), 16);

    hamming_distance_is_one <=      '1' when hamming_distance = to_unsigned(1, hamming_distance'length)
                               else '0';
    mapping_inverted_correctly <=   '1' when data_in_d2 = data_out_binary
                               else '0';

end;
