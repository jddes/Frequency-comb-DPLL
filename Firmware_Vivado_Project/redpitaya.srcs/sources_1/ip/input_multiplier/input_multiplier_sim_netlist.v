// Copyright 1986-2015 Xilinx, Inc. All Rights Reserved.
// --------------------------------------------------------------------------------
// Tool Version: Vivado v.2015.4 (win64) Build 1412921 Wed Nov 18 09:43:45 MST 2015
// Date        : Tue Jan 30 04:14:21 2018
// Host        : jdbureau running 64-bit major release  (build 9200)
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
TnJFQk+25l8KDaNCHk2XE3TpwaMMPBiQ6kx22k++fzsJBWq4KtixP5etlqmQhq+vtfF3LOypAYhD
F/eBnsWYT94nim6i+/XxWkEPLa0/b+2mCCymL2YypZ9RjcNGk8OfpWABDdOGT4cJVtiA6zVZBqQ0
pe8JEC4XHEsYCXHg0u+0LP1Ajvi2oChBEZOs9eGgsqjk/X5gOs5QojIskhx3SFblhr3EnRCQwQP8
KjoGYkcXkRuen3yFTGCapl9EvFT1M7cA7H6mUey/7irnuX1x5CcbZkFQUl4YNVyRfRHL3dn4C+PA
BdfXf++he+sLhbcSbY0ACuzIFZUEPOL5pWFkpA==


`pragma protect key_keyowner = "Synplicity", key_keyname= "SYNP05_001", key_method = "rsa"
`pragma protect encoding = (enctype = "BASE64", line_length = 76, bytes = 256)
`pragma protect key_block
DFG+QGEhOmZMY+WlGFOqU++Cfq9e6IZMksyZc6TBCL2LmDhuMKfYODWWiyWxa3dy+km4l4oU9ABP
xpy+baMtQt5+PFa8qcpXXWadTIeJfHIiQjJruTtE8gaWqRocnxOB06INDF626bZ/yyQ/m7RbJ1En
7vVY1FPH7MasVz1OWqLaB8XqFngTvOIfWq7shUI0+HhmXBvc0OinqUCVn8ylxFvBWvx/cqroXifD
B1c2y+bqw6NynQXa8cbHrghF78M8njUSuSbzQtboNGycpFBU5HOGzyxn4kD4nB3e+CBPmbf5AGHx
nzi4P+OJfb5iDlVVzYE8dysRnQfxqaqMEnP1IQ==


`pragma protect data_method = "AES128-CBC"
`pragma protect encoding = (enctype = "BASE64", line_length = 76, bytes = 7248)
`pragma protect data_block
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
jGs3G5heO5ZT
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
