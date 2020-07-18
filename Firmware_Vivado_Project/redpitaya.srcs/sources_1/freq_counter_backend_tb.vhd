library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

entity freq_counter_backend_tb is
end freq_counter_backend_tb;

architecture behavior of freq_counter_backend_tb is

    -- freq_counter_backend signals
    -- Generics as constants
    constant INPUT_WIDTH     : integer := 16;
    constant UNWRAPPED_WIDTH : integer := 64;
    constant LOGGER_WIDTH    : integer := 32;
    constant COUNTER_WIDTH   : integer := 32;
    type two_dim_array is array (natural range <>, natural range <>) of std_logic;
    -- Inputs
    signal clk               : std_logic                                  := '0';
    signal clk_enable_in     : std_logic                                  := '0';
    signal wrapped_phase_in1 : std_logic_vector(INPUT_WIDTH-1 downto 0)   := x"1111";
    signal wrapped_phase_in2 : std_logic_vector(INPUT_WIDTH-1 downto 0)   := x"2222";
    signal wrapped_phase_in3 : std_logic_vector(INPUT_WIDTH-1 downto 0)   := x"3333";
    signal wrapped_phase_in4 : std_logic_vector(INPUT_WIDTH-1 downto 0)   := x"4444";
    signal n_cycles          : std_logic_vector(COUNTER_WIDTH-1 downto 0) := std_logic_vector(to_unsigned(16, COUNTER_WIDTH));
    signal sys_addr          : std_logic_vector(32-1 downto 0)            := (others => '0');
    signal sys_wdata         : std_logic_vector(32-1 downto 0)            := (others => '0');
    signal sys_wen           : std_logic                                  := '0';
    signal sys_ren           : std_logic                                  := '0';
    -- Outputs
    signal sys_rdata : std_logic_vector(32-1 downto 0);
    signal sys_err   : std_logic;
    signal sys_ack   : std_logic;

    -- testbench signals
    signal counter : unsigned(32-1 downto 0) := (others => '0');

    -- Clock period definition
    constant clk_period : time := 5 ns;
begin

    -- Unit under test
    freq_counter_backend_inst : entity work.freq_counter_backend
    generic map (
        INPUT_WIDTH   => INPUT_WIDTH,
        LOGGER_WIDTH => LOGGER_WIDTH,
        COUNTER_WIDTH => COUNTER_WIDTH
    ) port map (
        clk               => clk,
        clk_enable_in     => clk_enable_in,
        wrapped_phase_in1 => wrapped_phase_in1,
        wrapped_phase_in2 => wrapped_phase_in2,
        wrapped_phase_in3 => wrapped_phase_in3,
        wrapped_phase_in4 => wrapped_phase_in4,
        n_cycles          => n_cycles,
        sys_addr          => sys_addr,
        sys_wdata         => sys_wdata,
        sys_wen           => sys_wen,
        sys_ren           => sys_ren,
        sys_rdata         => sys_rdata,
        sys_err           => sys_err,
        sys_ack           => sys_ack
    );

    -- Clock process definition for "clk"
    process
    begin
        clk <= '0';
        wait for clk_period/2;
        clk <= '1';
        wait for clk_period/2;
    end process;

-- generate clk enables (much faster than the actual code will use, to make the simulation quicker)
process( clk )
begin
    if rising_edge(clk) then
        if counter < 10-1 then
            counter <= counter + 1;
            clk_enable_in <= '0';
        else
            counter <= (others => '0');
            clk_enable_in <= '1';
        end if;
    end if;
end process;

    -- Stimulus process
    process
    begin
        wait for clk_period*100;
        wait until rising_edge(clk);

        -- start the ram writing process
        wait until rising_edge(clk);
            sys_wen <= '1';
            sys_addr <= x"0000_0041"; -- start_write
            sys_wdata <= std_logic_vector(to_unsigned(1, 32)); -- start_write
        wait until rising_edge(clk);
            sys_wen <= '1';
            sys_addr <= x"0000_0041"; -- start_write
            sys_wdata <= std_logic_vector(to_unsigned(0, 32)); -- start_write
        wait until rising_edge(clk);
            sys_wen <= '0';
        wait for clk_period*16*10*100; -- wait for 100 pts written in ram

        -- drive the read port
        wait until rising_edge(clk);
            sys_wen <= '1';
            sys_addr <= x"0000_0042"; -- start_read
        wait until rising_edge(clk);
            sys_wen <= '0';

        
        for I in 0 to 1023 loop
            wait until rising_edge(clk);
                sys_ren <= '1';
                sys_addr <= x"0000_0044"; -- read_data
            wait until rising_edge(clk);
                sys_ren <= '0';
            wait for clk_period*5;
        end loop;

        wait;


    end process;
    
end;
