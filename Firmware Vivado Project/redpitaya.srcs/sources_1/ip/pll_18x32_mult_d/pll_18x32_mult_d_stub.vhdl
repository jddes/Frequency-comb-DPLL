-- Copyright 1986-2015 Xilinx, Inc. All Rights Reserved.
-- --------------------------------------------------------------------------------
-- Tool Version: Vivado v.2015.4 (win64) Build 1412921 Wed Nov 18 09:43:45 MST 2015
-- Date        : Tue Jul 04 15:50:24 2017
-- Host        : DESKTOP-OULANE9 running 64-bit major release  (build 9200)
-- Command     : write_vhdl -force -mode synth_stub {D:/Users/Alex/Documents/GitHub/Frequency-comb-DPLL/Firmware Vivado
--               Project/redpitaya.srcs/sources_1/ip/pll_18x32_mult_d/pll_18x32_mult_d_stub.vhdl}
-- Design      : pll_18x32_mult_d
-- Purpose     : Stub declaration of top-level module interface
-- Device      : xc7z010clg400-1
-- --------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity pll_18x32_mult_d is
  Port ( 
    CLK : in STD_LOGIC;
    A : in STD_LOGIC_VECTOR ( 17 downto 0 );
    B : in STD_LOGIC_VECTOR ( 31 downto 0 );
    SCLR : in STD_LOGIC;
    P : out STD_LOGIC_VECTOR ( 49 downto 0 )
  );

end pll_18x32_mult_d;

architecture stub of pll_18x32_mult_d is
attribute syn_black_box : boolean;
attribute black_box_pad_pin : string;
attribute syn_black_box of stub : architecture is true;
attribute black_box_pad_pin of stub : architecture is "CLK,A[17:0],B[31:0],SCLR,P[49:0]";
attribute x_core_info : string;
attribute x_core_info of stub : architecture is "mult_gen_v12_0_10,Vivado 2015.4";
begin
end;
