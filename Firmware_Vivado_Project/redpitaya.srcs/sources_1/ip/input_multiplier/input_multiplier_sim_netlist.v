// Copyright 1986-2015 Xilinx, Inc. All Rights Reserved.
// --------------------------------------------------------------------------------
// Tool Version: Vivado v.2015.4 (win64) Build 1412921 Wed Nov 18 09:43:45 MST 2015
// Date        : Thu Jan 25 21:19:24 2018
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
G89oB9LalCo/wgfnzUEhmIYWdWK/60pOBJgGIQcfAnFAj7FQdQNfVpHPd8NRah5f/Mhnovf5NTz2
VallPALurbJe15Wsg1NlmkI83tDbC7PjLupv4vRb8YAEZUjc3HButtBNOKWp6Ca/Zho4cPO4MUlG
qO0deU68OL3Vtz1wkNQqJYVXLcNo7dmC0V0k9ZNSiOyYF67duSTLSGDrxz4jScf2Teq49wMfq10b
0VSMNBxaqy+8K74/7m8SN41lF+aA/zDPq10VRf/EKdGtMoQaaNXZDXul6/lcbJYxkbfLjgGGvsFI
QBZUF3Ea1lwZ7cZH4+uvtbTxUDA5fn3og99OXQ==


`pragma protect key_keyowner = "Synplicity", key_keyname= "SYNP05_001", key_method = "rsa"
`pragma protect encoding = (enctype = "BASE64", line_length = 76, bytes = 256)
`pragma protect key_block
m2JhalZcUA/ae8KrcsxMYt+SsVp79gfyeRxoCxS1FBT3FUjUww9e7z22uUtuPT8ThAsD5S38xRZ5
I7pvfcIarH9w9+EV5Vaw/qV6baIwKhfw+npkH0tErd4h6sPNRIQL3JOJESfdNArZg3qjiLb8yfha
0tmRWNvpyo/HbNSjH/vsUpuRl/zRhWm3y2pdUKQ9UZMgMyoJDl1iL76zb1QiXdsKSqGrnsz5EeAl
uMwCP60MSJBRyP7raoQ7XmprfYBRvx5G4bfFD/MtN6V748bUzOZLtolzQELE+vqqtRSnTSkd1l1V
IGKpIhAVLL5K+InR4vveeVcPSflMv/epjnhuGQ==


`pragma protect data_method = "AES128-CBC"
`pragma protect encoding = (enctype = "BASE64", line_length = 76, bytes = 7248)
`pragma protect data_block
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
QKPcTGwwa63M
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
