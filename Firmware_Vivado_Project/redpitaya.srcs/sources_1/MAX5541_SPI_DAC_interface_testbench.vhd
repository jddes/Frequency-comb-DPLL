library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity max5541_spi_dac_interface_testbench is
end max5541_spi_dac_interface_testbench;

architecture behavior of max5541_spi_dac_interface_testbench is
    constant CLK_DIV             : integer :=  7;      -- needs to be equal to ceil(system clock/SPI clock/2)
    constant N_BITS_DAC          : integer := 16;      -- can't be changed as this is linked to the exact chip that this module was written for.
    constant N_BITS_PER_TRANSFER : integer := 4+4+2*16;  -- can't be changed as this is linked to the exact chip that this module was written for.
    constant N_BITS_COUNTER      : integer := 16;       -- needs to be at least ceil(log2(N_BITS_PER_TRANSFER))
    -- Inputs
    signal clk : std_logic := '0';
    signal data_in : std_logic_vector(n_bits_dac-1 downto 0) := std_logic_vector(to_unsigned(101, 16));

    
    -- Outputs
    signal data_loaded_clk_enable : std_logic;
    signal scl : std_logic;
    signal sda : std_logic;
    signal csb : std_logic;

    -- Simulation signals only - for the SPI receiver:
    signal scl_last : std_logic := '0';
    signal sda_last : std_logic := '0';
    signal csb_last : std_logic := '0';
    signal data_recv_srl : std_logic_vector(n_bits_dac-1 downto 0) := std_logic_vector(to_unsigned(0, 16));
    signal data_recv_reg : std_logic_vector(n_bits_dac-1 downto 0) := std_logic_vector(to_unsigned(0, 16));
    
    -- Clock period definition
    constant clk_period : time := 5 ns;
begin

    -- Unit under test
    max5541_spi_dac_interface_inst : entity work.max5541_spi_dac_interface
    generic map (
        CLK_DIV             => CLK_DIV,
        N_BITS_DAC          => N_BITS_DAC,
        N_BITS_PER_TRANSFER => N_BITS_PER_TRANSFER,
        N_BITS_COUNTER      => N_BITS_COUNTER
    ) port map (
        clk     => clk,
        data_in => data_in,
        data_loaded_clk_enable => data_loaded_clk_enable,
        scl     => scl,
        sda     => sda,
        csb     => csb
    );

    -- Clock process definition for "clk"
    process
    begin
        clk <= '0';
        wait for clk_period/2;
        clk <= '1';
        wait for clk_period/2;
    end process;

    -- fake an SPI receiver:
    process (clk)
    begin
        if rising_edge(clk) then
            -- detect start and stop conditions:
            -- actually detecting the start condition seems useless, so let's just detect the stop condition:
            if csb = '1' and csb_last = '0' then    -- if rising edge on csb
                data_recv_reg <= data_recv_srl;     -- latch the data from the shift register
            end if;
            -- at every rising edge of the clock, we shift in one bit
            if scl = '1' and scl_last = '0' then
                data_recv_srl <= data_recv_srl(data_recv_srl'left-1 downto 0) & sda;
            end if;
            -- registers for edge detection:
            scl_last <= scl;
            sda_last <= sda;
            csb_last <= csb;
        end if;
    end process;

    -- generate a ramp at the input of the module:
    process (clk)
    begin
        if rising_edge(clk) then
            if data_loaded_clk_enable = '1' then
                data_in <= std_logic_vector(unsigned(data_in) + 1);
            end if;
        end if;
    end process;

    
    -- Stimulus process
    process
    begin
        wait for clk_period*10;
        wait until rising_edge(clk);
        

        ---- Example of a for loop:
        --wait until new_data_available = '1';
        --for I in 0 to 1023 loop
        --    wait until rising_edge(clk);
        --        read_enable <= '1';
        --    wait until rising_edge(clk);
        --        read_enable <= '0';
        --    wait for clk_period*5;
        --end loop;
        wait;
    end process;
    
end;
