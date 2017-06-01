// Copyright 1986-2015 Xilinx, Inc. All Rights Reserved.
// --------------------------------------------------------------------------------
// Tool Version: Vivado v.2015.4 (lin64) Build 1412921 Wed Nov 18 09:44:32 MST 2015
// Date        : Sat Aug 13 02:05:28 2016
// Host        : jd-VirtualBox running 64-bit Ubuntu 14.04.3 LTS
// Command     : write_verilog -force -mode funcsim
//               /media/sf_D/Projects/RedPitaya/fpga/project/redpitaya.srcs/sources_1/ip/pll_wide_mult/pll_wide_mult_sim_netlist.v
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
pXB3ExOh/rHUor7M5th/xKu7ctmIUWF+U0+DXImbngAg0/LxYW4ma8MTsDcrm6kKGvs3o5xlXcIC
VUqObWLceSpzv07q3RKbROdQF30x5y4lKXcDY64Bd9uarJDQAMAobFjteTPpVnA00YF4ShRWHmcQ
3pUU0TLtiV74lfwhj/pA3Sm+CKjfGKlQGcDvjHcBn0cX5MhWJ8NVt1pJF6VOxrWuQtYnqNnp/nvW
blEkXtB5+v1iNW0FysGhD++1lfX68l/wUAnPpopyquR57xXN4AHMKh1q1JzvxQkQLVXPYhB6LVMm
k6E3C81MazwvDb7Et9S+iMDKveWaS7E3A5WcxQ==


`pragma protect key_keyowner = "Synplicity", key_keyname= "SYNP05_001", key_method = "rsa"
`pragma protect encoding = (enctype = "BASE64", line_length = 76, bytes = 256)
`pragma protect key_block
qdwyeatBsEvP6+k01BNGCz/QRGxGX6WGuQ1uAblZ3nVsCXONlFDtODlH2+hMnK1y+nGBowUb6f2l
9iFYrCbRIFbUMcwNKzGRSNjaglw95c0jZ0OsF4kxOTU5q43bH8kcd57BEtbkaQTs/+1JlwdS7T9J
ZhQReIVNs/7TNQBCRv9MdY70wuaeuHzUUq4vXjmCm+wUEE7MVnSTo5BiOEFF29hp4mZ1JcVLk/yX
0hkf3jwfoLx2vEjw1/YxOrmZQEQ8QOzZzK4rxG7lw8pgakF8wPp09bcvPx3YdElfg+Z0srz1/rqd
5QQeP0Clbs3ZOx11FslENVBSo6UCIK3iMWiCmA==


`pragma protect data_method = "AES128-CBC"
`pragma protect encoding = (enctype = "BASE64", line_length = 76, bytes = 22816)
`pragma protect data_block
+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
n0qpNgA1my/oQUPuY5oavw==
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
