------------------------------------------------------------------------------------------------
-- Company:      NIST
-- Engineer:     Hugo Bergeron
-- 
-- Create Date:  July 14th, 2015
-- Design Name: 
-- Module Name:  limiter
-- Project Name: synchronization
-- Description: 
-- 
-- This module is a simple limiter with generic input width and a 4 cycle latency.
-- It works on signed numbers. 
--
------------------------------------------------------------------------------------------------

------------------------------------------------------------------------------------------------
-- Libraries
------------------------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

------------------------------------------------------------------------------------------------
-- Entity declaration
------------------------------------------------------------------------------------------------
entity limiter is
	generic (
        DATA_WIDTH : integer := 8 -- Data width in bits
	); 
    port (
		clk    : in  std_logic;                               -- clock
        di     : in  std_logic_vector(DATA_WIDTH-1 downto 0); -- input data (signed)
        di_min : in  std_logic_vector(DATA_WIDTH-1 downto 0); -- input data minimum (signed)
        di_max : in  std_logic_vector(DATA_WIDTH-1 downto 0); -- input data maximum (signed)
        do     : out std_logic_vector(DATA_WIDTH-1 downto 0)  -- outut data (signed)
	);
end entity;


------------------------------------------------------------------------------------------------
-- Architecture declaration
------------------------------------------------------------------------------------------------
architecture behavioral of limiter is

    -- Low and High flags
    signal flag_lo     : std_logic := '0';
    signal flag_hi     : std_logic := '0';
    signal flag_vector : std_logic_vector(1 downto 0) := (others => '0');
    
    -- Input registers
    signal regi_di     : std_logic_vector(DATA_WIDTH-1 downto 0) := (others => '0');
    signal regi_di_min : std_logic_vector(DATA_WIDTH-1 downto 0) := (others => '0');
    signal regi_di_max : std_logic_vector(DATA_WIDTH-1 downto 0) := (others => '0');
    
    -- MSB extended input data
    signal ext_di      : std_logic_vector(DATA_WIDTH+1-1 downto 0) := (others => '0');
    signal ext_di_min  : std_logic_vector(DATA_WIDTH+1-1 downto 0) := (others => '0');
    signal ext_di_max  : std_logic_vector(DATA_WIDTH+1-1 downto 0) := (others => '0');
    
    -- Delayed data
    signal dly_di      : std_logic_vector(DATA_WIDTH-1 downto 0) := (others => '0');
    signal dly_di_min  : std_logic_vector(DATA_WIDTH-1 downto 0) := (others => '0');
    signal dly_di_max  : std_logic_vector(DATA_WIDTH-1 downto 0) := (others => '0');
    
    -- Limited data
    signal ltd_di      : std_logic_vector(DATA_WIDTH-1 downto 0) := (others => '0');
    
    -- Output registers
    signal rego_do     : std_logic_vector(DATA_WIDTH-1 downto 0) := (others => '0');
begin

    -- Input registers to ease timing
    input_registers : process(clk) is
    begin
        if rising_edge(clk) then
            regi_di     <= di;
            regi_di_min <= di_min;
            regi_di_max <= di_max;
        end if;
    end process;
    
    -- Version of the inputs MSB extended to DATA_WIDTH+1 (signed)
    ext_di     <= (regi_di(regi_di'high)         & regi_di);
    ext_di_min <= (regi_di_min(regi_di_min'high) & regi_di_min);
    ext_di_max <= (regi_di_max(regi_di_max'high) & regi_di_max);
    
    -- This is a vector containing the current flags, to be used in a case statement
    flag_vector <= (1 => flag_lo, 0 => flag_hi);

    -- Main limiter process
    limiter : process(clk) is
    begin
        if rising_edge(clk) then
            -- Use the flags on the delayed data
            case (flag_vector) is
                when "00" => ltd_di <= dly_di;
                when "10" => ltd_di <= dly_di_min;
                when "01" => ltd_di <= dly_di_max;
                when others => ltd_di <= (others => '0');
            end case;
            -- Compute low flag
            if signed(ext_di) < signed(ext_di_min) then
                flag_lo <= '1';
            else
                flag_lo <= '0';
            end if;
            -- Compute high flag
            if signed(ext_di) > signed(ext_di_max) then
                flag_hi <= '1';
            else
                flag_hi <= '0';
            end if;
            -- Delay the data to follow the flags
            dly_di     <= regi_di;
            dly_di_min <= regi_di_min;
            dly_di_max <= regi_di_max;
        end if;
    end process;
    
    -- Output registers to ease timing
    output_registers : process(clk) is
    begin
        if rising_edge(clk) then
            rego_do <= ltd_di;
        end if;
    end process;
    do <= rego_do;
    
end architecture;


