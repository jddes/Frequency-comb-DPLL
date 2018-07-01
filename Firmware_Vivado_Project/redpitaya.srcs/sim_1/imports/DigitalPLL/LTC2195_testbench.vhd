--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   16:34:19 02/06/2014
-- Design Name:   
-- Module Name:   C:/_JD/FPGA_code/Daves_FPGA_box/SimplePI/LTC2195_testbench.vhd
-- Project Name:  SuperLaserLand
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: LTC2195
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
--USE ieee.numeric_std.ALL;
 
ENTITY LTC2195_testbench IS
END LTC2195_testbench;
 
ARCHITECTURE behavior OF LTC2195_testbench IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT LTC2195
    PORT(
         clk_in : IN  std_logic;
         rst_in : IN  std_logic;
         cmd_trig_in : IN  std_logic;
         cmd_addr_in : IN  std_logic_vector(15 downto 0);
         cmd_data_in : IN  std_logic_vector(15 downto 0);
         spi_scs_out : OUT  std_logic;
         spi_sck_out : OUT  std_logic;
         spi_sdo_out : OUT  std_logic;
         spi_sdi_in : IN  std_logic;
         ENC_out_p : OUT  std_logic;
         ENC_out_n : OUT  std_logic;
         DCO_in_p : IN  std_logic;
         DCO_in_n : IN  std_logic;
         FR_in_p : IN  std_logic;
         FR_in_n : IN  std_logic;
         D0_in_p : IN  std_logic_vector(3 downto 0);
         D0_in_n : IN  std_logic_vector(3 downto 0);
         D1_in_p : IN  std_logic_vector(3 downto 0);
         D1_in_n : IN  std_logic_vector(3 downto 0);
         ADC0_out : OUT  std_logic_vector(15 downto 0);
         ADC1_out : OUT  std_logic_vector(15 downto 0);
         FR_out : OUT  std_logic_vector(3 downto 0)
        );
    END COMPONENT;
    

   --Inputs
   signal clk_in : std_logic := '0';
   signal rst_in : std_logic := '0';
   signal cmd_trig_in : std_logic := '0';
   signal cmd_addr_in : std_logic_vector(15 downto 0) := (others => '0');
   signal cmd_data_in : std_logic_vector(15 downto 0) := (others => '0');
   signal spi_sdi_in : std_logic := '0';
   signal DCO_in_p : std_logic := '0';
   signal DCO_in_n : std_logic := '0';
   signal FR_in_p : std_logic := '0';
   signal FR_in_n : std_logic := '0';
   signal D0_in_p : std_logic_vector(3 downto 0) := (others => '0');
   signal D0_in_n : std_logic_vector(3 downto 0) := (others => '0');
   signal D1_in_p : std_logic_vector(3 downto 0) := (others => '0');
   signal D1_in_n : std_logic_vector(3 downto 0) := (others => '0');

 	--Outputs
   signal spi_scs_out : std_logic;
   signal spi_sck_out : std_logic;
   signal spi_sdo_out : std_logic;
   signal ENC_out_p : std_logic;
   signal ENC_out_n : std_logic;
   signal ADC0_out : std_logic_vector(15 downto 0);
   signal ADC1_out : std_logic_vector(15 downto 0);
   signal FR_out : std_logic_vector(3 downto 0);

   -- Clock period definitions
   constant clk_in_period : time := 10 ns;
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: LTC2195 PORT MAP (
          clk_in => clk_in,
          rst_in => rst_in,
          cmd_trig_in => cmd_trig_in,
          cmd_addr_in => cmd_addr_in,
          cmd_data_in => cmd_data_in,
          spi_scs_out => spi_scs_out,
          spi_sck_out => spi_sck_out,
          spi_sdo_out => spi_sdo_out,
          spi_sdi_in => spi_sdi_in,
          ENC_out_p => ENC_out_p,
          ENC_out_n => ENC_out_n,
          DCO_in_p => DCO_in_p,
          DCO_in_n => DCO_in_n,
          FR_in_p => FR_in_p,
          FR_in_n => FR_in_n,
          D0_in_p => D0_in_p,
          D0_in_n => D0_in_n,
          D1_in_p => D1_in_p,
          D1_in_n => D1_in_n,
          ADC0_out => ADC0_out,
          ADC1_out => ADC1_out,
          FR_out => FR_out
        );

   -- Clock process definitions
   clk_in_process :process
   begin
		clk_in <= '0';
		wait for clk_in_period/2;
		clk_in <= '1';
		wait for clk_in_period/2;
   end process;
 

   -- Stimulus process
   stim_proc: process
   begin		
      -- hold reset state for 100 ns.
			rst_in <= '1';
      wait for 100 ns;	
			rst_in <= '0';
      wait for clk_in_period*10;

      -- insert stimulus here 

      wait;
   end process;

END;
