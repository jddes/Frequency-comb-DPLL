// Copyright 1986-2015 Xilinx, Inc. All Rights Reserved.
// --------------------------------------------------------------------------------
// Tool Version: Vivado v.2015.4 (win64) Build 1412921 Wed Nov 18 09:43:45 MST 2015
// Date        : Thu Jan 25 14:57:04 2018
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
Ma+sukotZFy8T54ZU0EsoRSamdC3SwCSTj6BCRUHuhU4d59Awmap5Ye4XcOQnuOEruL4iwOPvLjc
PoF9YQf05rHDajvvN88S2Orum4u0SsFocExXLti68Ag0ttjhhwfP1aU7FmBmpORDUDMsf55eo25A
kyw/oR2V4tYd1y8CxV6olVSskXhaPeyitNugbGsY8WNSaeZ763Sq9qTo8Ilat/BYWSbk7BFfwmBA
Dlr0ul+ZZPhkTu2X9F0yOLzD1k2UspNMXViNfhrh/mvRL6zCVFh0bxgJCV+m1rCXtdqxruO4pVXc
BwB4VUTmVrdzxDtbZEp/mcTOnPxdtXy6cFoEBw==


`pragma protect key_keyowner = "Synplicity", key_keyname= "SYNP05_001", key_method = "rsa"
`pragma protect encoding = (enctype = "BASE64", line_length = 76, bytes = 256)
`pragma protect key_block
sJ6UAikwaJ1eXcZp4oSlNGnl3uhjpdQ4F4AzeORKIjFUJjwS15afy0GdOFVWx5Ove4lSHtPEvHOJ
FkpEohlHqtvm9NV3Ex5AX1eA19qaseotChmx2aLJhhoqr18C36iXYfx9kDHk4EmXWHp/FUqJ6gu8
xeQ+evOKEsOL7enOvj+DA6bi2FQVNl9G9saeswRFTQAWw+kk7rRL163C6nNZTRmURDytiOGh8wh/
2SQ/jmV8BoorSA46oa01q1xIbV9hAlnUc/XZaLVV4xKR02tWFtXbR4UWrJAy2X2a4w3yBhmcKAoK
OzHxWFE7Cjhjh1PLQoudZV1B28fC1zZQGrBF5Q==


`pragma protect data_method = "AES128-CBC"
`pragma protect encoding = (enctype = "BASE64", line_length = 76, bytes = 7248)
`pragma protect data_block
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
njjZeaERBQp0
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
