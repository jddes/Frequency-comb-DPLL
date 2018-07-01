--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   09:21:12 07/23/2015
-- Design Name:   
-- Module Name:   H:/VHDL/digital_servo/quantizer_testbench.vhd
-- Project Name:  SuperLaserLand
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: quantizer
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
USE ieee.math_real.ALL;
USE ieee.numeric_std.ALL;
 
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--USE ieee.numeric_std.ALL;
 
ENTITY quantizer_testbench IS
END quantizer_testbench;
 
ARCHITECTURE behavior OF quantizer_testbench IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT quantizer
    PORT(
         clk : IN  std_logic;
         di : IN  std_logic_vector(15 downto 0);
         do : OUT  std_logic_vector(9 downto 0)
        );
    END COMPONENT;
    

   --Inputs
   signal clk : std_logic := '0';
   signal di : std_logic_vector(15 downto 0) := (others => '0');

 	--Outputs
   signal do : std_logic_vector(9 downto 0);

   -- Clock period definitions
   constant clk_period : time := 10 ns;
 
    -- Stimulus  
    signal stim: std_logic_vector(15 DOWNTO 0) := (others => '0');

    signal s1 : signed(31 downto 0) := (others => '0');
    signal s2 : signed(31 downto 0) := (others => '0');
    signal s3 : signed(31 downto 0) := (others => '0');
    signal d2 : signed(31 downto 0) := (others => '0');
    signal d3 : signed(31 downto 0) := (others => '0');
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: quantizer PORT MAP (
          clk => clk,
          di => di,
          do => do
        );

   -- Clock process definitions
   clk_process :process
   begin
		clk <= '0';
		wait for clk_period/2;
		clk <= '1';
		wait for clk_period/2;
   end process;
 
    process (clk) is
        VARIABLE seed1, seed2: positive;
        VARIABLE rand: real;
        VARIABLE int_rand: integer;
    begin
        if rising_edge(clk) then 
            UNIFORM(seed1, seed2, rand);
            int_rand := INTEGER(TRUNC((rand-0.5)*277.0+4537.0));
            stim <= std_logic_vector(to_signed(int_rand, stim'LENGTH));
            
            
            s1 <= s1 + resize(signed(di), 32);
            s2 <= s2 + shift_left(resize(signed(do), 32), 16-10);
            s3 <= s3 + shift_left(resize(signed(di(16-1 downto 16-10)), 32), 16-10);
        end if;
    end process;
    d2 <= shift_right(s2 - s1, 16-10);
    d3 <= shift_right(s3 - s1, 16-10);
    
    di <= stim;

   -- Stimulus process
   stim_proc: process
   begin		
      -- hold reset state for 100 ns.
      wait for 100 ns;	

      wait for clk_period*10;

      -- insert stimulus here 

      wait;
   end process;

END;
