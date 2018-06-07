// Copyright 1986-2015 Xilinx, Inc. All Rights Reserved.
// --------------------------------------------------------------------------------
// Tool Version: Vivado v.2015.4 (win64) Build 1412921 Wed Nov 18 09:43:45 MST 2015
// Date        : Wed Jun 06 20:18:54 2018
// Host        : laptopjd running 64-bit Service Pack 1  (build 7601)
// Command     : write_verilog -force -mode funcsim
//               D:/Repo/Frequency-comb-DPLL/Firmware_Vivado_Project/redpitaya.srcs/sources_1/ip/input_multiplier/input_multiplier_sim_netlist.v
// Design      : input_multiplier
// Purpose     : This verilog netlist is a functional simulation representation of the design and should not be modified
//               or synthesized. This netlist cannot be used for SDF annotated simulation.
// Device      : xc7z010clg400-1
// --------------------------------------------------------------------------------
`timescale 1 ps / 1 ps

(* CHECK_LICENSE_TYPE = "input_multiplier,mult_gen_v12_0_10,{}" *) (* core_generation_info = "input_multiplier,mult_gen_v12_0_10,{x_ipProduct=Vivado 2015.4,x_ipVendor=xilinx.com,x_ipLibrary=ip,x_ipName=mult_gen,x_ipVersion=12.0,x_ipCoreRevision=10,x_ipLanguage=VERILOG,x_ipSimLanguage=MIXED,C_VERBOSITY=0,C_MODEL_TYPE=0,C_OPTIMIZE_GOAL=1,C_XDEVICEFAMILY=zynq,C_HAS_CE=0,C_HAS_SCLR=0,C_LATENCY=1,C_A_WIDTH=16,C_A_TYPE=0,C_B_WIDTH=16,C_B_TYPE=0,C_OUT_HIGH=31,C_OUT_LOW=0,C_MULT_TYPE=1,C_CE_OVERRIDES_SCLR=0,C_CCM_IMP=0,C_B_VALUE=10000001,C_HAS_ZERO_DETECT=0,C_ROUND_OUTPUT=0,C_ROUND_PT=0}" *) (* downgradeipidentifiedwarnings = "yes" *) 
(* x_core_info = "mult_gen_v12_0_10,Vivado 2015.4" *) 
(* NotValidForBitStream *)
module input_multiplier
   (CLK,
    A,
    B,
    P);
  (* x_interface_info = "xilinx.com:signal:clock:1.0 clk_intf CLK" *) input CLK;
  (* x_interface_info = "xilinx.com:signal:data:1.0 a_intf DATA" *) input [15:0]A;
  (* x_interface_info = "xilinx.com:signal:data:1.0 b_intf DATA" *) input [15:0]B;
  (* x_interface_info = "xilinx.com:signal:data:1.0 p_intf DATA" *) output [31:0]P;

  wire [15:0]A;
  wire [15:0]B;
  wire CLK;
  wire [31:0]P;
  wire [47:0]NLW_U0_PCASC_UNCONNECTED;
  wire [1:0]NLW_U0_ZERO_DETECT_UNCONNECTED;

  (* C_A_TYPE = "0" *) 
  (* C_A_WIDTH = "16" *) 
  (* C_B_TYPE = "0" *) 
  (* C_B_VALUE = "10000001" *) 
  (* C_B_WIDTH = "16" *) 
  (* C_CCM_IMP = "0" *) 
  (* C_CE_OVERRIDES_SCLR = "0" *) 
  (* C_HAS_CE = "0" *) 
  (* C_HAS_SCLR = "0" *) 
  (* C_HAS_ZERO_DETECT = "0" *) 
  (* C_LATENCY = "1" *) 
  (* C_MODEL_TYPE = "0" *) 
  (* C_MULT_TYPE = "1" *) 
  (* C_OPTIMIZE_GOAL = "1" *) 
  (* C_OUT_HIGH = "31" *) 
  (* C_OUT_LOW = "0" *) 
  (* C_ROUND_OUTPUT = "0" *) 
  (* C_ROUND_PT = "0" *) 
  (* C_VERBOSITY = "0" *) 
  (* C_XDEVICEFAMILY = "zynq" *) 
  (* downgradeipidentifiedwarnings = "yes" *) 
  input_multiplier_mult_gen_v12_0_10 U0
       (.A(A),
        .B(B),
        .CE(1'b1),
        .CLK(CLK),
        .P(P),
        .PCASC(NLW_U0_PCASC_UNCONNECTED[47:0]),
        .SCLR(1'b0),
        .ZERO_DETECT(NLW_U0_ZERO_DETECT_UNCONNECTED[1:0]));
endmodule

(* C_A_TYPE = "0" *) (* C_A_WIDTH = "16" *) (* C_B_TYPE = "0" *) 
(* C_B_VALUE = "10000001" *) (* C_B_WIDTH = "16" *) (* C_CCM_IMP = "0" *) 
(* C_CE_OVERRIDES_SCLR = "0" *) (* C_HAS_CE = "0" *) (* C_HAS_SCLR = "0" *) 
(* C_HAS_ZERO_DETECT = "0" *) (* C_LATENCY = "1" *) (* C_MODEL_TYPE = "0" *) 
(* C_MULT_TYPE = "1" *) (* C_OPTIMIZE_GOAL = "1" *) (* C_OUT_HIGH = "31" *) 
(* C_OUT_LOW = "0" *) (* C_ROUND_OUTPUT = "0" *) (* C_ROUND_PT = "0" *) 
(* C_VERBOSITY = "0" *) (* C_XDEVICEFAMILY = "zynq" *) (* ORIG_REF_NAME = "mult_gen_v12_0_10" *) 
(* downgradeipidentifiedwarnings = "yes" *) 
module input_multiplier_mult_gen_v12_0_10
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
  input [15:0]B;
  input CE;
  input SCLR;
  output [1:0]ZERO_DETECT;
  output [31:0]P;
  output [47:0]PCASC;

  wire [15:0]A;
  wire [15:0]B;
  wire CE;
  wire CLK;
  wire [31:0]P;
  wire [47:0]PCASC;
  wire SCLR;
  wire [1:0]ZERO_DETECT;

  (* C_A_TYPE = "0" *) 
  (* C_A_WIDTH = "16" *) 
  (* C_B_TYPE = "0" *) 
  (* C_B_VALUE = "10000001" *) 
  (* C_B_WIDTH = "16" *) 
  (* C_CCM_IMP = "0" *) 
  (* C_CE_OVERRIDES_SCLR = "0" *) 
  (* C_HAS_CE = "0" *) 
  (* C_HAS_SCLR = "0" *) 
  (* C_HAS_ZERO_DETECT = "0" *) 
  (* C_LATENCY = "1" *) 
  (* C_MODEL_TYPE = "0" *) 
  (* C_MULT_TYPE = "1" *) 
  (* C_OPTIMIZE_GOAL = "1" *) 
  (* C_OUT_HIGH = "31" *) 
  (* C_OUT_LOW = "0" *) 
  (* C_ROUND_OUTPUT = "0" *) 
  (* C_ROUND_PT = "0" *) 
  (* C_VERBOSITY = "0" *) 
  (* C_XDEVICEFAMILY = "zynq" *) 
  (* downgradeipidentifiedwarnings = "yes" *) 
  input_multiplier_mult_gen_v12_0_10_viv i_mult
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
X7ULkQVyn8rFl7BpJafdPjKCn/cuMhKBuNsgzNKWuAyG2ooGK6L1rPUl1g4D3rRzFDq0N5rrTkQd
iz2SjJB894K1uqbgB8b0QnUWU/YwFkQ8w52B4uA7VyKL2rtFDWKAhF/Yva6BRP2KTjSx9jHvKOyb
uSVC9qI/mqnYiiQQbZC5Rliptd4ZlRBCToVhMA3Ud4M5s8RIFEMQgoDOXGG6M0H95a8JlT75isOi
WapdikzOg9HxCljbXODROgY87MDO5qW74dq2nUMgepgNZCaW/FJuU+EkNbTUfRyYQmAzIDtArz8e
MdzLbJYXN7u0cIaAAz1Ur6HfEhIO6ukmtYSlGg==


`pragma protect key_keyowner = "Synplicity", key_keyname= "SYNP05_001", key_method = "rsa"
`pragma protect encoding = (enctype = "BASE64", line_length = 76, bytes = 256)
`pragma protect key_block
rZtv5Zc5kp1G+c5TvvgaykUbmmbVFrZ5phgjJZMczD3ebda4fXiiAcAWMj7zF5b2dQDpmgkBRJHm
MrSmNDwZxAB7lb7X8NiBEje//TsFsNQA/aH1sXwmYHA0NRrph54y5mousV2SZ0Wq27HAIKdj+/qA
MgaODf1q84ZkGroiWnrm/BsrP8wRd4DQTVAkFflr7A3YPARA9SZ7DkOb3KWfHuqrKXUTVxxVCqfq
1osH+RvtRCgTEpjn6J1g5RHzxFrPur5VLWY2xzSqd4Pri9p26mZDJ39QVMW1La9J3Q5HUm7ZikKD
7A8M41Uwc6Z56pquPDxYYzGv6BoumBEmKNVS9w==


`pragma protect data_method = "AES128-CBC"
`pragma protect encoding = (enctype = "BASE64", line_length = 76, bytes = 7248)
`pragma protect data_block
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
QjRmZGp69Une
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
