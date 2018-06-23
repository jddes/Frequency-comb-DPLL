// Copyright 1986-2015 Xilinx, Inc. All Rights Reserved.
// --------------------------------------------------------------------------------
// Tool Version: Vivado v.2015.4 (win64) Build 1412921 Wed Nov 18 09:43:45 MST 2015
// Date        : Sat Jun 23 16:43:35 2018
// Host        : jdbureau running 64-bit major release  (build 9200)
// Command     : write_verilog -force -mode funcsim
//               D:/Repo/Frequency-comb-DPLL/Firmware_Vivado_Project/redpitaya.srcs/sources_1/ip/pll_wide_mult/pll_wide_mult_sim_netlist.v
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
Lo3cmopENAFEu4x/rfiwoNnBeKbRs/Lww8u8Y6+/Amf8I0p/Nv56Fdtqd2K5dn3DqKKprdQuRuvH
XBQlpwILx5vtSaczZUilIrHVl4zwhalxJj1Hnw7S9F9AfkOcTOI0K+Vq3kC7MYD59pBwwaK8AsyI
ZGYjJsob8HIYhp/CFLchX2IOcdBbpoIkihMdyJ8qYv+whrw1+KzfeCOx04tahZsZ6DV7jdR4TeLT
Ck0FyBdkQRr6mRAw2XknV2T+Zx880eRmmlz0AH1STj8AkElJ/z3tFhlh03biotvCELY6UIXvChbK
xKtDEEcFMk+qHvKqEC7MB8jM37orYhCZhrnOWw==


`pragma protect key_keyowner = "Synplicity", key_keyname= "SYNP05_001", key_method = "rsa"
`pragma protect encoding = (enctype = "BASE64", line_length = 76, bytes = 256)
`pragma protect key_block
Py2YVO0VlRxbcHJ35609k3fKNujA/L9ypxExq+mBK5Amy8nih14yf5hc1EZl/JdK5rcMm5GIGmV2
ZZVHjHLc/xm/4ZdyDMWmQSiWIHA/UkZ5pqO24Gda5Pm9SqLkv0IEqITHrp9E0GEZbqYOqFXnqtBZ
tVjgTf0O/xZ51bt3SmlGfDgTKAJn9UVFrPu0yax70kCIK8MVXM636IUV64r69coY+PIby5OfIXuR
7eZwOMb2Qvq54ZcCcQnMDiYFBFLBBqs27ltFSX6xAnJuWyfZnnaG+c4WuKbtjMEha4bZG1DELYCy
Bs0mor2b5bLW5w9jrwzakB89+oKF/oKWSUncJQ==


`pragma protect data_method = "AES128-CBC"
`pragma protect encoding = (enctype = "BASE64", line_length = 76, bytes = 22816)
`pragma protect data_block
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
sXFTzcj3QJupWkOeL7ESXg==
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
