// Copyright 1986-2015 Xilinx, Inc. All Rights Reserved.
// --------------------------------------------------------------------------------
// Tool Version: Vivado v.2015.4 (win64) Build 1412921 Wed Nov 18 09:43:45 MST 2015
// Date        : Sat Jun 23 00:23:11 2018
// Host        : jdbureau running 64-bit major release  (build 9200)
// Command     : write_verilog -force -mode funcsim {D:/Repo/Frequency-comb-DPLL/Firmware Vivado
//               Project/redpitaya.srcs/sources_1/ip/input_multiplier/input_multiplier_sim_netlist.v}
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
E4rYGFtGOLN7Vgj57WZ4HldsTu56Fbqow8hcoQHQKfqpapRdJCrSUQlVNHSRCQ1jQgx9FT7qFRnO
CZCRTb1h7sEGW2pp8lJc8tlOv3l/6JYAQMkjj/O/Xqh6ayPjGQ/IMmXj6yXb83zW8jieoD1i9hTT
xnsO2sXmh/izz50br+y7tgAcNAxmZMBbgvgDYIti4RY3/g5WBGJ63ojXTyaV5NP2JII4SdnwWVhT
LFB5sPFklb/AGm7/GOusL7WIVR/3XyiERgnzcqB/hv2W/recjwzim+CYGsEf6gxjJLAodmX1ZlQ+
FHTPjvyGBiuedo2vFFmCUeR+qLN6M5UbgoxSRw==


`pragma protect key_keyowner = "Synplicity", key_keyname= "SYNP05_001", key_method = "rsa"
`pragma protect encoding = (enctype = "BASE64", line_length = 76, bytes = 256)
`pragma protect key_block
wVTYaMF2/DCPClJBXFDf4gLMJJ5oAP8x22Jhmk+0eqLu9UQPhSp6V261SYt97sjh0/mhaHS7sIyg
Pj7HgE455bYt0wEX9FgAVTEXJFGWP6Psh9lDIYZGYtMZjODBobnjoSk3UMf+ke+0VAW3ARUfU48R
Tu9ZJkTl3xgWGjBiLPpBBBp8ADbiw5Hmy000FdRMQTskcoHCCtiwmFTeafhvBxA7/O6f9nht+ZUx
rlgqvF3feroCcCeOPWjpF+ddQ+mVWanXZaQGEIXCjTsCFLBE9QyIuzg/sAX6BjhMafj2euNNYoRf
VCwhIipW1GWLSDs+UxdZdwwIN2oUlOJPOCX6qg==


`pragma protect data_method = "AES128-CBC"
`pragma protect encoding = (enctype = "BASE64", line_length = 76, bytes = 7248)
`pragma protect data_block
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
wRyCqsPzduR7
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
