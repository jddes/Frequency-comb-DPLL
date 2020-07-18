library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

entity phase_unwrapper_tb is
end phase_unwrapper_tb;

architecture behavior of phase_unwrapper_tb is

    -- phase_unwrapper signals
    -- Generics as constants
    constant INPUT_WIDTH  : integer := 6;
    constant OUTPUT_WIDTH : integer := 13;
    type two_dim_array is array (natural range <>, natural range <>) of std_logic;
    -- Inputs
    signal clk              : std_logic                                := '0';
    signal clk_enable_in    : std_logic                                := '0';
    signal wrapped_phase_in : std_logic_vector(INPUT_WIDTH-1 downto 0) := (others => '0');
    -- Outputs
    signal clk_enable_out      : std_logic;
    signal unwrapped_phase_out : std_logic_vector(OUTPUT_WIDTH-1 downto 0);

    -- testbenches signals:
    signal unwrapped_phase_in : signed(OUTPUT_WIDTH-1 downto 0) := (others => '0');
    signal unwrapped_phase_in_d1 : signed(OUTPUT_WIDTH-1 downto 0) := (others => '0');
    signal unwrapped_phase_in_d2 : signed(OUTPUT_WIDTH-1 downto 0) := (others => '0');
    signal error_int : signed(OUTPUT_WIDTH-1 downto 0) := (others => '0');

    signal error_clk_enable : std_logic := '0';

    -- Clock period definition
    constant clk_period : time := 5 ns;
begin

    -- Unit under test
    phase_unwrapper_inst : entity work.phase_unwrapper
    generic map (
        INPUT_WIDTH  => INPUT_WIDTH,
        OUTPUT_WIDTH => OUTPUT_WIDTH
    ) port map (
        clk                 => clk,
        clk_enable_in       => clk_enable_in,
        wrapped_phase_in    => wrapped_phase_in,
        clk_enable_out      => clk_enable_out,
        unwrapped_phase_out => unwrapped_phase_out
    );
    wrapped_phase_in <= std_logic_vector(unwrapped_phase_in(wrapped_phase_in'range));

    -- Clock process definition for "clk"
    process
    begin
        clk <= '0';
        wait for clk_period/2;
        clk <= '1';
        wait for clk_period/2;
    end process;

    process( clk )
    begin
        if rising_edge(clk) then
            if clk_enable_in='1' then
                unwrapped_phase_in_d1 <= unwrapped_phase_in;
            end if;
            unwrapped_phase_in_d2 <= unwrapped_phase_in_d1;

            error_clk_enable <= clk_enable_out;
            if clk_enable_out='1' then
                error_int <= signed(unwrapped_phase_out) - unwrapped_phase_in_d2;
            end if;
        end if;
    end process;

    -- Stimulus process
    process
    begin
        wait for clk_period*10;
        wait until rising_edge(clk);

        -- simple ramp over all pts (three times)
        for I in 0 to 3*(2**(OUTPUT_WIDTH)-1) loop
            wait until rising_edge(clk);
                clk_enable_in <= '1';
                unwrapped_phase_in <= to_signed(I, unwrapped_phase_in'length);

        end loop;



        -- simple ramp over all pts (three times), with clk enable pattern
        for I in 0 to 3*(2**(OUTPUT_WIDTH)-1) loop
            wait until rising_edge(clk);
                clk_enable_in <= '1';
                unwrapped_phase_in <= to_signed(I, unwrapped_phase_in'length);
            wait until rising_edge(clk);
                clk_enable_in <= '0';
            wait for clk_period*3;
        end loop;

        wait;


    end process;
    
end;
