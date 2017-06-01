----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    15:00:29 02/24/2014 
-- Design Name: 
-- Module Name:    ddc_frontend_lowpass_filter - Behavioral 
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
-- Description: Implements a cascade of : (4-pts boxcar) -> (2-pts boxcar) -> (2-pts boxcar) 
-- In MATLAB notation, the operation of the filter is: y = round(filter(conv(ones(2, 1), conv(ones(2, 1), ones(4, 1))), 1, x)/16)
-- Overall DC gain is equal to 1.  There are 5 extra clock cycles of processing delay, in addition to any group delay from the impulse response
-- 
-- Description for the new version with a filter select input: Simple low-pass filter, tuned for the FPGA-based frequency comb phase-locks.  There are two different filters.
-- filter_select = b"00" selects a convolution of 2x 2-samples long boxcar filters by a 4-samples long boxcar, so that the filter coefficients are: [1 3 4 4 3 1].
-- This filter has 3 zeros at Nyquist which is where most of the undesired energy has in this application when the input tone is tuned at 25 MHz. (this filter is applied after the complex multiplication with the LO, making the undesired tone appear at -50 MHz)
-- filter_select = b"01" selects a convolution of a 4-samples long boxcar with a 16-samples long boxcar.
-- the output is divided either by 16 to cancel the wideband filter gain, or 16*4 to cancel the narrowband filter.
-- filter_select = b"10" selects a convolution of a 16-taps minimum-phase FIR and a 2-points boxcar
--
-- the wideband filter has 5 cycles of processing delay in addition to the filter's group delay, while
-- the narrowband filter has 4 cycles of processing delay in addition to the filter's group delay.
-- the minimum-phase fir has 10 cycles of processing delay in addition to the filter's group delay. EDIT: In the new version for the Zynq (Red Pitaya), the delay is now 9 cycles instead of 10.



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

entity ddc_frontend_lowpass_filter is
	Generic (
		INPUT_SIZE : integer := 16
	);
    Port (
		rst           : in  std_logic;
		clk           : in  std_logic;
		clk_times_N   : in  std_logic;
		data_input    : in  std_logic_vector (INPUT_SIZE-1 downto 0);
		filter_select : in  std_logic_vector(1 downto 0);
		data_output   : out std_logic_vector (INPUT_SIZE-1 downto 0)

	);
end ddc_frontend_lowpass_filter;

architecture Behavioral of ddc_frontend_lowpass_filter is
	-- intermediate signals for the wideband filter
	signal data_interm1 : std_logic_vector(INPUT_SIZE+2-1 downto 0) := (others => '0');
	signal data_interm2 : std_logic_vector(INPUT_SIZE+3-1 downto 0) := (others => '0');
	signal data_interm3 : std_logic_vector(INPUT_SIZE+4-1 downto 0) := (others => '0');
	
	-- signals for the narrowband filter (16 pts boxcar)
	constant LOG2_MAXIMUM_SIZE_16_PTS : integer := 5;
	constant N_16_PTS : std_logic_vector(LOG2_MAXIMUM_SIZE_16_PTS-1 downto 0) := std_logic_vector(to_unsigned(16, LOG2_MAXIMUM_SIZE_16_PTS));
	signal data_narrowband : std_logic_vector(16+5+2-1 downto 0);
	
	
	
	-- signals for the minimum phase FIR:
	signal data_to_fir_wide : std_logic_vector(17-1 downto 0) := (others => '0');
	signal data_to_fir : std_logic_vector(16-1 downto 0) := (others => '0');
	signal data_fir : std_logic_vector(16-1 downto 0) := (others => '0');
	COMPONENT ddc_minimum_phase_fir
    PORT (
        aclk : IN STD_LOGIC;
        s_axis_data_tvalid : IN STD_LOGIC;
        s_axis_data_tready : OUT STD_LOGIC;
        s_axis_data_tdata : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
        m_axis_data_tvalid : OUT STD_LOGIC;
        m_axis_data_tdata : OUT STD_LOGIC_VECTOR(15 DOWNTO 0)
	  );
	END COMPONENT;
	
	
	
	-- selects between the two filters and also cancels the filter gain:
	signal data_output_register : std_logic_vector(INPUT_SIZE-1 downto 0) := (others => '0');
	-- Divides the output of the filter by 2^BIT_SHIFT_AFTER_FILTER to keep gain approximately equal to 1.
	constant BIT_SHIFT_AFTER_WIDEBAND_FILTER : positive := 4;
	constant BIT_SHIFT_AFTER_NARROWBAND_FILTER : positive := 2+4;
begin

   boxcar_4_pts_filter_inst: entity work.boxcar_4_pts_filter
	GENERIC MAP (
		INPUT_SIZE => INPUT_SIZE
	)
	PORT MAP (
          clk => clk,
          data_input => data_input,
          data_output => data_interm1
        );

   boxcar_2_pts_filter_inst1: entity work.boxcar_2_pts_filter
	GENERIC MAP (
		INPUT_SIZE => data_interm1'length
	)
	PORT MAP (
          clk => clk,
          data_input => data_interm1,
          data_output => data_interm2
        );
		  
   boxcar_2_pts_filter_inst2: entity work.boxcar_2_pts_filter
	GENERIC MAP (
		INPUT_SIZE => data_interm2'length
	)
	PORT MAP (
          clk => clk,
          data_input => data_interm2,
          data_output => data_interm3
        );
		  
	boxcar_filter_16_pts_inst : entity work.adjustable_boxcar_filter_v2
	generic map (
		LOG2_MAXIMUM_SIZE => LOG2_MAXIMUM_SIZE_16_PTS,
		DATA_WIDTH => data_interm1'length
	) port map (
		rst => rst,
		clk => clk,
		
		input_data => data_interm1,
		filter_size => N_16_PTS,
		output_data => data_narrowband
	);
	
	-- 3rd filter option (filter_select = b"10":
	-- convolution of a 2-points boxcar + a 16-taps, minimum phase fir
   boxcar_2_pts_filter_inst3: entity work.boxcar_2_pts_filter
	GENERIC MAP (
		INPUT_SIZE => data_input'length
	)
	PORT MAP (
          clk => clk,
          data_input => data_input,
          data_output => data_to_fir_wide
        );
	data_to_fir <= data_to_fir_wide(data_to_fir'range);	-- this is not 100% clean since it can wrap for the largest inputs.

	-- Changed 13-08-2016 to fit the Red Pitaya Zynq, we now use a FIR that runs the multipliers at N times the data clk rate
	--ddc_minimum_phase_fir_inst: ddc_minimum_phase_fir
	--port map (
 --       aclk                => clk,
 --       s_axis_data_tvalid  => '1',
 --       s_axis_data_tready  => open,
 --       s_axis_data_tdata   => data_to_fir,
 --       m_axis_data_tvalid  => open,
 --       m_axis_data_tdata   => data_fir
	--	); 
		
	N_times_clk_FIR_wrapper_inst: entity work.N_times_clk_FIR_wrapper
	port map (
		clk_times_1 => clk,
		clk_times_N => clk_times_N,
		data_in     => data_to_fir,
		data_out    => data_fir
	);


	process (clk)
	begin
		if rising_edge(clk) then
			if filter_select = b"00" then
				-- wideband filter
				-- Cancel filter gain.  We add half an LSB before dividing in order to round the result instead of truncating:
				data_output_register <= std_logic_vector(resize(shift_right(signed(data_interm3) + to_signed(2**(BIT_SHIFT_AFTER_WIDEBAND_FILTER-1), data_interm3'length), BIT_SHIFT_AFTER_WIDEBAND_FILTER), data_output_register'length));
			elsif filter_select = b"01" then
				-- narrowband filter
				-- Cancel filter gain.  We add half an LSB before dividing in order to round the result instead of truncating:
				data_output_register <= std_logic_vector(resize(shift_right(signed(data_narrowband) + to_signed(2**(BIT_SHIFT_AFTER_NARROWBAND_FILTER-1), data_interm3'length), BIT_SHIFT_AFTER_NARROWBAND_FILTER), data_output_register'length));
			elsif filter_select = b"10" then
				-- wideband, minimum-phase fir filter.
				-- no need to cancel filter gain because it is done in the fir core
				data_output_register <= data_fir;
			end if;
		end if;
	end process;
	
	data_output <= data_output_register;
	
end Behavioral;

