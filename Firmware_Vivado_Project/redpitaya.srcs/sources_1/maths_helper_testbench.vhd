library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.maths_helper.all;

entity maths_helper_testbench is
end maths_helper_testbench;

architecture behavior of maths_helper_testbench is

    -- Inputs
    signal clk : std_logic := '0';
    signal data_signed_in    : signed(  16-1 downto 0) := (others => '0');
    signal data_unsigned_in  : unsigned(16-1 downto 0) := (others => '0');
    
    -- Outputs
    signal data_signed_out   : signed(  8-1 downto 0) := (others => '0');
    signal data_unsigned_out : unsigned(8-1 downto 0) := (others => '0');
    
    -- Clock period definition
    constant clk_period : time := 5 ns;
begin


    -- Clock process definition for "clk"
    process
    begin
        clk <= '0';
        wait for clk_period/2;
        clk <= '1';
        wait for clk_period/2;
    end process;

    process (clk)
    begin
        if rising_edge(clk) then
            data_signed_in   <= data_signed_in + 1;
            data_unsigned_in <= data_unsigned_in + 1;
        end if;
    end process;

    data_signed_out   <= saturate(data_signed_in, 8);
    data_unsigned_out <= saturate(data_unsigned_in, 8);


    ---- Stimulus process
    --process
    --begin
    --    wait for clk_period*10;
    --    wait until rising_edge(clk);
    --    wait;

    --    -- Example of a for loop:
    --    wait until new_data_available = '1';
    --    for I in 0 to 1023 loop
    --        wait until rising_edge(clk);
    --            read_enable <= '1';
    --        wait until rising_edge(clk);
    --            read_enable <= '0';
    --        wait for clk_period*5;
    --    end loop;
    --end process;
    
end;
