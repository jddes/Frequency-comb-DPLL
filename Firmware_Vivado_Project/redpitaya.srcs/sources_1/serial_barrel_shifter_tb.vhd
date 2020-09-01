library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

library work;
use work.maths_helper.all;

entity serial_barrel_shifter_tb is
end serial_barrel_shifter_tb;

architecture behavior of serial_barrel_shifter_tb is

    -- serial_barrel_shifter signals
    -- Generics as constants
    constant INPUT_WIDTH  : integer := 8;
    constant OUTPUT_WIDTH : integer := 14;
    constant MAX_SHIFT    : integer := 20;
    -- Inputs
    signal clk              : std_logic                                     := '0';
    signal input_clk_enable : std_logic                                     := '0';
    signal data_in          : std_logic_vector(INPUT_WIDTH-1 downto 0)      := (others => '0');
    signal shift_amount     : std_logic_vector(clog2(MAX_SHIFT)-1 downto 0) := (others => '0');
    -- Outputs
    signal output_clk_enable : std_logic;
    signal data_out          : std_logic_vector(OUTPUT_WIDTH-1 downto 0);

    -- testbench signals
    signal expected          : signed(OUTPUT_WIDTH-1 downto 0);
    signal value_error       : std_logic := '0';
    -- Clock period definition
    constant clk_period : time := 5 ns;
begin

    -- Unit under test
    serial_barrel_shifter_inst : entity work.serial_barrel_shifter
    generic map (
        INPUT_WIDTH  => INPUT_WIDTH,
        OUTPUT_WIDTH => OUTPUT_WIDTH,
        MAX_SHIFT    => MAX_SHIFT
    ) port map (
        clk               => clk,
        input_clk_enable  => input_clk_enable,
        data_in           => data_in,
        shift_amount      => shift_amount,
        output_clk_enable => output_clk_enable,
        data_out          => data_out
    );

    -- Clock process definition for "clk"
    process
    begin
        clk <= '0';
        wait for clk_period/2;
        clk <= '1';
        wait for clk_period/2;
    end process;

    -- Stimulus process
    process
    begin
        wait for clk_period*10;
        wait until rising_edge(clk);
        

        -- Exhaustive check:
        for I in 0 to 2**INPUT_WIDTH-1 loop
            for I2 in 0 to MAX_SHIFT loop
                wait until rising_edge(clk);
                    input_clk_enable <= '1';
                    data_in <= std_logic_vector(to_signed(I, data_in'length));
                    shift_amount <= std_logic_vector(to_unsigned(I2, shift_amount'length));
                wait until rising_edge(clk);
                    input_clk_enable <= '0';
                    expected <= saturate(shift_left(
                                        resize(signed(data_in), 32), -- make this bigger so we hold all the possible values without overflow until we can saturate the result
                                                to_integer(unsigned(shift_amount))),
                                                    data_out'length);
                wait until output_clk_enable = '1';
                    if signed(data_out) /= expected then
                        value_error <= '1';
                    else
                        value_error <= '0';
                    end if;
            end loop;

        end loop;
        wait;


    end process;
    
end;
