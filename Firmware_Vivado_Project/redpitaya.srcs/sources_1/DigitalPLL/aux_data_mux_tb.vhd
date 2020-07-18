library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

entity aux_data_mux_tb is
end aux_data_mux_tb;

architecture behavior of aux_data_mux_tb is

    -- aux_data_mux signals
    -- Generics as constants
    constant OUTPUT_WIDTH : integer := 16;
    type two_dim_array is array (natural range <>, natural range <>) of std_logic;
    -- Inputs
    signal clk           : std_logic                                 := '0';
    signal write_mode    : std_logic                                 := '0';
    signal clk_enable_in : std_logic                                 := '0';
    signal sync_in       : std_logic                                 := '0';
    signal data_in       : std_logic_vector(OUTPUT_WIDTH-1 downto 0) := (others => '0');
    -- Outputs
    signal clk_enable_out : std_logic;
    signal data_out       : std_logic_vector(OUTPUT_WIDTH-1 downto 0);

    -- ram_data_logger signals
    constant ADDRESS_WIDTH : integer := 8;
    constant DATA_WIDTH    : integer := 16;
    -- Inputs
    signal sys_addr           : std_logic_vector(32-1 downto 0) := (others => '0');
    signal sys_wdata          : std_logic_vector(32-1 downto 0) := (others => '0');
    signal sys_sel            : std_logic_vector(4-1 downto 0)  := (others => '0');
    signal sys_wen            : std_logic                       := '0';
    signal sys_ren            : std_logic                       := '0';
    -- Outputs
    signal sys_rdata  : std_logic_vector(32-1 downto 0);
    signal sys_err    : std_logic;
    signal sys_ack    : std_logic;

    -- Clock period definition
    constant clk_period : time := 5 ns;
begin

    -- Unit under test
    aux_data_mux_inst : entity work.aux_data_mux
    generic map (
        OUTPUT_WIDTH => OUTPUT_WIDTH
    ) port map (
        clk            => clk,
        write_mode     => write_mode,
        clk_enable_in  => clk_enable_in,
        sync_in        => sync_in,
        data_in        => data_in,
        clk_enable_out => clk_enable_out,
        data_out       => data_out
    );
    -- also includes this in the simulation so that we can verify the proper interaction between these two modules
    ram_data_logger_inst : entity work.ram_data_logger
    generic map (
        ADDRESS_WIDTH => ADDRESS_WIDTH,
        DATA_WIDTH    => DATA_WIDTH
    ) port map (
        clk                => clk,
        data_in            => data_out,
        data_in_clk_enable => clk_enable_out,
        is_writing         => write_mode,
        sys_addr           => sys_addr,
        sys_wdata          => sys_wdata,
        sys_sel            => sys_sel,
        sys_wen            => sys_wen,
        sys_ren            => sys_ren,
        sys_rdata          => sys_rdata,
        sys_err            => sys_err,
        sys_ack            => sys_ack
    );

    -- Clock process definition for "clk"
    process
    begin
        clk <= '0';
        wait for clk_period/2;
        clk <= '1';
        wait for clk_period/2;
    end process;

    -- Stimulus process to generate input data
    process
    begin
        -- generate data that looks like the IQ data pattern from ddc_multichannel.vhd
        for I in 0 to 1500 loop
            wait until rising_edge(clk);
                sync_in <= '1';
                clk_enable_in <= '1';
                data_in <= std_logic_vector(to_unsigned(I, data_in'length));
            wait until rising_edge(clk);
                sync_in <= '0';
                clk_enable_in <= '1';
                data_in <= std_logic_vector(to_unsigned(I+10000, data_in'length));
            wait until rising_edge(clk);
                clk_enable_in <= '1';
                data_in <= std_logic_vector(to_unsigned(I+20000, data_in'length));


            wait until rising_edge(clk);
                clk_enable_in <= '0';
            wait until rising_edge(clk);
                clk_enable_in <= '0';
            wait until rising_edge(clk);
                clk_enable_in <= '0';
        end loop;

    end process;
    


    -- Stimulus process to start the writing process
    process
    begin
        wait until rising_edge(clk);
            sys_addr <= x"0000_1004";
            sys_wen <= '1';
        wait until rising_edge(clk);
            sys_addr <= x"0000_0000";
            sys_wen <= '0';
        wait for clk_period*(6*833-2+1+1); -- this should make the relative timing being sync_in and writing slide by 1 clk cycle at every attempt

    end process;
end;
