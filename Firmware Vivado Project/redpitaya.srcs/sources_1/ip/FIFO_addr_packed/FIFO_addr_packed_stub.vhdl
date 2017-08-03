-- Copyright 1986-2015 Xilinx, Inc. All Rights Reserved.
-- --------------------------------------------------------------------------------
-- Tool Version: Vivado v.2015.4 (win64) Build 1412921 Wed Nov 18 09:43:45 MST 2015
-- Date        : Tue Jul 04 16:23:00 2017
-- Host        : DESKTOP-OULANE9 running 64-bit major release  (build 9200)
-- Command     : write_vhdl -force -mode synth_stub
--               {d:/Users/Alex/Documents/GitHub/Frequency-comb-DPLL_v2/Frequency-comb-DPLL-DPLL-python3/Firmware Vivado
--               Project/redpitaya.srcs/sources_1/ip/FIFO_addr_packed/FIFO_addr_packed_stub.vhdl}
-- Design      : FIFO_addr_packed
-- Purpose     : Stub declaration of top-level module interface
-- Device      : xc7z010clg400-1
-- --------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity FIFO_addr_packed is
  Port ( 
    clk : in STD_LOGIC;
    srst : in STD_LOGIC;
    din : in STD_LOGIC_VECTOR ( 63 downto 0 );
    wr_en : in STD_LOGIC;
    rd_en : in STD_LOGIC;
    dout : out STD_LOGIC_VECTOR ( 63 downto 0 );
    full : out STD_LOGIC;
    wr_ack : out STD_LOGIC;
    empty : out STD_LOGIC
  );

end FIFO_addr_packed;

architecture stub of FIFO_addr_packed is
attribute syn_black_box : boolean;
attribute black_box_pad_pin : string;
attribute syn_black_box of stub : architecture is true;
attribute black_box_pad_pin of stub : architecture is "clk,srst,din[63:0],wr_en,rd_en,dout[63:0],full,wr_ack,empty";
attribute x_core_info : string;
attribute x_core_info of stub : architecture is "fifo_generator_v13_0_1,Vivado 2015.4";
begin
end;
