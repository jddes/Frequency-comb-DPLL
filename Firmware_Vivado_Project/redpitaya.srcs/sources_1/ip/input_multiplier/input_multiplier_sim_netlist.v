// Copyright 1986-2015 Xilinx, Inc. All Rights Reserved.
// --------------------------------------------------------------------------------
// Tool Version: Vivado v.2015.4 (win64) Build 1412921 Wed Nov 18 09:43:45 MST 2015
// Date        : Sat Jun 30 00:38:39 2018
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
a2jc4MNyMsPTIP8XT6MGmkcQQNqPKw+vAtbZrqFol5DSgCtyHou5WGsNLPB129maNWd0yW+JZq+W
Tq3YvkHMYyUP9wGLtkcxgL5cOgsVVbdTuzsxc8HsrEVDRh/0QqKVAdnqn9OntuQyyNusHTCufym1
xP3JHN6M2ooCW2QylxSAwO4x9zr6UNxFkszQfzJaFAZgFaVxG+EZR1sBpteQRE0dLE0H8h5gCwZa
BWkkFXYPn+ESUZeqm0NsWCMfHs8EVf0NSeKeZjLqLZoqwvrX3uVHwasURqBxbbYqHmlDgcZvnLsE
Nwt4/rLCFFfp86tyB2W5VZlowJ0x7ijdauC8Ow==


`pragma protect key_keyowner = "Synplicity", key_keyname= "SYNP05_001", key_method = "rsa"
`pragma protect encoding = (enctype = "BASE64", line_length = 76, bytes = 256)
`pragma protect key_block
otVnAMSRLfTHrgy52DGcFycHtrcc56taFaj/2x7ADGBwSa9Mmh9diMMnDHUq99Cwp6ojt5ROagsw
2Kzkwvb27HDc2t5U+xUV3+LQP9gpeixGRNvK+AOIJ96ds5DJjph7cZDTv6gY2RLCR+fERK8iXDLl
MwI/7zk/h2JMHPAdiKIznDUJzEWoF0k8Tv9orF9ZC7zCBeZqUfumu/fp67/Uy1gXTUzmbjueGsfj
uu2cVP2XNYaNDnrSTdW8G4EzN0DDrWnf3BR5OgelpV0bqM7ManFB1K6S3dA4UPAsfph3N1YlJoEH
y9PUhm33DDjJNK32dH/omYKDQLVSzMYCUuRXeA==


`pragma protect data_method = "AES128-CBC"
`pragma protect encoding = (enctype = "BASE64", line_length = 76, bytes = 7248)
`pragma protect data_block
+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
An9ANAQSsT86
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
