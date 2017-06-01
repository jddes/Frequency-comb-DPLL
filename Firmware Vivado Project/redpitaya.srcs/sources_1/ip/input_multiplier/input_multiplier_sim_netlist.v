// Copyright 1986-2015 Xilinx, Inc. All Rights Reserved.
// --------------------------------------------------------------------------------
// Tool Version: Vivado v.2015.4 (lin64) Build 1412921 Wed Nov 18 09:44:32 MST 2015
// Date        : Sat Aug 13 02:03:48 2016
// Host        : jd-VirtualBox running 64-bit Ubuntu 14.04.3 LTS
// Command     : write_verilog -force -mode funcsim
//               /media/sf_D/Projects/RedPitaya/fpga/project/redpitaya.srcs/sources_1/ip/input_multiplier/input_multiplier_sim_netlist.v
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
MshqT68t6H2WdI7B5Dta4b4CL7HB0vDjzwDVtjFZDirGY7alH7aDWXAkic5z0LWk9sb8c4YYiuvS
1dswTZIwAIgpiJEcfoAtLBIXReeBzCDFuVcvH7yrnAX7lzEEGjds5Zos8ChhtkClnvjOQJxGmcKN
aGrsjyf94JR4caJpMOwRbjHBUcmRWTNIY+tcbb9n1Sea355eT4+x/DubjZfnLx2yRV/QH2TnuVWR
1hbepz8yvimdnZ+S35kWR3wtQce/HezM8aXfC+Qc/aNd13UX4EnkGoG1wjQD7uVZM56sewfTxAwN
aI4x68O6oSlyjdoGVle/+RsY/3wbvz60Trlj4g==


`pragma protect key_keyowner = "Synplicity", key_keyname= "SYNP05_001", key_method = "rsa"
`pragma protect encoding = (enctype = "BASE64", line_length = 76, bytes = 256)
`pragma protect key_block
bOUcnNTPA4XGsf0K1oLv2EWK5OgcAy6xcaI/E7ra29SVlnKhDeCz87xex0G7UtaM+ghGQA5IWHL7
AuXBfXGzBl/yYMZpVqthT94hTWoyJjAqtfU/BDuXMu9sGnBc5KQQNMNsFDwfLCXTMa3QG2vjByXX
tup5OjZLOsaPkjb9qLbXj9Pp5cuAZfU7R1vpqt8sRTBDrJeuicrBaBESqGilhYRli4fxBPgEb98O
V4Q9T7edqHAGVH41N/7tuWAccvMWr2KMIJPLwJZEe9POgCQHDCHBjGWvgcXfA//1/o62OgFpVGzu
BMnEHpfOgiQZ1MM/qDF7HMh+PKM+Qq1wys3l1g==


`pragma protect data_method = "AES128-CBC"
`pragma protect encoding = (enctype = "BASE64", line_length = 76, bytes = 7248)
`pragma protect data_block
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
EbldiQ4KJiVd
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
