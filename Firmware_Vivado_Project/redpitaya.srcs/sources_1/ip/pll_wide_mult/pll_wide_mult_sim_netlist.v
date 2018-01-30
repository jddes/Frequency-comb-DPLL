// Copyright 1986-2015 Xilinx, Inc. All Rights Reserved.
// --------------------------------------------------------------------------------
// Tool Version: Vivado v.2015.4 (win64) Build 1412921 Wed Nov 18 09:43:45 MST 2015
// Date        : Tue Jan 30 05:13:17 2018
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
TDXpDaxF37FRvxY7Gvax0e27FhPu2PnsfBptCE+VRQctxYk6vvZEfKEKMaRcRn+RpzGlovebRDyH
SXX1Hc/KtieSDGLjNVivqK1hELCtlO/PJ0AMTXn0COR5DVNJw5RraHrfqelb3JbaRXhaKDBeBGNZ
N0Re1EV9TQ/N3MOsC6C/sBv5DbiTo/R+JhiGJq3nChMPOC9sL2+/mh3VpZagOt5bDf+a7iMFEsMn
MGUYGSikOE1aMjhKJRcUj/TfbwHR3Px3ZujaxJ3teUNFKE/5vvYpaXdtCjg/KZYzXNigbx/fH27x
odAFwZT+EoQgDsXesOkRQmQkD5qafcQzjgX+3g==


`pragma protect key_keyowner = "Synplicity", key_keyname= "SYNP05_001", key_method = "rsa"
`pragma protect encoding = (enctype = "BASE64", line_length = 76, bytes = 256)
`pragma protect key_block
S/XVHTwQSBeJx6BShx+rznk0HoqoK+15dFHgTCeKM6cTU1rdXkFv7/udUeV+IIVyYxwTriX0/AWE
xOdjUSGghRDmJrMtxRAxwQ5QhsR4yp/G24DcRv/+VZ5csm4gcohuQX/1eJx+y28uxgyLiQvXjR+f
Wx0rPtcvKytz1YHhHTkTzbhjxgzpOI1unn2B2Kle7HwZdBAanEa+bjsPiQRR5BAJfLirsOiuiycY
VpORx6klm94p8yrQ/Iu4+7/wkw/yRA1Nhax0cxdjkXDqO70odPW+hRdUJ1W3ocxe0+/zjN3hc+ld
Rvgs/uRHmOshjNkxf2GxQa1nvM0TRlcck2cHww==


`pragma protect data_method = "AES128-CBC"
`pragma protect encoding = (enctype = "BASE64", line_length = 76, bytes = 22816)
`pragma protect data_block
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
IflZeo8tcgeSv47t4n1sqQ==
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
