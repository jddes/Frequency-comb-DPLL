----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    11:29:12 11/29/2013 
-- Design Name: 
-- Module Name:    PLL_loop_filters - Behavioral 
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
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity PLL_loop_filters is
	Generic (
		-- Constants which control the scaling:
		-- Each branch's output is divided by 2^N
		N_DIVIDE_P 	: integer := 24;
		N_DIVIDE_I 	: integer := 24;	-- 16 + log2(100e6/(2*pi*3e3)), where 100e6 is the sampling frequency and 3e3 is the nominal corner frequency of the PI
		N_DIVIDE_II : integer := 35;
		N_OUTPUT 	: integer := 16
	
	);
    Port ( clk : in  STD_LOGIC;
           lock : in  STD_LOGIC;
           gain_changed : in  STD_LOGIC;
           data_in : in  STD_LOGIC_VECTOR (9 downto 0);
           gain_p : in  STD_LOGIC_VECTOR (31 downto 0);
           gain_i : in  STD_LOGIC_VECTOR (31 downto 0);
			  gain_ii : in  STD_LOGIC_VECTOR (31 downto 0);
           data_out : out  STD_LOGIC_VECTOR (N_OUTPUT-1 downto 0));
end PLL_loop_filters;

architecture Behavioral of PLL_loop_filters is

	--Coregen declarations
	-----------------------------------------------------------------------
	-- Multiplier, 10x32 input bits, 42 output bits
	component pll_wide_mult
		port (
		clk: in std_logic;
		a: in std_logic_vector(9 downto 0);
		b: in std_logic_vector(31 downto 0);
		sclr : in std_logic;
		p: out std_logic_vector(41 downto 0));
	end component;
	
	-- Multiplier, 32x32 input bits, 64 output bits, synchronous clear
	component pll_32x32_mult_ii
		port (
		clk: in std_logic;
		a: in std_logic_vector(31 downto 0);
		b: in std_logic_vector(31 downto 0);
		sclr : in std_logic;
		p: out std_logic_vector(63 downto 0));
	end component;
	
	-- Internal variables
	-----------------------------------------------------------------------
	signal pll0_p_mult_output : std_logic_vector(41 downto 0) := (others => '0');
	
	signal pll0_i_mult_output : std_logic_vector(41 downto 0) := (others => '0');
	signal pll0_i_accumulator : signed(N_OUTPUT+N_DIVIDE_I-1 downto 0) := (others => '0');
	
	signal pll0_ii_accumulator1 : signed(32-1 downto 0) := (others => '0');
	signal mult_sclr : std_logic := '0';
	signal pll0_ii_mult_output : std_logic_vector(63 downto 0) := (others => '0');
	signal pll0_ii_accumulator2 : signed(N_OUTPUT+N_DIVIDE_II-1 downto 0) := (others => '0');
	
	signal output_sum : signed(N_OUTPUT-1 downto 0) := (others => '0');
begin

	-- Proportionnal branch
	----------------------------------------------------------------
	pll_wide_mult_p : pll_wide_mult
			port map (
				clk => clk,
				a => data_in,
				b => gain_p,
				sclr => mult_sclr,
				p => pll0_p_mult_output);

	-- Integrator branch
	----------------------------------------------------------------
	pll_wide_mult_i : pll_wide_mult
			port map (
				clk => clk,
				a => data_in,
				b => gain_i,
				sclr => mult_sclr,
				p => pll0_i_mult_output);
				
	process (clk)
	begin
		if rising_edge(clk) then
			if gain_changed = '1' or lock = '0' then
				pll0_i_accumulator <= (others => '0');
			else
				-- TODO: saturate instead of overflowing?
				pll0_i_accumulator <= pll0_i_accumulator + resize(signed(pll0_i_mult_output), pll0_i_accumulator'length);
			end if;
		end if;
	end process;
	
	-- Double-Integrator branch
	----------------------------------------------------------------
	-- This time we first integrate the frequency input to yield the phase,
	-- from 10 bits input to 32 bits output with saturation.  This means that we have a range of 22 bits (4e6 * 2*pi radians) over
	-- which the phase is tracked linearly.
	-- We then apply the gain, ie we multiply a 32 bits x 32 bits = 64 bits signal
	-- We finally accumulate the result, and then divide by 2^N_DIVIDE_II at the summing node.
	
	-- Saturating accumulator
	process (clk)
		variable temp_sum : signed(pll0_ii_accumulator1'length-1+1 downto 0) := (others => '0');
	begin
		if rising_edge(clk) then
			if gain_changed = '1' or lock = '0' then
				pll0_ii_accumulator1 <= (others => '0');
			else
				-- This holds the full 33-bits result of the accumulation without saturation or overflow
				-- REMOVE THIS shift_left BEFORE SYNTHESIS: THIS IS ONLY TO TEST THE SATURATION BEHAVIOR!!!!!!!!!!!!!!!!!!
--				temp_sum := resize(pll0_ii_accumulator1, temp_sum'length) + shift_left(resize(signed(data_in), temp_sum'length), 10);
				temp_sum := resize(pll0_ii_accumulator1, temp_sum'length) + resize(signed(data_in), temp_sum'length);
				if temp_sum > b"01111111111111111111111111111111" then
					-- Railed positive
					pll0_ii_accumulator1 <= b"01111111111111111111111111111111";--to_signed(2**31-1, 32);
				elsif temp_sum < b"10000000000000000000000000000000" then
					-- Railed negative
					pll0_ii_accumulator1 <= b"10000000000000000000000000000000";--to_signed(-2**31, 32);
				else
					-- Within the linear range
					pll0_ii_accumulator1 <= temp_sum(pll0_ii_accumulator1'range);
				end if;
				
			end if;
		end if;
	end process;
	
	-- 32x32 Multiplier which scales the integrated phase:
	pll_32x32_mult_ii_inst : pll_32x32_mult_ii
			port map (
				clk => clk,
				a => std_logic_vector(pll0_ii_accumulator1),
				b => gain_ii,
				sclr => mult_sclr,
				p => pll0_ii_mult_output);
	mult_sclr <= gain_changed or not lock;


	-- Second integrator at the output, with no provision for saturation, which is not so bad because if we overflow here that means that the output is railed
	-- so we have lost control of the phase lock anyway.
	process (clk)
	begin
		if rising_edge(clk) then
			if gain_changed = '1' or lock = '0' then
				pll0_ii_accumulator2 <= (others => '0');
			else
				-- TODO: saturate instead of overflowing?
				pll0_ii_accumulator2 <= pll0_ii_accumulator2 + resize(signed(pll0_ii_mult_output), pll0_ii_accumulator2'length);
			end if;
		end if;
	end process;
	
	-- Output summing node
	----------------------------------------------------------------
	process (clk)
	begin
		if rising_edge(clk) then
			-- output_sum <= pll0_p_mult_output/2^N_DIVIDE_P + pll0_i_mult_output/2^N_DIVIDE_I + pll0_ii_mult_output2/2^N_DIVIDE_II;
			if lock = '1' then
				output_sum <=	resize(signed(pll0_p_mult_output(pll0_p_mult_output'length-1 downto N_DIVIDE_P)),      N_OUTPUT) + 
									resize(signed(pll0_i_accumulator(pll0_i_accumulator'length-1 downto N_DIVIDE_I)),      N_OUTPUT) + 
									resize(signed(pll0_ii_accumulator2(pll0_ii_accumulator2'length-1 downto N_DIVIDE_II)), N_OUTPUT);
			else
				output_sum <= (others => '0');
			end if;
		end if;
	end process;
	
	data_out <= std_logic_vector(output_sum);
end Behavioral;

