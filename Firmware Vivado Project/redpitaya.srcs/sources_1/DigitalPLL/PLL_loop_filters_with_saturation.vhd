----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    11:29:12 11/29/2013 
-- Design Name: 
-- Module Name:    PLL_loop_filters_with_saturation - Behavioral 
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
-- Description:  Implements a PII^2 filter, according to the following equation:
-- data_out = gain_p/2^N_DIVIDE_P*data_in + gain_i/2^N_DIVIDE_I * cumsum(data_in) + gain_ii/2^N_DIVIDE_II * cumsum(cumsum(data_in))
-- Note that this equation does not include the delays, quantization and the saturation.
-- Each branch is saturated independently, and the sum is also saturated.
-- The quantization happens before the output summing block.
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



entity PLL_loop_filters_with_saturation is
	Generic (
		-- Constants which control the scaling:
		-- Each branch's output is divided by 2^N
		N_DIVIDE_P 	: integer := 24;
		N_DIVIDE_I 	: integer := 24;	-- 16 + log2(100e6/(2*pi*3e3)), where 100e6 is the sampling frequency and 3e3 is the nominal corner frequency of the PI
		N_DIVIDE_II : integer := 35;
        N_DIVIDE_D  : integer := 32;
		N_OUTPUT 	: integer := 16
	
	);
    Port (
		clk             : in  std_logic;
		lock            : in  std_logic;
		gain_changed    : in  std_logic;
		data_in         : in  std_logic_vector (9 downto 0);
		gain_p          : in  std_logic_vector (31 downto 0);
		gain_i          : in  std_logic_vector (31 downto 0);
		gain_ii         : in  std_logic_vector (31 downto 0);
		gain_d          : in  std_logic_vector (31 downto 0);
		coef_d_filter   : in  std_logic_vector (17 downto 0);
		phase_residuals : out std_logic_vector (31 downto 0);
		data_out        : out std_logic_vector (N_OUTPUT-1 downto 0);
		saturated_low   : out std_logic;
		saturated_high  : out std_logic
    );
end PLL_loop_filters_with_saturation;

architecture Behavioral of PLL_loop_filters_with_saturation is

	--Coregen declarations
	-----------------------------------------------------------------------
	-- Multiplier, 10x32 input bits, 42 output bits
	component pll_wide_mult
	port (
		clk  : in std_logic;
		a    : in std_logic_vector(9 downto 0);
		b    : in std_logic_vector(31 downto 0);
		sclr : in std_logic;
		p    : out std_logic_vector(41 downto 0));
	end component;
	
	-- Multiplier, 32x32 input bits, 64 output bits, synchronous clear
	component pll_32x32_mult_ii
	port (
		clk  : in std_logic;
		a    : in std_logic_vector(31 downto 0);
		b    : in std_logic_vector(31 downto 0);
		sclr : in std_logic;
		p    : out std_logic_vector(63 downto 0));
	end component;
    
--	-- Multiplier, 18x32 input bits, 64 output bits, synchronous clear
--	component pll_18x32_mult_d
--		port (
--		clk: in std_logic;
--		a: in std_logic_vector(17 downto 0);
--		b: in std_logic_vector(31 downto 0);
--		sclr : in std_logic;
--		p: out std_logic_vector(49 downto 0));
--	end component;
	
	-- Internal variables
	-----------------------------------------------------------------------
	-- P branch signals
	signal p_mult_output                        : std_logic_vector(41 downto 0) := (others => '0');
	signal p_out                                : std_logic_vector(N_OUTPUT-1 downto 0) := (others => '0');
	signal p_railed_positive, p_railed_negative : std_logic := '0';
	
	-- This accumulator integrates the frequency error to yield the phase error, and its result is used by both the I and the I^2 branch:
	-- We arbitrarily decide on using 32 bits for the result (mostly because it fits well in the next 32x32 MULT)
	-- The freq error has 10 fractional bits which means that there are 22 integer bits of phase error, or 2e6 * 2*pi radians of linear range.
	constant N_BITS_PHASE_RESULT   : integer := 32;
	signal phase_error_accumulator : signed(N_BITS_PHASE_RESULT-1 downto 0) := (others => '0');
	signal phase_error_accumulator_resized : std_logic_vector(32-1 downto 0) := (others => '0');
	-- the extra bit in these signals is to hold the full, unwrapped result
	constant PHASE_ACCUM_MAX : signed(N_BITS_PHASE_RESULT+1-1 downto 0) := shift_left(to_signed(1, N_BITS_PHASE_RESULT+1), N_BITS_PHASE_RESULT-1)-1;	-- (2^(N_BITS_PHASE_RESULT-1)-1)
	constant PHASE_ACCUM_MIN : signed(N_BITS_PHASE_RESULT+1-1 downto 0) := shift_left(to_signed(-1, N_BITS_PHASE_RESULT+1), N_BITS_PHASE_RESULT-1);	-- (-2**(N_BITS_PHASE_RESULT-1))
	
	-- I branch signals
	signal i_mult_output                        : std_logic_vector(32+32-1 downto 0) := (others => '0');
	signal i_out                                : std_logic_vector(N_OUTPUT-1 downto 0) := (others => '0');
	signal i_railed_positive, i_railed_negative : std_logic := '0';

	-- II branch signals
	signal ii_mult_output, ii_mult_output_reg                         : std_logic_vector(32+32-1 downto 0) := (others => '0');
	
	signal second_stage_railed_positive, second_stage_railed_negative : std_logic := '0';
	signal ii_accumulator                                             : std_logic_vector(N_OUTPUT+N_DIVIDE_II-1 downto 0) := (others => '0');
	signal ii_accumulator_resized                                     : std_logic_vector(ii_accumulator'length-N_DIVIDE_II-1 downto 0) := (others => '0');
	signal ii_out                                                     : std_logic_vector(N_OUTPUT-1 downto 0) := (others => '0');
	signal ii_railed_positive, ii_railed_negative                     : std_logic := '0';
	
    -- D branch signals
    -- signal data_in_dly : std_logic_vector(9 downto 0) := (others => '0');
	signal data_diff        : std_logic_vector(32-1 downto 0)       := (others => '0');
	signal d_mult_output    : std_logic_vector(64-1 downto 0)       := (others => '0');
	signal d_out_unfiltered : std_logic_vector(N_OUTPUT-1 downto 0) := (others => '0');
	signal d_out            : std_logic_vector(N_OUTPUT-1 downto 0) := (others => '0');
	signal d_in_filt        : std_logic_vector(14-1 downto 0)       := (others => '0');
	signal d_out_filt       : std_logic_vector(32-1 downto 0)       := (others => '0');
	signal d_out_filt_dly   : std_logic_vector(32-1 downto 0)       := (others => '0');
    
	signal d_railed_positive, d_railed_negative            : std_logic := '0';
	
	-- Summing node signals
	signal output_sum                                      : signed(N_OUTPUT-1+2 downto 0) := (others => '0');    -- the extra two bits are to handle the full range result without overflowing
	signal sum_railed_negative, sum_railed_positive        : std_logic := '0';    -- this is used for the anti-windup behavior (we stop integrating if the sum is railed, even if the integrator isn't)
	
	-- Flags which indicate internal state
	signal synchronous_clear                               : std_logic := '0'; -- resets everything, asserted when either gain_changed = '1' or lock = '0'
	signal saturated_high_internal, saturated_low_internal : std_logic := '0';    -- indicates to the external world when one of the internal signal is saturated
begin

	-- Synchronous clear of the internal signals either when we are out of lock, or when the gains are changed:
	synchronous_clear <= gain_changed or not lock;

	-- Proportionnal branch
	----------------------------------------------------------------
	pll_wide_mult_p : pll_wide_mult
	port map (
		clk               => clk,
		a                 => data_in,
		b                 => gain_p,
		sclr              => synchronous_clear,
		p                 => p_mult_output
	);

	-- Division by 2^N_DIVIDE_P and saturation for P branch, adds 1 cycle of delay:
	p_saturation_inst: entity work.resize_with_saturation
	GENERIC MAP (
		N_INPUT           => p_mult_output'length-N_DIVIDE_P,
		N_OUTPUT          => p_out'length
	)
	PORT MAP (
		clk               => clk,
		synchronous_clear => synchronous_clear,
		data_in           => p_mult_output(p_mult_output'length-1 downto N_DIVIDE_P),
		railed_positive   => p_railed_positive,
		railed_negative   => p_railed_negative,
		data_out          => p_out
	);

	-- Saturating accumulator which generates the phase error by integrating the frequency error (NO ANTI-WINDUP: this is by design because having anti-windup here would mean not integrating part of the error signal),
	-- this result is used by both the I and the I^2 branch.  Adds 1 clock cycle of delay.
	-- phase_error_accumulator = saturate(cumsum(data_in))
	process (clk)
		variable temp_sum : signed(phase_error_accumulator'length+1-1 downto 0) := (others => '0');
	begin
		if rising_edge(clk) then
			if gain_changed = '1' or lock = '0' then
				phase_error_accumulator <= (others => '0');
			else
				-- This holds the full 33-bits result of the accumulation without saturation or overflow
				temp_sum := resize(phase_error_accumulator, temp_sum'length) + resize(signed(data_in), temp_sum'length);
				if temp_sum > PHASE_ACCUM_MAX then
					-- Railed positive
					phase_error_accumulator <= PHASE_ACCUM_MAX(phase_error_accumulator'range);--to_signed(2**31-1, 32);
				elsif temp_sum < PHASE_ACCUM_MIN then
					-- Railed negative
					phase_error_accumulator <= PHASE_ACCUM_MIN(phase_error_accumulator'range);--to_signed(-2**31, 32);
				else
					-- Within the linear range
					phase_error_accumulator <= temp_sum(phase_error_accumulator'range);
				end if;
			end if;
		end if;
	end process;
	-- for monitoring the lock state:
	phase_residuals <= std_logic_vector(phase_error_accumulator);
	
	-- Integrator branch
	----------------------------------------------------------------
	
	-- Multiplier, i_mult_output = gain_i * phase_error_accumulator (exact integer arithmetic, 32x32 = 64 bits result)
	-- 32x32 Multiplier which scales the integrated phase, 8 clock cycles of delay:
	pll_32x32_mult_i_inst : pll_32x32_mult_ii
	port map (
		clk               => clk,
		a                 => phase_error_accumulator_resized,    -- the resize is only for the case where phase_error_accumulator is smaller than the 'a' operand, which occurs in simulation when we want to speed up the integrator overflow test.
		b                 => gain_i,
		sclr              => synchronous_clear,
		p                 => i_mult_output
	);

	phase_error_accumulator_resized <= std_logic_vector(resize(phase_error_accumulator, 32)); -- the resize is only for the case where phase_error_accumulator is smaller than the 'a' operand, which occurs in simulation when we want to speed up the integrator overflow test.

	-- Division by 2^N_DIVIDE_I and saturation for I branch, adds 1 cycle of delay:
	i_saturation_inst: entity work.resize_with_saturation
	GENERIC MAP (
		N_INPUT           => i_mult_output'length-N_DIVIDE_I,
		N_OUTPUT          => i_out'length
	)
	PORT MAP (
		clk               => clk,
		synchronous_clear => synchronous_clear,
		data_in           => i_mult_output(i_mult_output'length-1 downto N_DIVIDE_I),
		railed_positive   => i_railed_positive,
		railed_negative   => i_railed_negative,
		data_out          => i_out
	);



	-- Double-Integrator branch
	----------------------------------------------------------------
	-- We use the phase_error_accumulator result, scale the result, then accumulate again, and finally divide by N_DIVIDE_II.
	
	-- Multiplier, ii_mult_output = gain_ii * phase_error_accumulator (exact integer arithmetic, 32x32 = 64 bits result)
	-- 32x32 Multiplier which scales the integrated phase, 8 clock cycles of delay:
	pll_32x32_mult_ii_inst : pll_32x32_mult_ii
	port map (
		clk               => clk,
		a                 => phase_error_accumulator_resized,    -- the resize is only for the case where phase_error_accumulator is smaller than the 'a' operand, which occurs in simulation when we want to speed up the integrator overflow test.
		b                 => gain_ii,
		sclr              => synchronous_clear,
		p                 => ii_mult_output
	);

	-- register stage between the multiplier and the integrator to help with timing closure:
	process (clk)
	begin
		if rising_edge(clk) then
			ii_mult_output_reg <= ii_mult_output;
		end if;
	end process;

	-- Integrator with saturation (exact integer arithmetic, other than the saturation behavior).  Also has anti-windup.
	integrator_with_saturation_inst2 : entity work.integrator_with_saturation
	generic map (
		N_INPUT => ii_mult_output'length,
		N_OUTPUT => ii_accumulator'length
	) port map (
		clk                 => clk,
		sclr                => synchronous_clear,
		railed_positive     => sum_railed_positive,
		railed_negative     => sum_railed_negative,
		data_in             => ii_mult_output_reg,
		data_out            => ii_accumulator,
		railed_positive_out => second_stage_railed_positive,
		railed_negative_out => second_stage_railed_negative

	);
				
	-- Division by 2^N_DIVIDE_II and saturation for II branch, adds 1 cycle of delay:
	ii_saturation_inst: entity work.resize_with_saturation
	GENERIC MAP (
		N_INPUT               => ii_accumulator'length-N_DIVIDE_II,
		N_OUTPUT              => ii_out'length
	)
	PORT MAP (
			clk               => clk,
			synchronous_clear => synchronous_clear,
			data_in           => ii_accumulator_resized,
			railed_positive   => ii_railed_positive,
			railed_negative   => ii_railed_negative,
			data_out          => ii_out
	);

	ii_accumulator_resized <= ii_accumulator(ii_accumulator'length-1 downto N_DIVIDE_II);

	-- Differentiator with filter branch
	----------------------------------------------------------------
   
    process (clk) is
    begin
        if rising_edge(clk) then
            d_in_filt <= std_logic_vector(shift_left(resize(signed(data_in), d_in_filt'length), 3));
        end if;
    end process;
        
        
    IIR_LPF_inst : entity work.IIR_LPF
    generic map (
        N_DATA => d_in_filt'length
    ) port map (
        clk      => clk,
        coef     => coef_d_filter,
        data_in  => d_in_filt,
        data_out => d_out_filt
    );
    
    process (clk) is
    begin
        if rising_edge(clk) then
            d_out_filt_dly <= d_out_filt;
            data_diff <= std_logic_vector(signed(d_out_filt) - signed(d_out_filt_dly));
        end if;
    end process;
    
    pll_wide_mult_d : pll_32x32_mult_ii
    port map (
        clk  => clk,
        a    => data_diff,
        b    => gain_d,
        sclr => synchronous_clear,
        p    => d_mult_output
    );
    	
	-- Division by 2^N_DIVIDE_D and saturation for D branch, adds 1 cycle of delay:
    d_saturation_inst: entity work.resize_with_saturation
    GENERIC MAP (
        N_INPUT  => d_mult_output'length-N_DIVIDE_D-18-3,
        N_OUTPUT => d_out'length
    )
    PORT MAP (
        clk => clk,
        synchronous_clear => synchronous_clear,
        data_in           => d_mult_output(d_mult_output'length-1 downto N_DIVIDE_D+18+3),
        railed_positive   => d_railed_positive,
        railed_negative   => d_railed_negative,
        data_out          => d_out
    );
    
    
    
			

	
	-- Output summing node
	----------------------------------------------------------------
	-- Output_sum was expanded a little bit to never overflow (we're summing three inputs that are already saturated to the output range and so we need only 2 extra bits to handle the full result
	-- This assumes that all three inputs have been properly saturated beforehand
	with synchronous_clear select
		-- JDD 12-08-2016: disabled D branch to try to make it fit into the smallest Zynq (Red Pitaya)
		-- JDD 15-06-2017: re-enabled D branch since there was enough DSP slices
		output_sum <=	resize(signed(p_out),			N_OUTPUT+2) + 
						resize(signed(i_out),			N_OUTPUT+2) + 
						resize(signed(ii_out),			N_OUTPUT+2) + 
						resize(signed(d_out),			N_OUTPUT+2) when '0',
						(others => '0') 							when others;

		--output_sum <=	resize(signed(p_out),			N_OUTPUT+2) + 
		--				resize(signed(i_out),			N_OUTPUT+2) + 
		--				resize(signed(ii_out),			N_OUTPUT+2) when '0',
		--				(others => '0') 							when others;
						
	-- Saturation for output sum, adds 1 cycle of delay:
   out_saturation_inst: entity work.resize_with_saturation
	GENERIC MAP (
		N_INPUT => N_OUTPUT+2,
		N_OUTPUT => N_OUTPUT
	)
	PORT MAP (
          clk => clk,
	      synchronous_clear => synchronous_clear,
          data_in => std_logic_vector(output_sum),
          railed_positive => sum_railed_positive,
          railed_negative => sum_railed_negative,
          data_out => data_out
        );
	
	
	-- Indicate the internal saturation state:
	-- We add two registers to help with the routing:
	process (clk)
	begin
		if rising_edge(clk) then
			saturated_high_internal <= (sum_railed_positive or p_railed_positive or i_railed_positive or ii_railed_positive or d_railed_positive or second_stage_railed_positive);
			saturated_low_internal 	<=	(sum_railed_negative or p_railed_negative or i_railed_negative or ii_railed_negative or d_railed_negative or second_stage_railed_negative);
			-- extra register stage:
			saturated_high	 <= saturated_high_internal;
			saturated_low	 <= saturated_low_internal;
		end if;
	end process;
	

	
end Behavioral;

