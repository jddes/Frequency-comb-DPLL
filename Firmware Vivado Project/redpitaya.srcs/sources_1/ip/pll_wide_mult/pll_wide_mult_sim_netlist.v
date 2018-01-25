// Copyright 1986-2015 Xilinx, Inc. All Rights Reserved.
// --------------------------------------------------------------------------------
// Tool Version: Vivado v.2015.4 (win64) Build 1412921 Wed Nov 18 09:43:45 MST 2015
// Date        : Thu Jan 25 14:57:09 2018
// Host        : jdbureau running 64-bit major release  (build 9200)
// Command     : write_verilog -force -mode funcsim {D:/Repo/Frequency-comb-DPLL/Firmware Vivado
//               Project/redpitaya.srcs/sources_1/ip/pll_wide_mult/pll_wide_mult_sim_netlist.v}
// Design      : pll_wide_mult
// Purpose     : This verilog netlist is a functional simulation representation of the design and should not be modified
//               or synthesized. This netlist cannot be used for SDF annotated simulation.
// Device      : xc7z010clg400-1
// --------------------------------------------------------------------------------
`timescale 1 ps / 1 ps

(* CHECK_LICENSE_TYPE = "pll_wide_mult,mult_gen_v12_0_10,{}" *) (* core_generation_info = "pll_wide_mult,mult_gen_v12_0_10,{x_ipProduct=Vivado 2015.4,x_ipVendor=xilinx.com,x_ipLibrary=ip,x_ipName=mult_gen,x_ipVersion=12.0,x_ipCoreRevision=10,x_ipLanguage=VERILOG,x_ipSimLanguage=MIXED,C_VERBOSITY=0,C_MODEL_TYPE=0,C_OPTIMIZE_GOAL=1,C_XDEVICEFAMILY=zynq,C_HAS_CE=0,C_HAS_SCLR=1,C_LATENCY=5,C_A_WIDTH=10,C_A_TYPE=0,C_B_WIDTH=32,C_B_TYPE=0,C_OUT_HIGH=41,C_OUT_LOW=0,C_MULT_TYPE=1,C_CE_OVERRIDES_SCLR=0,C_CCM_IMP=0,C_B_VALUE=10000001,C_HAS_ZERO_DETECT=0,C_ROUND_OUTPUT=0,C_ROUND_PT=0}" *) (* downgradeipidentifiedwarnings = "yes" *) 
(* x_core_info = "mult_gen_v12_0_10,Vivado 2015.4" *) 
(* NotValidForBitStream *)
module pll_wide_mult
   (CLK,
    A,
    B,
    SCLR,
    P);
  (* x_interface_info = "xilinx.com:signal:clock:1.0 clk_intf CLK" *) input CLK;
  (* x_interface_info = "xilinx.com:signal:data:1.0 a_intf DATA" *) input [9:0]A;
  (* x_interface_info = "xilinx.com:signal:data:1.0 b_intf DATA" *) input [31:0]B;
  (* x_interface_info = "xilinx.com:signal:reset:1.0 sclr_intf RST" *) input SCLR;
  (* x_interface_info = "xilinx.com:signal:data:1.0 p_intf DATA" *) output [41:0]P;

  wire [9:0]A;
  wire [31:0]B;
  wire CLK;
  wire [41:0]P;
  wire SCLR;
  wire [47:0]NLW_U0_PCASC_UNCONNECTED;
  wire [1:0]NLW_U0_ZERO_DETECT_UNCONNECTED;

  (* C_A_TYPE = "0" *) 
  (* C_A_WIDTH = "10" *) 
  (* C_B_TYPE = "0" *) 
  (* C_B_VALUE = "10000001" *) 
  (* C_B_WIDTH = "32" *) 
  (* C_CCM_IMP = "0" *) 
  (* C_CE_OVERRIDES_SCLR = "0" *) 
  (* C_HAS_CE = "0" *) 
  (* C_HAS_SCLR = "1" *) 
  (* C_HAS_ZERO_DETECT = "0" *) 
  (* C_LATENCY = "5" *) 
  (* C_MODEL_TYPE = "0" *) 
  (* C_MULT_TYPE = "1" *) 
  (* C_OPTIMIZE_GOAL = "1" *) 
  (* C_OUT_HIGH = "41" *) 
  (* C_OUT_LOW = "0" *) 
  (* C_ROUND_OUTPUT = "0" *) 
  (* C_ROUND_PT = "0" *) 
  (* C_VERBOSITY = "0" *) 
  (* C_XDEVICEFAMILY = "zynq" *) 
  (* downgradeipidentifiedwarnings = "yes" *) 
  pll_wide_mult_mult_gen_v12_0_10 U0
       (.A(A),
        .B(B),
        .CE(1'b1),
        .CLK(CLK),
        .P(P),
        .PCASC(NLW_U0_PCASC_UNCONNECTED[47:0]),
        .SCLR(SCLR),
        .ZERO_DETECT(NLW_U0_ZERO_DETECT_UNCONNECTED[1:0]));
endmodule

(* C_A_TYPE = "0" *) (* C_A_WIDTH = "10" *) (* C_B_TYPE = "0" *) 
(* C_B_VALUE = "10000001" *) (* C_B_WIDTH = "32" *) (* C_CCM_IMP = "0" *) 
(* C_CE_OVERRIDES_SCLR = "0" *) (* C_HAS_CE = "0" *) (* C_HAS_SCLR = "1" *) 
(* C_HAS_ZERO_DETECT = "0" *) (* C_LATENCY = "5" *) (* C_MODEL_TYPE = "0" *) 
(* C_MULT_TYPE = "1" *) (* C_OPTIMIZE_GOAL = "1" *) (* C_OUT_HIGH = "41" *) 
(* C_OUT_LOW = "0" *) (* C_ROUND_OUTPUT = "0" *) (* C_ROUND_PT = "0" *) 
(* C_VERBOSITY = "0" *) (* C_XDEVICEFAMILY = "zynq" *) (* ORIG_REF_NAME = "mult_gen_v12_0_10" *) 
(* downgradeipidentifiedwarnings = "yes" *) 
module pll_wide_mult_mult_gen_v12_0_10
   (CLK,
    A,
    B,
    CE,
    SCLR,
    ZERO_DETECT,
    P,
    PCASC);
  input CLK;
  input [9:0]A;
  input [31:0]B;
  input CE;
  input SCLR;
  output [1:0]ZERO_DETECT;
  output [41:0]P;
  output [47:0]PCASC;

  wire [9:0]A;
  wire [31:0]B;
  wire CE;
  wire CLK;
  wire [41:0]P;
  wire [47:0]PCASC;
  wire SCLR;
  wire [1:0]ZERO_DETECT;

  (* C_A_TYPE = "0" *) 
  (* C_A_WIDTH = "10" *) 
  (* C_B_TYPE = "0" *) 
  (* C_B_VALUE = "10000001" *) 
  (* C_B_WIDTH = "32" *) 
  (* C_CCM_IMP = "0" *) 
  (* C_CE_OVERRIDES_SCLR = "0" *) 
  (* C_HAS_CE = "0" *) 
  (* C_HAS_SCLR = "1" *) 
  (* C_HAS_ZERO_DETECT = "0" *) 
  (* C_LATENCY = "5" *) 
  (* C_MODEL_TYPE = "0" *) 
  (* C_MULT_TYPE = "1" *) 
  (* C_OPTIMIZE_GOAL = "1" *) 
  (* C_OUT_HIGH = "41" *) 
  (* C_OUT_LOW = "0" *) 
  (* C_ROUND_OUTPUT = "0" *) 
  (* C_ROUND_PT = "0" *) 
  (* C_VERBOSITY = "0" *) 
  (* C_XDEVICEFAMILY = "zynq" *) 
  (* downgradeipidentifiedwarnings = "yes" *) 
  pll_wide_mult_mult_gen_v12_0_10_viv i_mult
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
cEVj5YzYHtj+5YWEM9kvHynsBkVzkrp5CVgbDQVY8/2gs1ZpjQu+ONhLI5TAGymMaeUPsKVElsQf
OzyJbMB2R6mhvWWunDdW97m98kf/lRxh8b33ITNgopu4AF/7ikwznYjiu26//+qZXjDXsOLXKcei
FLmKAixXakOvtAOvboc1l9izCGFIHfELzDewqX6pejns9pW3CKBXEEK8Vrlq1RlyOtaJz4JNL9pH
/YwFtcnGtUHSMbqaNjDlT1pyKJ80wg9r8Ps4H5JJax7jhPmenfBpRTwdsnuWwFZNXccLDFRj4gvL
c4LsvF1XxoTslOtH4SDZKCj78ETQ5XXGaOVJUQ==


`pragma protect key_keyowner = "Synplicity", key_keyname= "SYNP05_001", key_method = "rsa"
`pragma protect encoding = (enctype = "BASE64", line_length = 76, bytes = 256)
`pragma protect key_block
v2Re/vJeeLLrBJTFyaaK4kFLkFwjxLLtkLooULfSrC1mzl8YB9n3s8tQYfoYI7eXuIebiIV0Akog
JYAZRzmINtaTyw77JzcR9cJNn2xrRcnEvBjQsp3gEeiy2dDpGU2IujAshtd7fBdSpTtZune6wk5V
DhttV7+1gMs4XpANdA1M9NsO3NX6LjjBCk8Lwh9EwxGr4nJs4V+4G7LEzAQyYd3vaf44lWFKe4gE
6PmVYOBp5D2wYorWW9QnL+VcJdAm1bhYGIeXu6keVKxlbyZI0nlcraLGs35IZlP69eh6Bq4PF7Wo
p2x23LMLa3NB3CuO3AqNnlx7bnPTA0sOAEhmAw==


`pragma protect data_method = "AES128-CBC"
`pragma protect encoding = (enctype = "BASE64", line_length = 76, bytes = 22816)
`pragma protect data_block
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
f8E7EFfLwZYGHOz2ZljsVQ==
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
