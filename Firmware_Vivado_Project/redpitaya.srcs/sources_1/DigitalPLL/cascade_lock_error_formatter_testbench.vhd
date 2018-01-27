library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity cascade_lock_error_formatter_testbench is
end cascade_lock_error_formatter_testbench;

architecture behavior of cascade_lock_error_formatter_testbench is
    constant N_BITS_IN  : integer := 16;
    constant N_BITS_OUT : integer := 10;

    -- Inputs
    signal clk : std_logic := '0';
    signal dac0_in : std_logic_vector(n_bits_in-1 downto 0) := (others => '0');
    signal dac0_lockpoint_in : std_logic_vector(n_bits_in-1 downto 0) := (others => '0');
    
    -- Outputs
    signal error1_out : std_logic_vector(n_bits_out-1 downto 0);
    signal error1_out_expected : std_logic_vector(n_bits_out-1 downto 0) := (others => '0');
    
    
    -- Clock period definition
    constant clk_period : time := 5 ns;
begin

    -- Unit under test
    cascade_lock_error_formatter_inst : entity work.cascade_lock_error_formatter
    port map (
        clk => clk,
        dac0_in => dac0_in,
        dac0_lockpoint_in => dac0_lockpoint_in,
        error1_out => error1_out
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

        -- Test normal operation, output should be 900/2^6 = 14
        wait for clk_period*10;
        wait until rising_edge(clk);
            dac0_in             <= std_logic_vector(to_signed(1000, dac0_in'length));
            dac0_lockpoint_in   <= std_logic_vector(to_signed( 100, dac0_in'length));
        wait until rising_edge(clk);
        wait until rising_edge(clk);
            error1_out_expected <= std_logic_vector(to_signed(  14, error1_out_expected'length));

        -- Test positive limits, smallest number that rails (not quite but the other options will be harder to interpret because of the floor() operation), output should be +511
        wait for clk_period*10;
        wait until rising_edge(clk);
            dac0_in             <= std_logic_vector(to_signed(511*2**6, dac0_in'length));
            dac0_lockpoint_in   <= std_logic_vector(to_signed(      -1, dac0_in'length));
        wait until rising_edge(clk);
        wait until rising_edge(clk);
            error1_out_expected <= std_logic_vector(to_signed(     511, error1_out_expected'length));

        -- Test positive limits, largest input number possible, output should be +511
        wait for clk_period*10;
        wait until rising_edge(clk);
            dac0_in             <= std_logic_vector(to_signed(2**15-1, dac0_in'length));
            dac0_lockpoint_in   <= std_logic_vector(to_signed(-2**15 , dac0_in'length));
        wait until rising_edge(clk);
        wait until rising_edge(clk);
            error1_out_expected <= std_logic_vector(to_signed(    511, error1_out_expected'length));

        -- Test negative limits, smallest magnitude number that rails (not quite but the other options will be harder to interpret because of the floor() operation), output should be -512
        wait for clk_period*10;
        wait until rising_edge(clk);
            dac0_in             <= std_logic_vector(to_signed(-512*2**6, dac0_in'length));
            dac0_lockpoint_in   <= std_logic_vector(to_signed(        1, dac0_in'length));
        wait until rising_edge(clk);
        wait until rising_edge(clk);
            error1_out_expected <= std_logic_vector(to_signed(     -512, error1_out_expected'length));

        -- Test negative limits, largest magnitude number that rails, output should be -512
        wait for clk_period*10;
        wait until rising_edge(clk);
            dac0_in             <= std_logic_vector(to_signed(-2**15, dac0_in'length));
            dac0_lockpoint_in   <= std_logic_vector(to_signed(2**15-1, dac0_in'length));
        wait until rising_edge(clk);
        wait until rising_edge(clk);
            error1_out_expected <= std_logic_vector(to_signed(   -512, error1_out_expected'length));

        wait;


    end process;
    
end;
