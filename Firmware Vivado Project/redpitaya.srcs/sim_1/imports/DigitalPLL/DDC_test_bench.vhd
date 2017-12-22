--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   13:13:12 10/22/2013
-- Design Name:   
-- Module Name:   C:/Xilinx_Projects/PLL_2013_test1_ML605/DDC_test_bench.vhd
-- Project Name:  PLL_2013_test1_ML605
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: DDC
-- 
-- Dependencies:
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
--
-- Notes: 
-- This testbench has been automatically generated using types std_logic and
-- std_logic_vector for the ports of the unit under test.  Xilinx recommends
-- that these types always be used for the top-level I/O of a design in order
-- to guarantee that the testbench will bind correctly to the post-implementation 
-- simulation model.
--------------------------------------------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
 
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
USE ieee.numeric_std.ALL;
 
ENTITY DDC_test_bench IS
END DDC_test_bench;
 
ARCHITECTURE behavior OF DDC_test_bench IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT DDC
	Generic(
		INPUT_DATA_WIDTH : positive;
		WRAPPED_PHASE_WIDTH : positive
	);
    PORT(
         rst : IN  std_logic;
         clk : IN  std_logic;
         data_input : IN  std_logic_vector(15 downto 0);
         reference_frequency : IN  std_logic_vector(47 downto 0);
			boxcar_filter_size : in std_logic_vector(12-1 downto 0);
         amplitude : OUT  std_logic_vector(11 downto 0);
         wrapped_phase : OUT  std_logic_vector(9 downto 0);
         inst_frequency : OUT  std_logic_vector(9 downto 0)
        );
    END COMPONENT;
    

   --Inputs
   signal rst : std_logic := '0';
   signal clk : std_logic := '0';
   signal data_input : std_logic_vector(15 downto 0) := (others => '0');
   signal reference_frequency : std_logic_vector(47 downto 0) := b"000011001100110011001100110011001100110011001101";	-- 10 MHz
	signal input_signal_frequency : std_logic_vector(47 downto 0) := b"000011001100110011001100110011001100110011001101";	-- 10 MHz
	signal boxcar_filter_size : std_logic_vector(12-1 downto 0) := std_logic_vector(to_unsigned(20, 12));	-- 10 MHz

 	--Outputs
   signal amplitude : std_logic_vector(11 downto 0);
   signal wrapped_phase : std_logic_vector(9 downto 0);
   signal inst_frequency : std_logic_vector(9 downto 0);

   -- Clock period definitions
   constant clk_period : time := 10 ns;
	
	
	-- The Core which generates sine and cosine to test the DDC
	component LO_DDS
		port (
--		clk: in std_logic;
--		pinc_in: in std_logic_vector(47 downto 0);
--		cosine: out std_logic_vector(15 downto 0);
--		sine: out std_logic_vector(15 downto 0);
--		phase_out: out std_logic_vector(47 downto 0));
        aclk : IN STD_LOGIC;
        s_axis_phase_tvalid : IN STD_LOGIC;
        s_axis_phase_tdata : IN STD_LOGIC_VECTOR(47 DOWNTO 0);  -- phase increments
        m_axis_data_tvalid : OUT STD_LOGIC;
        m_axis_data_tdata : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);  -- cos and sine (16 bits signed each)
        m_axis_phase_tvalid : OUT STD_LOGIC;
        m_axis_phase_tdata : OUT STD_LOGIC_VECTOR(47 DOWNTO 0)  -- output phase, not used in this module
        );
	end component;
	
	signal test_cosine : std_logic_vector(15 downto 0);
	signal DDC_input_signal : std_logic_vector(15 downto 0);
	signal pulses : std_logic_vector(15 downto 0) := (others => '0');
	signal clock_counter : unsigned(15 downto 0) := (others => '0');
	
	signal lo_dds_m_axis_data_tdata : STD_LOGIC_VECTOR(31 DOWNTO 0);
BEGIN

-- Compute cos() and sin()
	LO_DDS_inst : LO_DDS
			port map (
--				clk => clk,
--				pinc_in => input_signal_frequency,
--				cosine => test_cosine,
--				sine => open,
--				phase_out => open);
				aclk                    => clk,
                s_axis_phase_tvalid     => '1',
                s_axis_phase_tdata      => input_signal_frequency,
                m_axis_data_tvalid      => open,
                m_axis_data_tdata       => lo_dds_m_axis_data_tdata,
                m_axis_phase_tvalid     => open,
                m_axis_phase_tdata      => open
                );
    test_cosine  <= lo_dds_m_axis_data_tdata(15 downto 0);
--    DDS_sine_tmp    <= lo_dds_m_axis_data_tdata(31 downto 16);
				
	DDC_input_signal(15 downto 0) <= test_cosine(15) & test_cosine(15) & test_cosine(15 downto 0+2);
	data_input <= std_logic_vector(signed(DDC_input_signal) + signed(pulses));
	
	process (clk)
	begin
		if rising_edge(clk) then
			if clock_counter = 0 then
				pulses <= std_logic_vector(to_signed(10000, pulses'length));
				clock_counter <= to_unsigned(100, clock_counter'length);
			else
				pulses <= std_logic_vector(to_signed(0, pulses'length));
				clock_counter <= clock_counter - 1;
			end if;
		end if;
	end process;
	
	-- Instantiate the Unit Under Test (UUT)
   uut: DDC
	GENERIC MAP (
		INPUT_DATA_WIDTH => 16,
		WRAPPED_PHASE_WIDTH => 10
	
	)
	PORT MAP (
          rst => rst,
          clk => clk,
          data_input => data_input,
          reference_frequency => reference_frequency,
			 boxcar_filter_size => boxcar_filter_size,
          amplitude => amplitude,
          wrapped_phase => wrapped_phase,
          inst_frequency => inst_frequency
        );

   -- Clock process definitions
   clk_process :process
   begin
		clk <= '0';
		wait for clk_period/2;
		clk <= '1';
		wait for clk_period/2;
   end process;
 

   -- Stimulus process
   stim_proc: process
   begin		
      -- hold reset state for 100 ns.
			rst <= '1';
      wait for 100 ns;	
			rst <= '0';
      wait for clk_period*1000;
			input_signal_frequency <= (others => '0');	-- 0 MHz
			reference_frequency <= (others => '0');	-- 0 MHz
			
			
			
			
      wait for clk_period*1000;
			reference_frequency <=    b"000011001100110011001100110011001100110011001101";	-- 10 MHz
			input_signal_frequency <= b"000011110101110000101000111101011100001010001111";	-- 12 MHz = 10 MHz + 200MHz/100 = 12MHz
			
      wait for clk_period*1000;
			input_signal_frequency <= b"000011001100110011001100110011001100110011001101";	-- 10 MHz
      -- insert stimulus here 

      wait;
   end process;

END;
