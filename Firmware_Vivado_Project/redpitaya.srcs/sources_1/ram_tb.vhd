library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;   

entity ram_tb is
end ram_tb;


architecture behavior of ram_tb is

constant clock_period : time := 5 ns;
signal clk : STD_LOGIC := '0';
signal stop_the_clock: boolean;

--component simple_dualport_ram
--Generic (
--        ADDRESS_WIDTH : positive := 15;
--        DATA_WIDTH : positive := 16
--    );
--    Port (

--        -- Write port:
--        clk_write : in std_logic;
--        write_enable : in std_logic;
--        write_address : in  std_logic_vector (ADDRESS_WIDTH-1 downto 0);
--        write_data : in std_logic_vector(DATA_WIDTH-1 downto 0);

--        -- Read port:
--        clk_read : in  std_logic;
--        read_enable : in std_logic;
--        read_address : in  std_logic_vector (ADDRESS_WIDTH-1 downto 0);
--        read_data : out  std_logic_vector (DATA_WIDTH-1 downto 0)
--    );
--end component;

    signal write_address : std_logic_vector (8-1 downto 0);
    signal write_data : std_logic_vector (64-1 downto 0) := (others => '0');
    signal write_enable : std_logic := '0';
    signal read_address : std_logic_vector (8-1 downto 0) := (others => '0');
    signal read_data : std_logic_vector (64-1 downto 0) := (others => '0');
    signal read_enable : std_logic := '0';

--    type RAM_TYPE is array(0 to 2**16-1) of std_logic_vector(16-1 downto 0);    
--    signal RAM : RAM_TYPE := (others => (others => '0'));

begin
    

    -- the actual ram
    ram_inst : entity work.simple_dualport_ram_with_init
    generic map (
        ADDRESS_WIDTH => 8,
        DATA_WIDTH    => 64,
        DATA_FILE     => "ram_init_file.txt"

    ) port map (
        clk_write     => clk,
        write_enable  => write_enable,
        write_address => write_address,
        write_data    => write_data,
        
        clk_read      => clk,
        read_enable   => read_enable,
        read_address  => read_address,
        read_data     => read_data
    );

    stimulus: process
    begin
        wait for clock_period * 10;
        write_enable <= '0';
        read_enable <= '0';
        wait for clock_period * 5;

        write_address   <= "00000001"; --0000000000000001
        write_data      <= "0000000000000000000000000000000000000000000000000000000000000001"; --0000000000000001 --00000000000000000000000000000001
        wait for clock_period;
        write_enable <= '1';
        wait for clock_period;
        write_enable <= '0';
        wait for clock_period;
        write_enable <= '1';
        wait for clock_period;
        write_enable <= '0';

        write_address   <= "00000001"; --0000000000000001
        write_data      <= "0000000000000000000000000000000000000000000000000000000000000010"; -- --00000000000000000000000000000010
        wait for clock_period;
        write_enable <= '1';
        wait for clock_period;
        write_enable <= '0';

        wait for clock_period;
        write_address   <= "00000010"; --0000000000000010
        write_data      <= "0000000000000000000000000000000000000000000000000000000000000011"; -- --00000000000000000000000000000011
        wait for clock_period;
        write_enable <= '1';
        wait for clock_period;
        write_enable <= '0';
        

        read_address <= "00000000";
        read_enable <= '1';
        wait for clock_period * 2;
        read_address <= std_logic_vector(unsigned(read_address)+1); --0000000000000001
        wait for clock_period;
        read_enable <= '1';
        wait for clock_period;
        read_address   <= std_logic_vector(unsigned(read_address)+1); --0000000000000010        
        wait for clock_period;
        read_address   <= std_logic_vector(unsigned(read_address)+1); --0000000000000010        
        read_enable <= '0';
        wait for clock_period;

        --read_address   <= "00000010"; --0000000000000010
        --wait for clock_period;
        --read_enable <= '1';
        --wait for clock_period;
        --read_enable <= '0';
        --wait for clock_period;

        --read_address   <= "00000011"; --0000000000000011
        --wait for clock_period;
        --read_enable <= '1';
        --wait for clock_period;
        --read_enable <= '0';
        --wait for clock_period;
        
        stop_the_clock <= true;
        wait;
    end process;



    clocking: process
    begin
      while not stop_the_clock loop
        clk <= '0', '1' after clock_period / 2;
        wait for clock_period;
      end loop;
      wait;
    end process;

end;