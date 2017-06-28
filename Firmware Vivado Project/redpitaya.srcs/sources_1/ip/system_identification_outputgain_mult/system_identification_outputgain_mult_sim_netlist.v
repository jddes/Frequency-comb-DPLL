// Copyright 1986-2015 Xilinx, Inc. All Rights Reserved.
// --------------------------------------------------------------------------------
// Tool Version: Vivado v.2015.4 (win64) Build 1412921 Wed Nov 18 09:43:45 MST 2015
// Date        : Wed Jun 28 16:50:42 2017
// Host        : DESKTOP-OULANE9 running 64-bit major release  (build 9200)
// Command     : write_verilog -force -mode funcsim {D:/Users/Alex/Documents/GitHub/Frequency-comb-DPLL/Firmware Vivado
//               Project/redpitaya.srcs/sources_1/ip/system_identification_outputgain_mult/system_identification_outputgain_mult_sim_netlist.v}
// Design      : system_identification_outputgain_mult
// Purpose     : This verilog netlist is a functional simulation representation of the design and should not be modified
//               or synthesized. This netlist cannot be used for SDF annotated simulation.
// Device      : xc7z010clg400-1
// --------------------------------------------------------------------------------
`timescale 1 ps / 1 ps

(* CHECK_LICENSE_TYPE = "system_identification_outputgain_mult,mult_gen_v12_0_10,{}" *) (* core_generation_info = "system_identification_outputgain_mult,mult_gen_v12_0_10,{x_ipProduct=Vivado 2015.4,x_ipVendor=xilinx.com,x_ipLibrary=ip,x_ipName=mult_gen,x_ipVersion=12.0,x_ipCoreRevision=10,x_ipLanguage=VERILOG,x_ipSimLanguage=MIXED,C_VERBOSITY=0,C_MODEL_TYPE=0,C_OPTIMIZE_GOAL=1,C_XDEVICEFAMILY=zynq,C_HAS_CE=0,C_HAS_SCLR=1,C_LATENCY=2,C_A_WIDTH=16,C_A_TYPE=0,C_B_WIDTH=18,C_B_TYPE=0,C_OUT_HIGH=30,C_OUT_LOW=15,C_MULT_TYPE=1,C_CE_OVERRIDES_SCLR=0,C_CCM_IMP=0,C_B_VALUE=10000001,C_HAS_ZERO_DETECT=0,C_ROUND_OUTPUT=0,C_ROUND_PT=0}" *) (* downgradeipidentifiedwarnings = "yes" *) 
(* x_core_info = "mult_gen_v12_0_10,Vivado 2015.4" *) 
(* NotValidForBitStream *)
module system_identification_outputgain_mult
   (CLK,
    A,
    B,
    SCLR,
    P);
  (* x_interface_info = "xilinx.com:signal:clock:1.0 clk_intf CLK" *) input CLK;
  (* x_interface_info = "xilinx.com:signal:data:1.0 a_intf DATA" *) input [15:0]A;
  (* x_interface_info = "xilinx.com:signal:data:1.0 b_intf DATA" *) input [17:0]B;
  (* x_interface_info = "xilinx.com:signal:reset:1.0 sclr_intf RST" *) input SCLR;
  (* x_interface_info = "xilinx.com:signal:data:1.0 p_intf DATA" *) output [15:0]P;

  wire [15:0]A;
  wire [17:0]B;
  wire CLK;
  wire [15:0]P;
  wire SCLR;
  wire [47:0]NLW_U0_PCASC_UNCONNECTED;
  wire [1:0]NLW_U0_ZERO_DETECT_UNCONNECTED;

  (* C_A_TYPE = "0" *) 
  (* C_A_WIDTH = "16" *) 
  (* C_B_TYPE = "0" *) 
  (* C_B_VALUE = "10000001" *) 
  (* C_B_WIDTH = "18" *) 
  (* C_CCM_IMP = "0" *) 
  (* C_CE_OVERRIDES_SCLR = "0" *) 
  (* C_HAS_CE = "0" *) 
  (* C_HAS_SCLR = "1" *) 
  (* C_HAS_ZERO_DETECT = "0" *) 
  (* C_LATENCY = "2" *) 
  (* C_MODEL_TYPE = "0" *) 
  (* C_MULT_TYPE = "1" *) 
  (* C_OPTIMIZE_GOAL = "1" *) 
  (* C_OUT_HIGH = "30" *) 
  (* C_OUT_LOW = "15" *) 
  (* C_ROUND_OUTPUT = "0" *) 
  (* C_ROUND_PT = "0" *) 
  (* C_VERBOSITY = "0" *) 
  (* C_XDEVICEFAMILY = "zynq" *) 
  (* downgradeipidentifiedwarnings = "yes" *) 
  system_identification_outputgain_mult_mult_gen_v12_0_10 U0
       (.A(A),
        .B(B),
        .CE(1'b1),
        .CLK(CLK),
        .P(P),
        .PCASC(NLW_U0_PCASC_UNCONNECTED[47:0]),
        .SCLR(SCLR),
        .ZERO_DETECT(NLW_U0_ZERO_DETECT_UNCONNECTED[1:0]));
endmodule

(* C_A_TYPE = "0" *) (* C_A_WIDTH = "16" *) (* C_B_TYPE = "0" *) 
(* C_B_VALUE = "10000001" *) (* C_B_WIDTH = "18" *) (* C_CCM_IMP = "0" *) 
(* C_CE_OVERRIDES_SCLR = "0" *) (* C_HAS_CE = "0" *) (* C_HAS_SCLR = "1" *) 
(* C_HAS_ZERO_DETECT = "0" *) (* C_LATENCY = "2" *) (* C_MODEL_TYPE = "0" *) 
(* C_MULT_TYPE = "1" *) (* C_OPTIMIZE_GOAL = "1" *) (* C_OUT_HIGH = "30" *) 
(* C_OUT_LOW = "15" *) (* C_ROUND_OUTPUT = "0" *) (* C_ROUND_PT = "0" *) 
(* C_VERBOSITY = "0" *) (* C_XDEVICEFAMILY = "zynq" *) (* ORIG_REF_NAME = "mult_gen_v12_0_10" *) 
(* downgradeipidentifiedwarnings = "yes" *) 
module system_identification_outputgain_mult_mult_gen_v12_0_10
   (CLK,
    A,
    B,
    CE,
    SCLR,
    ZERO_DETECT,
    P,
    PCASC);
  input CLK;
  input [15:0]A;
  input [17:0]B;
  input CE;
  input SCLR;
  output [1:0]ZERO_DETECT;
  output [15:0]P;
  output [47:0]PCASC;

  wire [15:0]A;
  wire [17:0]B;
  wire CE;
  wire CLK;
  wire [15:0]P;
  wire [47:0]PCASC;
  wire SCLR;
  wire [1:0]ZERO_DETECT;

  (* C_A_TYPE = "0" *) 
  (* C_A_WIDTH = "16" *) 
  (* C_B_TYPE = "0" *) 
  (* C_B_VALUE = "10000001" *) 
  (* C_B_WIDTH = "18" *) 
  (* C_CCM_IMP = "0" *) 
  (* C_CE_OVERRIDES_SCLR = "0" *) 
  (* C_HAS_CE = "0" *) 
  (* C_HAS_SCLR = "1" *) 
  (* C_HAS_ZERO_DETECT = "0" *) 
  (* C_LATENCY = "2" *) 
  (* C_MODEL_TYPE = "0" *) 
  (* C_MULT_TYPE = "1" *) 
  (* C_OPTIMIZE_GOAL = "1" *) 
  (* C_OUT_HIGH = "30" *) 
  (* C_OUT_LOW = "15" *) 
  (* C_ROUND_OUTPUT = "0" *) 
  (* C_ROUND_PT = "0" *) 
  (* C_VERBOSITY = "0" *) 
  (* C_XDEVICEFAMILY = "zynq" *) 
  (* downgradeipidentifiedwarnings = "yes" *) 
  system_identification_outputgain_mult_mult_gen_v12_0_10_viv i_mult
       (.A(A),
        .B(B),
        .CE(CE),
        .CLK(CLK),
        .P(P),
        .PCASC(PCASC),
        .SCLR(SCLR),
        .ZERO_DETECT(ZERO_DETECT));
endmodule
`pragma protect begin_protected
`pragma protect version = 1
`pragma protect encrypt_agent = "XILINX"
`pragma protect encrypt_agent_info = "Xilinx Encryption Tool 2014"
`pragma protect key_keyowner = "Cadence Design Systems.", key_keyname= "cds_rsa_key", key_method = "rsa"
`pragma protect encoding = (enctype = "BASE64", line_length = 76, bytes = 64)
`pragma protect key_block
VllxWgRrugvi2fu1Kh4iL+ZkJA5TtZ+LGWCqHHHE1lCRjHiMOz5M3L3abI/BjM/wR5F/V2K65Bhs
texqqBOYvA==


`pragma protect key_keyowner = "Mentor Graphics Corporation", key_keyname= "MGC-VERIF-SIM-RSA-1", key_method = "rsa"
`pragma protect encoding = (enctype = "BASE64", line_length = 76, bytes = 128)
`pragma protect key_block
MBYsuh9EGjKBlxR/81kh3KOqi8FbrckSRPHKXnFdQ+xl0tmxawBysww69vxfgtxFNJiAbn7g4XTl
ZKY4IL7I/Xtd8hfbyrNLd91vyaOSjApJ4lvzulVzGXiQnK2HerB/fsbdlHNBia244t0PdPr6F9xO
hHL7LtyvIyJ5GOAsQME=


`pragma protect key_keyowner = "Xilinx", key_keyname= "xilinx_2014_03", key_method = "rsa"
`pragma protect encoding = (enctype = "BASE64", line_length = 76, bytes = 256)
`pragma protect key_block
ZB+/R4dft7sjBtbt9KO0IC7JOAWrN2QUGDgE3tSIfDrQl4/J/iMmI3GwLQ7XorjfXJUQLlhgiEPW
+ugw+Ogpzl70RHSRn9wgBx8DxM5Ks50Auo/f7WTgCjB3kGLNv6mQbSMau1NzNOYVnZl8Rh6tHtUB
bOgS2tSRNq6hoywBzhlOhNF+WAFeAqlCivZUu+PEkHo6E5Tjow/fdsFGqDgxNX7oeLWmPsDpsKJ3
QcctpNHijjAQG5KD1D89K79Bra/gcXsqEUhln1UXEOlRrwotkgtYjLlDPa9a2oR5jbm9OA3sioA3
hmA55rKietj5N1L9Vfefe1hITEgIAfywcKZrYQ==


`pragma protect key_keyowner = "Synopsys", key_keyname= "SNPS-VCS-RSA-1", key_method = "rsa"
`pragma protect encoding = (enctype = "BASE64", line_length = 76, bytes = 128)
`pragma protect key_block
4G3TtWY+qMIHXmGANxyz04ejYEVMyDiVta/i/y1q0B2PiS/6o154uUJJtYZ6VwWcRLRFBS+KSUQS
1xM/H/dAMEXDwu6MoUZym3rNyVU2gMZDpStmQOJh5oqpOfWgd+pOZrno4Pu+I5fLHhcoKhrqt+Q2
EW8gZ8651ee7nTJiYJg=


`pragma protect key_keyowner = "Aldec", key_keyname= "ALDEC15_001", key_method = "rsa"
`pragma protect encoding = (enctype = "BASE64", line_length = 76, bytes = 256)
`pragma protect key_block
QMt+dKNUhNRuG/0VSi/RJghtOHEDAWuXQw6E5JDXlQ+PxklRNo5tNEiJcBcfgCuhCDCJzTxIDZpL
Zl2WXMeL7ut1Y4eRZ+DtqIV3uZkJsDlnZiNL2aV/OG/UVW7kjI0hreqRKfFgsfU5U+hz59Oe8dy/
F/kn0Lm3Jd3tuBZ/cUT+xg0TOmz94aVFbqONwZkaZwyCPsAn9HIeLYFAVy/VcPKduQSMJPBQ7PdH
w52z7LHHlPlI921JzVq774O0fZa3eT3VxX64elGzcrajGaZVnvYHnXYf72axtRbmk6RBrwG4/Wdm
fqtbdWjOojWTqRzPE4EY4JSbY+Rf1P4x2S8noQ==


`pragma protect key_keyowner = "ATRENTA", key_keyname= "ATR-SG-2015-RSA-3", key_method = "rsa"
`pragma protect encoding = (enctype = "BASE64", line_length = 76, bytes = 256)
`pragma protect key_block
S52hBEv73jPEAyMZcPN7R3PqCrzyV5A5nvi4Ta3EFdSf6V7h3OcWhpCvzJxlzMTuMZtXKveuy3Zq
W9cfkWUM11Wf+R5nPff+MWuKk5MueJZyp0EkRBwkDplwASqXoGcn/EZEI7q64lHjwiIUtpjtnml7
JKEMcCxna7gxNb9J2HLVpNoU5Tzc7ivVytTQ3/lZMzNHyYTf1AXOId2TJN2zNXVZI+CyJMx22gz6
BZhUfxy5+fezMv+cSMX2/VIk8lkzVKR0FmReScs4LG8lxvY227btFNDIZGwT3yDmdzGqMabsx6WW
nwWes9N7WA9TVKvqvODIAGKUZzAcKr0sfSeLJw==


`pragma protect key_keyowner = "Mentor Graphics Corporation", key_keyname= "MGC-PREC-RSA", key_method = "rsa"
`pragma protect encoding = (enctype = "BASE64", line_length = 76, bytes = 256)
`pragma protect key_block
ZMZjn/kW34TjAhTFNYHz4E6ydnt9rm+LQmIgyQgMl5W6p95fHyv3uM5NK9dhPLvk0C2lCPbRDaK3
MLDhC7zrAvpNKJb2YKTbO1+owB59YgmuqA9NJp3EO4q0VhA0tmcSGQNV9K66BPnj6a6pxWrTPPlM
mBvhuRc9T6t+9qtr9/dzrkVPr/+1ndx5T2hL9MvIBSDfpwPch79jBiMeayP1kaSxIdV14nl8hmJf
ilzqx+ixI3tqAIiQTYyeR+tVOWGXhSWYhK5xNNLfvKIpza8HTKslj96CHweoH4iGtwwHa9j/LYV3
7JMSJmSdjxy5vgJhJUV9OGGuX7umdaYwQjV6lw==


`pragma protect key_keyowner = "Synplicity", key_keyname= "SYNP05_001", key_method = "rsa"
`pragma protect encoding = (enctype = "BASE64", line_length = 76, bytes = 256)
`pragma protect key_block
x8vtawQYq2LR2Bafygzx9RwCyibo99QO7JM0dMk8H/llkhSgKjImwu3B1nDbLtsX8Ci9G2ynDJLb
ljbONKPSH+J5I4lVKJnbR3u+/Q1cUKWlwCqnshgK9PWfPp7HNqFYpA6V0UI89/a6cbTe1rE5oobc
FP7MoKBAk0Y1PJX9IvVGAYmV/NA1Dy9iyIpHpzkkou5PMaa6NypiRS7samxXQvBrnfvpJqMyolOy
JHcOrSUke1S0+IseTBvj7xJW6evbBtNXGP34vEoPvDauID1REAkH6ANBumiv0lewK1d6EbdthOZj
O+A4C3NtSBAW8cvJLB3Is+cGTJrJzkD574FHXA==


`pragma protect data_method = "AES128-CBC"
`pragma protect encoding = (enctype = "BASE64", line_length = 76, bytes = 8608)
`pragma protect data_block
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
HA==
`pragma protect end_protected
`ifndef GLBL
`define GLBL
`timescale  1 ps / 1 ps

module glbl ();

    parameter ROC_WIDTH = 100000;
    parameter TOC_WIDTH = 0;

//--------   STARTUP Globals --------------
    wire GSR;
    wire GTS;
    wire GWE;
    wire PRLD;
    tri1 p_up_tmp;
    tri (weak1, strong0) PLL_LOCKG = p_up_tmp;

    wire PROGB_GLBL;
    wire CCLKO_GLBL;
    wire FCSBO_GLBL;
    wire [3:0] DO_GLBL;
    wire [3:0] DI_GLBL;
   
    reg GSR_int;
    reg GTS_int;
    reg PRLD_int;

//--------   JTAG Globals --------------
    wire JTAG_TDO_GLBL;
    wire JTAG_TCK_GLBL;
    wire JTAG_TDI_GLBL;
    wire JTAG_TMS_GLBL;
    wire JTAG_TRST_GLBL;

    reg JTAG_CAPTURE_GLBL;
    reg JTAG_RESET_GLBL;
    reg JTAG_SHIFT_GLBL;
    reg JTAG_UPDATE_GLBL;
    reg JTAG_RUNTEST_GLBL;

    reg JTAG_SEL1_GLBL = 0;
    reg JTAG_SEL2_GLBL = 0 ;
    reg JTAG_SEL3_GLBL = 0;
    reg JTAG_SEL4_GLBL = 0;

    reg JTAG_USER_TDO1_GLBL = 1'bz;
    reg JTAG_USER_TDO2_GLBL = 1'bz;
    reg JTAG_USER_TDO3_GLBL = 1'bz;
    reg JTAG_USER_TDO4_GLBL = 1'bz;

    assign (weak1, weak0) GSR = GSR_int;
    assign (weak1, weak0) GTS = GTS_int;
    assign (weak1, weak0) PRLD = PRLD_int;

    initial begin
	GSR_int = 1'b1;
	PRLD_int = 1'b1;
	#(ROC_WIDTH)
	GSR_int = 1'b0;
	PRLD_int = 1'b0;
    end

    initial begin
	GTS_int = 1'b1;
	#(TOC_WIDTH)
	GTS_int = 1'b0;
    end

endmodule
`endif
