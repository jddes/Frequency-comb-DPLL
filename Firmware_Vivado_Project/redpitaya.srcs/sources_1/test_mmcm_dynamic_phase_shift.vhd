library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

Library UNISIM;
use UNISIM.vcomponents.all;

-- Testing what is the maximum phase slew rate of the MMCM's dynamic phase shift feature.
-- Answer: it takes 60.1 ns from PSEN to PSDONE, and the phase shifts by 1/56th of a period per PSEN assertion.
-- This means that the maximum frequency shift is:
-- 1/56 / 60.1 ns = 300 kHz.
-- this frequency shift is on the VCO frequency itself however,
-- and thus the frequency shift possible on the divided down clock is simply:
-- 1/56 / 60.1 ns / N = 300 kHz / N.
-- where N is the division ratio between the MMCM's VCO and the output clock

entity test_mmcm_dynamic_phase_shift is
port (
    rst     : in  std_logic;
    clk_in  : in  std_logic;
    
    PSDONE  : out std_logic;
    
    clk_out : out std_logic

    );
end entity;

architecture Behavioral of test_mmcm_dynamic_phase_shift is

    signal counter : unsigned(32-1 downto 0) := (others => '0');

    signal CLKFB    : std_logic := '0';
    signal PSEN     : std_logic := '0';
    signal PSINCDEC : std_logic := '0';

begin


-- MMCME2_ADV  : In order to incorporate this function into the design,
--    VHDL     : the following instance declaration needs to be placed
--  instance   : in the body of the design code.  The instance name
-- declaration : (MMCME2_ADV_inst) and/or the port declarations after the
--    code     : "=>" declaration maybe changed to properly reference and
--             : connect this function to the design.  All inputs and outputs
--             : must be connected.

--   Library   : In addition to adding the instance declaration, a use
-- declaration : statement for the UNISIM.vcomponents library needs to be
--     for     : added before the entity declaration.  This library
--   Xilinx    : contains the component declarations for all Xilinx
-- primitives  : primitives and points to the models that will be used
--             : for simulation.

   -- MMCME2_ADV: Advanced Mixed Mode Clock Manager
   --             Kintex-7
   -- Xilinx HDL Language Template, version 2015.4

   MMCME2_ADV_inst : MMCME2_ADV
   generic map (
      BANDWIDTH => "OPTIMIZED",      -- Jitter programming (OPTIMIZED, HIGH, LOW)
      CLKFBOUT_MULT_F => 10.0,        -- Multiply value for all CLKOUT (2.000-64.000).
      CLKFBOUT_PHASE => 0.0,         -- Phase offset in degrees of CLKFB (-360.000-360.000).
      -- CLKIN_PERIOD: Input clock period in ns to ps resolution (i.e. 33.333 is 30 MHz).
      CLKIN1_PERIOD => 10.0,
      CLKIN2_PERIOD => 0.0,
      -- CLKOUT0_DIVIDE - CLKOUT6_DIVIDE: Divide amount for CLKOUT (1-128)
      CLKOUT1_DIVIDE => 10,
      CLKOUT2_DIVIDE => 1,
      CLKOUT3_DIVIDE => 1,
      CLKOUT4_DIVIDE => 1,
      CLKOUT5_DIVIDE => 1,
      CLKOUT6_DIVIDE => 1,
      CLKOUT0_DIVIDE_F => 10.0,       -- Divide amount for CLKOUT0 (1.000-128.000).
      -- CLKOUT0_DUTY_CYCLE - CLKOUT6_DUTY_CYCLE: Duty cycle for CLKOUT outputs (0.01-0.99).
      CLKOUT0_DUTY_CYCLE => 0.5,
      CLKOUT1_DUTY_CYCLE => 0.5,
      CLKOUT2_DUTY_CYCLE => 0.5,
      CLKOUT3_DUTY_CYCLE => 0.5,
      CLKOUT4_DUTY_CYCLE => 0.5,
      CLKOUT5_DUTY_CYCLE => 0.5,
      CLKOUT6_DUTY_CYCLE => 0.5,
      -- CLKOUT0_PHASE - CLKOUT6_PHASE: Phase offset for CLKOUT outputs (-360.000-360.000).
      CLKOUT0_PHASE => 0.0,
      CLKOUT1_PHASE => 0.0,
      CLKOUT2_PHASE => 0.0,
      CLKOUT3_PHASE => 0.0,
      CLKOUT4_PHASE => 0.0,
      CLKOUT5_PHASE => 0.0,
      CLKOUT6_PHASE => 0.0,
      CLKOUT4_CASCADE => FALSE,      -- Cascade CLKOUT4 counter with CLKOUT6 (FALSE, TRUE)
      COMPENSATION => "ZHOLD",       -- ZHOLD, BUF_IN, EXTERNAL, INTERNAL
      DIVCLK_DIVIDE => 1,            -- Master division value (1-106)
      -- REF_JITTER: Reference input jitter in UI (0.000-0.999).
      REF_JITTER1 => 0.0,
      REF_JITTER2 => 0.0,
      STARTUP_WAIT => FALSE,         -- Delays DONE until MMCM is locked (FALSE, TRUE)
      -- Spread Spectrum: Spread Spectrum Attributes
      SS_EN => "FALSE",              -- Enables spread spectrum (FALSE, TRUE)
      SS_MODE => "CENTER_HIGH",      -- CENTER_HIGH, CENTER_LOW, DOWN_HIGH, DOWN_LOW
      SS_MOD_PERIOD => 10000,        -- Spread spectrum modulation period (ns) (VALUES)
      -- USE_FINE_PS: Fine phase shift enable (TRUE/FALSE)
      CLKFBOUT_USE_FINE_PS => TRUE,
      CLKOUT0_USE_FINE_PS => TRUE,
      CLKOUT1_USE_FINE_PS => FALSE,
      CLKOUT2_USE_FINE_PS => FALSE,
      CLKOUT3_USE_FINE_PS => FALSE,
      CLKOUT4_USE_FINE_PS => FALSE,
      CLKOUT5_USE_FINE_PS => FALSE,
      CLKOUT6_USE_FINE_PS => FALSE 
   )
   port map (
        -- Clock Outputs: 1-bit (each) output: User configurable clock outputs
        CLKOUT0      => clk_out,      -- 1-bit output: CLKOUT0
        CLKOUT0B     => open,
        CLKOUT1      => open,
        CLKOUT1B     => open,
        CLKOUT2      => open,
        CLKOUT2B     => open,
        CLKOUT3      => open,
        CLKOUT3B     => open,
        CLKOUT4      => open,
        CLKOUT5      => open,
        CLKOUT6      => open,
        -- DRP Ports: 16-bit (each) output: Dynamic reconfiguration ports
        DO           => open,         -- 16-bit output: DRP data
        DRDY         => open,         -- 1-bit output: DRP ready
        -- Dynamic Phase Shift Ports: 1-bit (each) output: Ports used for dynamic phase shifting of the outputs
        PSDONE       => PSDONE,       -- 1-bit output: Phase shift done
        -- Feedback Clocks: 1-bit (each) output: Clock feedback ports
        CLKFBOUT     => CLKFB,      -- 1-bit output: Feedback clock
        CLKFBOUTB    => open,         -- 1-bit output: Inverted CLKFBOUT
        -- Status Ports: 1-bit (each) output: MMCM status ports
        CLKFBSTOPPED => open,         -- 1-bit output: Feedback clock stopped
        CLKINSTOPPED => open,         -- 1-bit output: Input clock stopped
        LOCKED       => open,         -- 1-bit output: LOCK
        -- Clock Inputs: 1-bit (each) input: Clock inputs
        CLKIN1       => clk_in,       -- 1-bit input: Primary clock
        CLKIN2       => '0',          -- 1-bit input: Secondary clock
        -- Control Ports: 1-bit (each) input: MMCM control ports
        CLKINSEL     => '1',          -- 1-bit input: Clock select, High=CLKIN1 Low=CLKIN2
        PWRDWN       => '0',          -- 1-bit input: Power-down
        RST          => rst,          -- 1-bit input: Reset

        -- DRP Ports: 7-bit (each) input: Dynamic reconfiguration ports
        DADDR        => (others => '0'),
        DCLK         => '0',
        DEN          => '0',
        DI           => (others => '0'),
        DWE          => '0',

        -- Dynamic Phase Shift Ports: 1-bit (each) input: Ports used for dynamic phase shifting of the outputs
        PSCLK        => clk_in,        -- 1-bit input: Phase shift clock
        PSEN         => PSEN,         -- 1-bit input: Phase shift enable
        PSINCDEC     => PSINCDEC,     -- 1-bit input: Phase shift increment/decrement
        -- Feedback Clocks: 1-bit (each) input: Clock feedback ports
        CLKFBIN      => CLKFB       -- 1-bit input: Feedback clock
   );


    
    -- counter process
    process( clk_in )
    begin
        if rising_edge(clk_in) then
            PSEN <= '0';
            if counter < 100-1 then
                counter <= counter + 1;
            else
                counter <= (others => '0');
                PSEN <= '1';
            end if;
        end if;
    end process;

end;
