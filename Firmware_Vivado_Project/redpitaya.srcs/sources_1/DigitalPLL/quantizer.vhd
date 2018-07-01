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

entity quantizer is
    generic (
        DI_WIDTH : integer := 16;
        DO_WIDTH : integer := 10
    );
    port (
        clk : in  std_logic;
        di  : in  std_logic_vector(DI_WIDTH-1 downto 0);
        do  : out std_logic_vector(DO_WIDTH-1 downto 0)
    );
end entity;

architecture behavioral of quantizer is

    signal   di_ireg               : std_logic_vector(DI_WIDTH-1 downto 0) := (others => '0');

	signal   shift_register        : std_logic_vector(10-1 downto 0) := (others => '1');
	signal   shift_register_input  : std_logic := '0';
	signal   shift_register_output : std_logic := '0';
    signal   prbs_out              : std_logic := '0';
    
    constant HALF_STEP_UP          : std_logic_vector(DI_WIDTH-1 downto 0) := std_logic_vector(to_signed(+2**(DI_WIDTH-DO_WIDTH-1), DI_WIDTH));
    constant HALF_STEP_DOWN        : std_logic_vector(DI_WIDTH-1 downto 0) := std_logic_vector(to_signed(-2**(DI_WIDTH-DO_WIDTH-1), DI_WIDTH));
    signal   noise                 : std_logic_vector(DI_WIDTH-1 downto 0) := (others => '0');
    
    signal feedback : std_logic_vector(DI_WIDTH-1 downto 0) := (others => '0');
    signal qerr     : std_logic_vector(DI_WIDTH-1 downto 0) := (others => '0');
    signal qi       : std_logic_vector(DI_WIDTH-1 downto 0) := (others => '0');
    signal qi_frac  : std_logic_vector(DI_WIDTH-1 downto 0) := (others => '0');
    signal qo       : std_logic_vector(DI_WIDTH-1 downto 0) := (others => '0');
    signal qi_quant : std_logic_vector(DO_WIDTH-1 downto 0) := (others => '0');
    
    signal do_oreg  : std_logic_vector(DO_WIDTH-1 downto 0) := (others => '0');
begin
    ----------------------------------------------------------------------------------
    -- Input Registers
    ----------------------------------------------------------------------------------
	input_registers : process(clk)
	begin
		if rising_edge(clk) then
            di_ireg <= di;
		end if;
	end process;
    
    ----------------------------------------------------------------------------------
    -- PRBS
    ----------------------------------------------------------------------------------

	shift_register_input  <= shift_register(7) xor shift_register(0);
	shift_register_output <= shift_register(0);

	PRBS : process(clk)
	begin
		if rising_edge(clk) then
			shift_register <= shift_register_input & shift_register(shift_register'left downto 1);
		end if;
	end process;
	prbs_out <= shift_register_output;

    ----------------------------------------------------------------------------------
    -- Create noise to decorrelate quantization noise
    ----------------------------------------------------------------------------------
	decorr : process(clk)
	begin
		if rising_edge(clk) then
            if prbs_out = '0' then
                noise <= HALF_STEP_UP;
            else
                noise <= HALF_STEP_DOWN;
            end if;
		end if;
	end process;
    
    ----------------------------------------------------------------------------------
    -- Quantization
    ----------------------------------------------------------------------------------
	quant : process(clk)
	begin
		if rising_edge(clk) then
            feedback <= std_logic_vector(signed(feedback) + signed(qerr));
		end if;
	end process;
    qi <= std_logic_vector(signed(di_ireg) + signed(noise) + signed(feedback));
    qi_frac <= std_logic_vector(resize(signed(qi(DI_WIDTH-DO_WIDTH-1 downto 0)), DI_WIDTH));
    qo <= std_logic_vector(signed(qi) - signed(qi_frac));
    qerr <= std_logic_vector(signed(di_ireg) - signed(qo));
    qi_quant <= qo(DI_WIDTH-1 downto DI_WIDTH-DO_WIDTH);
    
    ----------------------------------------------------------------------------------
    -- Output Registers
    ----------------------------------------------------------------------------------
	output_registers : process(clk)
	begin
		if rising_edge(clk) then
            do_oreg <= qi_quant;
		end if;
	end process;
    do <= do_oreg;
    
end architecture;
