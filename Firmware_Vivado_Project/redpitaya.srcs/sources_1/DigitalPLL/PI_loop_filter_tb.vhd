library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

entity PI_loop_filter_tb is
end PI_loop_filter_tb;

architecture behavior of PI_loop_filter_tb is

    -- PI_loop_filter signals
    -- Generics as constants
    constant INPUT_WIDTH  : integer := 18;
    constant OUTPUT_WIDTH : integer := 48;
    -- Inputs
    signal clk                : std_logic                                := '0';
    signal input_clk_enable   : std_logic                                := '0';
    signal unwrapped_phase_in : std_logic_vector(INPUT_WIDTH-1 downto 0) := (others => '0');
    signal gain_fine          : std_logic_vector(4-1 downto 0)           := (others => '0');
    signal P_gain_coarse      : std_logic_vector(6-1 downto 0)           := (others => '0');
    signal I_gain_coarse      : std_logic_vector(6-1 downto 0)           := (others => '0');
    signal railed_high        : std_logic                                := '0';
    signal railed_low         : std_logic                                := '0';
    signal P_enable           : std_logic                                := '0';
    signal I_enable           : std_logic                                := '0';
    -- Outputs
    signal output_clk_enable : std_logic;
    signal data_out          : std_logic_vector(OUTPUT_WIDTH-1 downto 0);

    -- Clock period definition
    constant clk_period : time := 5 ns;
begin

    -- Unit under test
    PI_loop_filter_inst : entity work.PI_loop_filter
    generic map (
        INPUT_WIDTH  => INPUT_WIDTH,
        OUTPUT_WIDTH => OUTPUT_WIDTH
    ) port map (
        clk                => clk,
        input_clk_enable   => input_clk_enable,
        unwrapped_phase_in => unwrapped_phase_in,
        gain_fine          => gain_fine,
        P_gain_coarse      => P_gain_coarse,
        I_gain_coarse      => I_gain_coarse,
        P_enable           => P_enable,
        I_enable           => I_enable,
        railed_high        => railed_high,
        railed_low         => railed_low,
        output_clk_enable  => output_clk_enable,
        data_out           => data_out
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
        -- 1. Open-loop, P gain only, step input
        wait until rising_edge(clk);
            gain_fine     <= std_logic_vector(to_signed(1, gain_fine'length));
            P_gain_coarse <= std_logic_vector(to_unsigned(1, P_gain_coarse'length));
            I_gain_coarse <= std_logic_vector(to_unsigned(1, I_gain_coarse'length));
            P_enable      <= '1';
            I_enable      <= '0';
        wait for clk_period*20;


        for I in 0 to 10 loop
            wait until rising_edge(clk);
                input_clk_enable <= '1';
                unwrapped_phase_in <= std_logic_vector(to_signed(1000, unwrapped_phase_in'length));
            wait until rising_edge(clk);
                input_clk_enable <= '0';
            wait for clk_period*100;
        end loop;
        -- 1.5: test negative fine gain:
        wait until rising_edge(clk);
            gain_fine     <= std_logic_vector(to_signed(-1, gain_fine'length));
        wait for clk_period*20;
        for I in 0 to 10 loop
            wait until rising_edge(clk);
                input_clk_enable <= '1';
                unwrapped_phase_in <= std_logic_vector(to_signed(1000, unwrapped_phase_in'length));
            wait until rising_edge(clk);
                input_clk_enable <= '0';
            wait for clk_period*100;
        end loop;

        -- go back to 0:
        wait until rising_edge(clk);
            input_clk_enable <= '1';
            unwrapped_phase_in <= std_logic_vector(to_signed(1000, unwrapped_phase_in'length));
        wait until rising_edge(clk);
            input_clk_enable <= '0';
        wait for clk_period*100;

        -- 2. Open-loop, I gain only, step input
        wait until rising_edge(clk);
            gain_fine     <= std_logic_vector(to_signed(1, gain_fine'length));
            P_gain_coarse <= std_logic_vector(to_unsigned(1, P_gain_coarse'length));
            I_gain_coarse <= std_logic_vector(to_unsigned(0, I_gain_coarse'length));
            P_enable      <= '0';
            I_enable      <= '1';
        wait for clk_period*20;

        for I in 0 to 100 loop
            wait until rising_edge(clk);
                input_clk_enable <= '1';
                unwrapped_phase_in <= std_logic_vector(to_signed(1000, unwrapped_phase_in'length));
            wait until rising_edge(clk);
                input_clk_enable <= '0';
            wait for clk_period*100;
        end loop;


        -- 3. Test saturation from P branch: ramp input. Input will wrap around
        wait until rising_edge(clk);
            gain_fine     <= std_logic_vector(to_signed(1, gain_fine'length));
            P_gain_coarse <= std_logic_vector(to_unsigned(32, P_gain_coarse'length));
            I_gain_coarse <= std_logic_vector(to_unsigned(1, I_gain_coarse'length));
            P_enable      <= '1';
            I_enable      <= '0';
        wait for clk_period*20;
        for I in 0 to 1023 loop
            wait until rising_edge(clk);
                input_clk_enable <= '1';
                unwrapped_phase_in <= std_logic_vector(signed(unwrapped_phase_in) + to_signed(1000, unwrapped_phase_in'length));
            wait until rising_edge(clk);
                input_clk_enable <= '0';
            wait for clk_period*100;
        end loop;

        -- go back to 0:
        wait until rising_edge(clk);
            input_clk_enable <= '1';
            unwrapped_phase_in <= std_logic_vector(to_signed(1000, unwrapped_phase_in'length));
        wait until rising_edge(clk);
            input_clk_enable <= '0';
        wait for clk_period*100;


        -- 3. Test saturation from I branch: constant positive input, then constant negative input
        wait until rising_edge(clk);
            gain_fine     <= std_logic_vector(to_signed(1, gain_fine'length));
            P_gain_coarse <= std_logic_vector(to_unsigned(0, P_gain_coarse'length));
            I_gain_coarse <= std_logic_vector(to_unsigned(25, I_gain_coarse'length));
            P_enable      <= '0';
            I_enable      <= '1';
        wait for clk_period*20;
        for I in 0 to 1023 loop
            wait until rising_edge(clk);
                input_clk_enable <= '1';
                unwrapped_phase_in <= std_logic_vector(to_signed(100000, unwrapped_phase_in'length));
            wait until rising_edge(clk);
                input_clk_enable <= '0';
            wait for clk_period*100;
        end loop;
        -- negative input
        for I in 0 to 1023 loop
            wait until rising_edge(clk);
                input_clk_enable <= '1';
                unwrapped_phase_in <= std_logic_vector(to_signed(-100000, unwrapped_phase_in'length));
            wait until rising_edge(clk);
                input_clk_enable <= '0';
            wait for clk_period*100;
        end loop;

        -- test handling of external saturation flags
        -- use I term only, since that is easier, making sure that the PI itself doesn't saturate
        -- just put a constant positive input, then toggle saturation flags
        -- then switch to negative input
        -- first reset the integrator:
        wait until rising_edge(clk);
            gain_fine     <= std_logic_vector(to_signed(1, gain_fine'length));
            P_gain_coarse <= std_logic_vector(to_unsigned(0, P_gain_coarse'length));
            I_gain_coarse <= std_logic_vector(to_unsigned(6, I_gain_coarse'length));
            P_enable      <= '0';
            I_enable      <= '1';
        wait for clk_period*100;
        -- positive input
        for I in 0 to 1023 loop
            wait until rising_edge(clk);
                input_clk_enable <= '1';
                unwrapped_phase_in <= std_logic_vector(to_signed(1000, unwrapped_phase_in'length));
                if I mod 10 < 3 then
                    railed_high <= '1';
                    railed_low  <= '0';
                elsif I mod 10 < 6 then
                    railed_high <= '0';
                    railed_low  <= '1';
                else
                    railed_high <= '1';
                    railed_low  <= '1';
                end if;
            wait until rising_edge(clk);
                input_clk_enable <= '0';
            wait for clk_period*100;
        end loop;
        -- negative input
        for I in 0 to 1023 loop
            wait until rising_edge(clk);
                input_clk_enable <= '1';
                unwrapped_phase_in <= std_logic_vector(to_signed(-1000, unwrapped_phase_in'length));
                if I mod 10 < 3 then
                    railed_high <= '1';
                    railed_low  <= '0';
                elsif I mod 10 < 6 then
                    railed_high <= '0';
                    railed_low  <= '1';
                else
                    railed_high <= '1';
                    railed_low  <= '1';
                end if;
            wait until rising_edge(clk);
                input_clk_enable <= '0';
            wait for clk_period*100;
        end loop;

        -- closed-loop test: (...)

        wait;

    end process;
    
end;
