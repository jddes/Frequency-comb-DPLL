----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:   
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



entity IIR_LPF is
    generic (
        N_DATA : integer
    );
    port (
        clk      : in  std_logic;
        coef     : in  std_logic_vector(18-1 downto 0);
        data_in  : in  std_logic_vector(N_DATA-1 downto 0);
        data_out : out std_logic_vector(N_DATA+18-1 downto 0)
    );
end entity;

architecture behavioral of IIR_LPF is
    
    signal coef_reg : signed(18-1 downto 0) := (others => '0');
    
	signal data_in_int : signed(N_DATA-1 downto 0) := (others => '0');
    signal data_out_wide : signed(N_DATA+18-1 downto 0) := (others => '0');
    signal data_out_int : signed(N_DATA-1 downto 0) := (others => '0');
    
    signal delta : signed(N_DATA-1 downto 0) := (others => '0');
    
    attribute use_dsp48 : string;
    attribute use_dsp48 of data_out_wide : signal is "yes";

begin
    
    -- Input stage
    process (clk) is
    begin
        if rising_edge(clk) then
            data_in_int <= signed(data_in);
            coef_reg <= signed(coef);
        end if;
    end process;
	
    -- Filter stage
    delta <= data_in_int - data_out_int;
    process (clk) is
    begin
        if rising_edge(clk) then
            data_out_wide <= data_out_wide + delta*coef_reg;
        end if;
    end process;
    data_out_int <= resize(shift_right(data_out_wide, 18), data_out_int'length);
    
    -- Output stage
    data_out <= std_logic_vector(data_out_wide);

end architecture;
