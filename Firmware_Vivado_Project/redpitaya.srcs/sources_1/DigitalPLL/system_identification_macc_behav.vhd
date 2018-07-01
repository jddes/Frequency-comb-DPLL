library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


entity system_identification_macc_behav  is
Generic (
	DATA_WIDTH_IN		: integer := 16;
	DATA_WIDTH_OUT 		: integer := 64
);
port (
	clk               : in  std_logic;
	synchronous_clear : in  std_logic;
	
	-- s = cumsum(a*b)
	a                 : in  std_logic_vector(DATA_WIDTH_IN -1 downto 0);
	b                 : in  std_logic_vector(DATA_WIDTH_IN -1 downto 0);
	s                 : out std_logic_vector(DATA_WIDTH_OUT-1 downto 0)


	);
end entity;

architecture Behavioral of system_identification_macc_behav is

	-- the two operands
	signal a_reg      : std_logic_vector(DATA_WIDTH_IN -1              downto 0)  := (others => '0');
	signal b_reg      : std_logic_vector(DATA_WIDTH_IN -1              downto 0)  := (others => '0');
	-- the product
	signal p          : signed          (DATA_WIDTH_IN+DATA_WIDTH_IN -1 downto 0) := (others => '0');
	signal p_reg      : signed          (DATA_WIDTH_IN+DATA_WIDTH_IN -1 downto 0) := (others => '0');
	-- the accumulator
	signal accum      : signed          (DATA_WIDTH_OUT -1              downto 0) := (others => '0');
	signal accum_reg  : signed          (DATA_WIDTH_OUT -1              downto 0) := (others => '0');
	signal accum_reg2 : signed          (DATA_WIDTH_OUT -1              downto 0) := (others => '0');
	
begin

	process (clk)
	begin
		if rising_edge(clk) then
			-- registers to improve timing
			a_reg <= a;
			b_reg <= b;
			

			-- actual product
			p <= signed(a_reg) * signed(b_reg);
			p_reg <= p;	-- register to improve timing

			-- accumulator
			if synchronous_clear = '1' then
				accum <= (others => '0');
			else
				accum <= accum + resize(p_reg, accum'length);
			end if;

			-- registers to improve timing, this is a 64-bits accumulator
			accum_reg  <= accum;
			accum_reg2 <= accum_reg;

		end if;
	end process;

	-- assign output
	s <= std_logic_vector(accum_reg2);
end;
