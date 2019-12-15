library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity running_median_testbench is
end running_median_testbench;

architecture behavior of running_median_testbench is
    constant DATA_WIDTH    : integer := 16;
    --constant COUNTER_WIDTH : integer := 32; -- sets the max number of points between assertions of dump_results

    -- Inputs
    signal clk          : std_logic := '0';
    signal clk_enable   : std_logic := '0';
    signal data         : std_logic_vector(data_width-1 downto 0) := (others => '0');
    signal dump_results : std_logic := '0';
    
    -- Outputs
    signal median_estimate : std_logic_vector(data_width-1 downto 0);
    signal min_value       : std_logic_vector(data_width-1 downto 0);
    signal max_value       : std_logic_vector(data_width-1 downto 0);


    
    -- Clock period definition
    constant clk_period : time := 5 ns;
begin

    -- Unit under test
    running_median_inst : entity work.running_median
    generic map (
        DATA_WIDTH => DATA_WIDTH
    ) port map (
        clk             => clk,
        clk_enable      => clk_enable,
        data            => data,
        dump_results    => dump_results,
        median_estimate => median_estimate
    );

    running_minmax_inst : entity work.running_minmax
    generic map (
        DATA_WIDTH => DATA_WIDTH
    ) port map (
        clk             => clk,
        clk_enable      => clk_enable,
        data            => data,
        dump_results    => dump_results,
        min_value       => min_value,
        max_value       => max_value
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
        

        -- Example of a for loop:
        for I2 in 0 to 1023 loop
            for I in 0 to 1023 loop
                wait until rising_edge(clk);
                    clk_enable <= '1';
                    if I = 200 then
                        data <= std_logic_vector(to_unsigned(16000, 16));
                    else
                        data <= std_logic_vector(resize(unsigned(data(10-1 downto 0)) + 1, 16));
                    end if;
                wait until rising_edge(clk);
                    clk_enable <= '0';
                wait until rising_edge(clk);
                    clk_enable <= '0';
            end loop;
            wait until rising_edge(clk);
                dump_results <= '1';
            wait until rising_edge(clk);
                dump_results <= '0';
        end loop;

        wait;

    end process;
    
end;
