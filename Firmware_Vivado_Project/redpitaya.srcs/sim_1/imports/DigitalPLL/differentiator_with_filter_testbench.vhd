--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   16:20:27 05/06/2015
-- Design Name:   
-- Module Name:   H:/VHDL/digital_servo/differentiator_with_filter_testbench.vhd
-- Project Name:  SuperLaserLand
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: differentiator_with_filter
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
USE ieee.numeric_std.ALL;
 
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--USE ieee.numeric_std.ALL;
 
ENTITY differentiator_with_filter_testbench IS
END differentiator_with_filter_testbench;
 
ARCHITECTURE behavior OF differentiator_with_filter_testbench IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
component differentiator_with_filter is
    generic (
        N_DATA  : integer
    );
    port (
        clk      : in  std_logic;
        coef     : in  std_logic_vector(18-1 downto 0);
        data_in  : in  std_logic_vector(N_DATA-1 downto 0);
        data_out : out std_logic_vector(18-1 downto 0)
    );
end component;
    
    constant N_COEF   : integer := 18;
    constant N_DATA  : integer := 16;

   --Inputs
   signal clk : std_logic := '0';
   signal coef : std_logic_vector(N_COEF-1 downto 0) := (others => '0');
   signal data_in : std_logic_vector(N_DATA-1 downto 0) := (others => '0');

 	--Outputs
   signal data_out : std_logic_vector(18-1 downto 0);

   -- Clock period definitions
   constant clk_period : time := 10 ns;
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: differentiator_with_filter
   GENERIC MAP (
   N_DATA => N_DATA
   )
   PORT MAP (
          clk => clk,
          coef => coef,
          data_in => data_in,
          data_out => data_out
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
      wait for 100 ns;	

      wait for clk_period*10;
      
      wait until falling_edge(clk);
      coef <= std_logic_vector(to_signed(65536, N_COEF));
      
      wait until falling_edge(clk);
      data_in <= std_logic_vector(to_signed(10000, N_DATA));
      wait until falling_edge(clk);
      data_in <= std_logic_vector(to_signed(0, N_DATA));

      -- insert stimulus here 

      wait;
   end process;

END;
