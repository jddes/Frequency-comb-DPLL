library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- simply integrates a (mostly-constant) value into a ramp, with some scaling:
-- data_out = cumsum(ramp_slope/2^RIGHTSHIFT),
-- where the cumsum operation is clocked by clk_enable_in.
-- no protection against wrapping is provided - 
-- the intent is that the word sizes will be large enough,
-- and the ramp_slope values low enough for wrapping to never occur in proper operation.
--
-- this yields the following physical scaling:
-- ramp_rate_in_Hz = ramp_slope/2^(DDS_CTRL_WORD_WIDTH+RIGHT_SHIFT) * sampling_rate^2
-- where OUTPUT_DATA_WIDTH is meant to be set to DDS_CTRL_WORD_WIDTH.
-- sampling_rate is the clk_enable_in sampling rate (designed for ~300 kHz)
-- in which case, we also have the following:
-- minimum ramp step size:
-- ramp_rate_step_size_in_Hz = 1/2^(DDS_CTRL_WORD_WIDTH+RIGHT_SHIFT) * sampling_rate^2
-- ramp_rate_step_size_in_Hz = 1/2^(DDS_CTRL_WORD_WIDTH+RIGHT_SHIFT) * sampling_rate^2
-- 
-- ramp_rate_in_code = @(rate_in_Hz, sampling_rate) 2^64*rate_in_Hz/sampling_rate^2
entity linear_ramp_gen is
Generic (
    INPUT_DATA_WIDTH  : integer := 64;
    OUTPUT_DATA_WIDTH : integer := 48;
    RIGHTSHIFT        : integer := 16
);
port (
    clk           : in  std_logic;
    
    reset_ramp    : in  std_logic;  -- logical 1 on this resets the ramp

    clk_enable_in : in  std_logic;
    ramp_slope    : in  std_logic_vector(INPUT_DATA_WIDTH-1 downto 0);
    
    data_out      : out std_logic_vector(OUTPUT_DATA_WIDTH-1 downto 0)
    
    );
end entity;

architecture Behavioral of linear_ramp_gen is

    signal reset_ramp_reg : std_logic := '0';
    signal integrator : signed(INPUT_DATA_WIDTH-1 downto 0) := (others => '0');
    signal data_out_wider : std_logic_vector(INPUT_DATA_WIDTH-1 downto 0) := (others => '0');
begin

    process (clk)
    begin
        if rising_edge(clk) then
            reset_ramp_reg <= reset_ramp;

            if reset_ramp_reg = '1' then
                integrator <= (others => '0');
            else
                if clk_enable_in = '1' then
                    integrator <= integrator + signed(ramp_slope);
                end if;
            end if;
        end if;
    end process;

    data_out_wider <= std_logic_vector(shift_right(integrator, RIGHTSHIFT));
    data_out <= data_out_wider(data_out'range);

end;
