// Copyright 1986-2015 Xilinx, Inc. All Rights Reserved.
// --------------------------------------------------------------------------------
// Tool Version: Vivado v.2015.4 (win64) Build 1412921 Wed Nov 18 09:43:45 MST 2015
// Date        : Tue Jan 30 04:14:27 2018
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
N0qaJU+EbU6f0+kS76VkhuP/gZQ6sRHH1Gw+NMHPS8zoaKEtV2yNZDhTVGAKlG/Mon4+iX8jqbIO
Fb+uKQO6u5laIFVOANRy1JPjW/ljGlIpowf9RxNCxaKP5qGLPkRbchYWP1mjzK5SacoRn4YRhZyS
RyfXuiXKyUMqYYMOVIXZ/i2E9va3a24y4g7YvTGXeMCFJuQsjA9aWdA5CToQHpyDtxlROiktWWvL
8vuVARipiqPQOym2H7s9F2/bYTLR1haVwn0T75miee4kWlC11fW5PFofMG3SjuPUewcI8LQ/yygw
0LGiAwI2e4oQCGsJ+jcEO/6FcQVmtmSiVxoxFg==


`pragma protect key_keyowner = "Synplicity", key_keyname= "SYNP05_001", key_method = "rsa"
`pragma protect encoding = (enctype = "BASE64", line_length = 76, bytes = 256)
`pragma protect key_block
UHNKOizDVdhFUPfKtbbuKIP0Yspht+FAu8gWUwVN5Mz3ol1tgf4J91/Ctn2UVnHeZBJeRvmHorUp
em+78FUVoZxSG+O/jQBohldjb06WHUZdaVYu/Gj2e8UV3a7cc96TM+6L+688GDeC+fgemp7prsxc
9/LzbO+SBrhiYRhXLGtUtZoWn7I58X7/Kpc8K2WVBXHCNRPD5CaQ8XEQI9YvC5gAgEgxZA6o4COA
dN2CL7xfQ3n137WwToTq5V0sOYSa6XwWolQtDoBISsexZ7ZSlvEQeoV7GCaAHWO76qQQzrSKf41H
iqmZrlVnohIF8XzgCHL2eSnJjrpdYzr+A3qqtA==


`pragma protect data_method = "AES128-CBC"
`pragma protect encoding = (enctype = "BASE64", line_length = 76, bytes = 22816)
`pragma protect data_block
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
1Al3oDg08RVUoMIuduUNyQ==
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
