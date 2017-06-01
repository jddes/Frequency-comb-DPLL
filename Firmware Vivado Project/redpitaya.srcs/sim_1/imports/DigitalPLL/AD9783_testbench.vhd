--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   13:47:16 02/25/2014
-- Design Name:   
-- Module Name:   C:/_JD/FPGA_code/Daves_FPGA_box/SimplePI/AD9783_testbench.vhd
-- Project Name:  SuperLaserLand
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: AD9783
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
 
ENTITY AD9783_testbench IS
END AD9783_testbench;
 
ARCHITECTURE behavior OF AD9783_testbench IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT AD9783
    PORT(
         clk_in : IN  std_logic;
         rst_in : IN  std_logic;
         cmd_trig_in : IN  std_logic;
         cmd_addr_in : IN  std_logic_vector(15 downto 0);
         cmd_data_in : IN  std_logic_vector(15 downto 0);
         cmd_data_out : OUT  std_logic_vector(15 downto 0);
         rst_out : OUT  std_logic;
         spi_scs_out : OUT  std_logic;
         spi_sck_out : OUT  std_logic;
         spi_sdo_out : OUT  std_logic;
         spi_sdi_in : IN  std_logic;
         DAC0_in : IN  std_logic_vector(15 downto 0);
         DAC1_in : IN  std_logic_vector(15 downto 0);
         CLK_out_p : OUT  std_logic;
         CLK_out_n : OUT  std_logic;
         DCI_out_p : OUT  std_logic;
         DCI_out_n : OUT  std_logic;
         D_out_p : OUT  std_logic_vector(15 downto 0);
         D_out_n : OUT  std_logic_vector(15 downto 0)
        );
    END COMPONENT;
    

   --Inputs
   signal clk_in : std_logic := '0';
   signal rst_in : std_logic := '0';
   signal cmd_trig_in : std_logic := '0';
   signal cmd_addr_in : std_logic_vector(15 downto 0) := (others => '0');
   signal cmd_data_in : std_logic_vector(15 downto 0) := (others => '0');
   signal spi_sdi_in : std_logic := '0';
   signal DAC0_in : std_logic_vector(15 downto 0) := (others => '1');
   signal DAC1_in : std_logic_vector(15 downto 0) := (others => '0');

 	--Outputs
   signal cmd_data_out : std_logic_vector(15 downto 0);
   signal rst_out : std_logic;
   signal spi_scs_out : std_logic;
   signal spi_sck_out : std_logic;
   signal spi_sdo_out : std_logic;
   signal CLK_out_p : std_logic;
   signal CLK_out_n : std_logic;
   signal DCI_out_p : std_logic;
   signal DCI_out_n : std_logic;
   signal D_out_p : std_logic_vector(15 downto 0);
   signal D_out_n : std_logic_vector(15 downto 0);

   -- Clock period definitions
   constant clk_in_period : time := 10 ns;
   constant CLK_out_p_period : time := 10 ns;
   constant CLK_out_n_period : time := 10 ns;
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: AD9783 PORT MAP (
          clk_in => clk_in,
          rst_in => rst_in,
          cmd_trig_in => cmd_trig_in,
          cmd_addr_in => cmd_addr_in,
          cmd_data_in => cmd_data_in,
          cmd_data_out => cmd_data_out,
          rst_out => rst_out,
          spi_scs_out => spi_scs_out,
          spi_sck_out => spi_sck_out,
          spi_sdo_out => spi_sdo_out,
          spi_sdi_in => spi_sdi_in,
          DAC0_in => DAC0_in,
          DAC1_in => DAC1_in,
          CLK_out_p => CLK_out_p,
          CLK_out_n => CLK_out_n,
          DCI_out_p => DCI_out_p,
          DCI_out_n => DCI_out_n,
          D_out_p => D_out_p,
          D_out_n => D_out_n
        );

   -- Clock process definitions
   clk_in_process :process
   begin
		clk_in <= '0';
		wait for clk_in_period/2;
		clk_in <= '1';
		wait for clk_in_period/2;
   end process;
 
--   CLK_out_p_process :process
--   begin
--		CLK_out_p <= '0';
--		wait for CLK_out_p_period/2;
--		CLK_out_p <= '1';
--		wait for CLK_out_p_period/2;
--   end process;
-- 
--   CLK_out_n_process :process
--   begin
--		CLK_out_n <= '0';
--		wait for CLK_out_n_period/2;
--		CLK_out_n <= '1';
--		wait for CLK_out_n_period/2;
--   end process;
 

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
