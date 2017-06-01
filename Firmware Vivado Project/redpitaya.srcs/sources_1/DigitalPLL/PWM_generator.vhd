----------------------------------------------------------------------------------
-- Company: NIST
-- Engineer: Hugo Bergeron
-- 
-- Create Date: 4/24/2015
-- Design Name: 
-- Module Name:    
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
-- Description: 
--
-- Dependencies: 
--
-- Revision: 
-- Revision 0.01 - File Created
-- Additional Comments: 
--
----------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


entity PWM_generator is
	Generic (
        NUMBER_OF_BITS : integer := 8
	);
	Port (
        clk   : in  std_logic;
        level : in  std_logic_vector(NUMBER_OF_BITS downto 0);
        dout  : out std_logic
	);
end entity;

architecture Behavioral of PWM_generator is
    signal level_reg : std_logic_vector(NUMBER_OF_BITS downto 0) := (others => '0');
    signal level_clp : std_logic_vector(NUMBER_OF_BITS downto 0) := (others => '0');
    signal dout_int  : std_logic := '0';
    signal dout_reg  : std_logic := '0';
    signal feedback  : std_logic_vector(NUMBER_OF_BITS downto 0) := (others => '0');
begin

    inout_regs : process (clk) is
    begin
        if rising_edge(clk) then
            level_reg <= level;
            dout_int <= dout_reg;
        end if;
    end process;
    dout <= dout_int;
    

    pwm : process (clk) is
        variable current : std_logic_vector(NUMBER_OF_BITS downto 0) := (others => '0');
    begin
        if rising_edge(clk) then
            if level_reg(NUMBER_OF_BITS) = '1' then
                level_clp <= (NUMBER_OF_BITS => '1', others => '0');
            else
                level_clp <= level_reg;
            end if;
            current := std_logic_vector(unsigned(feedback) + unsigned(level_clp));
            feedback <= '0' & current(NUMBER_OF_BITS-1 downto 0);
            dout_reg <= current(NUMBER_OF_BITS);
        end if;
    end process;
    
end architecture;
