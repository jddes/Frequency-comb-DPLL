library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- SPI interface for a MAX5541 16-bits serial DAC.
-- The max SPI clock is 10 MHz so choose CLK_DIV appropriately.
-- The SPI clk rate will be equal to: System clk rate/(2*CLK_DIV).
-- The DAC sample rate will be equal to 2*(SPI clk rate)/(N_HALF_CYCLES_PER_SAMPLE) system clock rate/(N_HALF_CYCLES_PER_SAMPLE*CLK_DIV),
-- At time of design of this block, we had:
-- 		system clk rate = 125 MHz,
-- 		CLK_DIV = 7,
-- 		SPI clock rate = 8.9 MHz,
-- 		N_HALF_CYCLES_PER_SAMPLE = 40
-- 		DAC sample rate = 446 kHz
-- Comment: N_HALF_CYCLES_PER_SAMPLE could be decreased slightly if less padding is added between samples, but the dead time is currently a pretty small fraction of the overall transfer time (see testbench for actual numbers)
-- Total transfer time per sample is currently 2.24 us, with 0.5 us of dead time, so max rate could potentially be close to 1/(2.24us - 0.5 us) = 575 kHz.
-- The exact max rate might be slightly different because some dead time is necessary for the CSB start and stop conditions.

entity MAX5541_SPI_DAC_interface is
Generic (
	CLK_DIV                  : integer :=  7;      -- needs to be equal to ceil(system clock/SPI clock/2)
	N_BITS_DAC               : integer := 16;      -- can't be changed as this is linked to the exact chip that this module was written for.
	N_HALF_CYCLES_PER_SAMPLE : integer := 4+4+2*16;  -- can't be changed as this is linked to the exact chip that this module was written for.
	N_BITS_COUNTER           : integer := 16       -- needs to be at least ceil(log2(N_HALF_CYCLES_PER_SAMPLE))
);
port (
	-- System clock, needs to be much higher than SPI clock (see CLK_DIV generic)
	clk                    : in  std_logic;
	
	-- Input port: Data to send to the dac
	data_in                :  in std_logic_vector(N_BITS_DAC-1 downto 0);
	
	-- Output port: indicates when the data has been shifted in, to enable other modules to sync up with the SPI clock:
	data_loaded_clk_enable : out std_logic;
	
	-- Output port: SPI interface to top-level pins:
	scl                    : out std_logic;
	sda                    : out std_logic;
	csb                    : out std_logic

	);
end entity;

architecture Behavioral of MAX5541_SPI_DAC_interface is

	signal data_in_reg : std_logic_vector(N_BITS_DAC-1 downto 0) := (others => '0');

	type state_type is (STATE_IDLE, STATE_TRANSFERING);
	signal FSM_state : state_type := STATE_IDLE;

	-- Shift registers in which we load the data to be read out serially
	signal SCL_SRL : std_logic_vector(N_HALF_CYCLES_PER_SAMPLE-1 downto 0) := (others => '0');
	signal SDA_SRL : std_logic_vector(N_HALF_CYCLES_PER_SAMPLE-1 downto 0) := (others => '0');
	signal CSB_SRL : std_logic_vector(N_HALF_CYCLES_PER_SAMPLE-1 downto 0) := (others => '0');

	-- Sequencing counter which determines when we load the data into the shift registers:
	signal bits_counter : unsigned(N_BITS_COUNTER-1 downto 0) := (others => '0');
	signal clk_enable_counter : unsigned(N_BITS_COUNTER-1 downto 0) := (others => '0');
	signal clk_enable : std_logic := '0';

	signal scl_internal     : std_logic := '0';
	signal sda_internal     : std_logic := '0';
	signal csb_internal     : std_logic := '0';

	signal data_loaded_clk_enable_internal : std_logic := '0';

begin

	-- input register stage for the data:
	process (clk)
	begin
		if rising_edge(clk) then
			data_in_reg <= data_in;
		end if;
	end process;

	-- counter which generates clk enables at 2*the SPI clock rate:
	process (clk)
	begin
		if rising_edge(clk) then
			if clk_enable_counter = CLK_DIV-1 then
				clk_enable_counter <= (others => '0');
				clk_enable <= '1';
			else
				clk_enable_counter <= clk_enable_counter + 1;
				clk_enable <= '0';
			end if;
		end if;
	end process;
	
	-- Process which is clk-enabled at 2*SPI clock rate
	-- Basically only shifts out the shift registers and reloads them at the end of every transfer
	process (clk)
	begin
		if rising_edge(clk) then
			data_loaded_clk_enable_internal <= '0';	-- default value


			if clk_enable = '1' then
				-- shift out the SRL content:
				CSB_SRL <= CSB_SRL(CSB_SRL'left-1 downto 0) & 'X';	-- those X's are never supposed to make it out of the SRL because it will be reloaded before it gets to the end
				SCL_SRL <= SCL_SRL(SCL_SRL'left-1 downto 0) & 'X';
				SDA_SRL <= SDA_SRL(SDA_SRL'left-1 downto 0) & 'X';
				scl_internal <= SCL_SRL(SCL_SRL'left);
				sda_internal <= SDA_SRL(SDA_SRL'left);
				csb_internal <= CSB_SRL(CSB_SRL'left);


				if bits_counter = N_HALF_CYCLES_PER_SAMPLE-1 then
					bits_counter <= (others => '0');
					-- load new data into SRLs:
					-- this is basically hard-coding the entire timing diagram (figure 2 of the MAX5541 datasheet)
					-- each bit corresponds to a half-period of the SPI clock.
					CSB_SRL <= b"11_10_00_00_00_00_00_00_00_00_00_00_00_00_00_00_00_00_11_11";
					SCL_SRL <= b"00_00_01_01_01_01_01_01_01_01_01_01_01_01_01_01_01_01_00_00";
					SDA_SRL <= b"0000" 	& data_in_reg(15) & data_in_reg(15)
										& data_in_reg(14) & data_in_reg(14)
										& data_in_reg(13) & data_in_reg(13)
										& data_in_reg(12) & data_in_reg(12)
										& data_in_reg(11) & data_in_reg(11)
										& data_in_reg(10) & data_in_reg(10)
										& data_in_reg( 9) & data_in_reg( 9)
										& data_in_reg( 8) & data_in_reg( 8)
										& data_in_reg( 7) & data_in_reg( 7)
										& data_in_reg( 6) & data_in_reg( 6)
										& data_in_reg( 5) & data_in_reg( 5)
										& data_in_reg( 4) & data_in_reg( 4)
										& data_in_reg( 3) & data_in_reg( 3)
										& data_in_reg( 2) & data_in_reg( 2)
										& data_in_reg( 1) & data_in_reg( 1)
										& data_in_reg( 0) & data_in_reg( 0)
										& b"00_00";
					data_loaded_clk_enable_internal <= '1';
				else
					bits_counter <= bits_counter + 1;
				end if;

			end if;
		end if;
	end process;


	-- assign outputs:
	scl                    <= scl_internal;
	sda                    <= sda_internal;
	csb                    <= csb_internal;
	data_loaded_clk_enable <= data_loaded_clk_enable_internal;
end;
