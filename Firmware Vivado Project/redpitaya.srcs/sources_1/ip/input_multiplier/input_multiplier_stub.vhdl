-- Copyright 1986-2015 Xilinx, Inc. All Rights Reserved.
-- --------------------------------------------------------------------------------
-- Tool Version: Vivado v.2015.4 (win64) Build 1412921 Wed Nov 18 09:43:45 MST 2015
-- Date        : Sat Jun 23 00:23:11 2018
-- Host        : jdbureau running 64-bit major release  (build 9200)
-- Command     : write_vhdl -force -mode synth_stub {D:/Repo/Frequency-comb-DPLL/Firmware Vivado
--               Project/redpitaya.srcs/sources_1/ip/input_multiplier/input_multiplier_stub.vhdl}
-- Design      : input_multiplier
-- Purpose     : Stub declaration of top-level module interface
-- Device      : xc7z010clg400-1
-- --------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity input_multiplier is
  Port ( 
    CLK : in STD_LOGIC;
    A : in STD_LOGIC_VECTOR ( 15 downto 0 );
    B : in STD_LOGIC_VECTOR ( 15 downto 0 );
    P : out STD_LOGIC_VECTOR ( 31 downto 0 )
  );

end input_multiplier;

architecture stub of input_multiplier is
attribute syn_black_box : boolean;
attribute black_box_pad_pin : string;
attribute syn_black_box of stub : architecture is true;
attribute black_box_pad_pin of stub : architecture is "CLK,A[15:0],B[15:0],P[31:0]";
attribute x_core_info : string;
attribute x_core_info of stub : architecture is "mult_gen_v12_0_10,Vivado 2015.4";
begin
end;
