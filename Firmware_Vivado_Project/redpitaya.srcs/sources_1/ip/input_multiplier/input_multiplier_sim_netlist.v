// Copyright 1986-2015 Xilinx, Inc. All Rights Reserved.
// --------------------------------------------------------------------------------
// Tool Version: Vivado v.2015.4 (win64) Build 1412921 Wed Nov 18 09:43:45 MST 2015
// Date        : Sat Aug 12 15:54:37 2017
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
lRFUy+7JAH0KsewotZDhArAmEVLyEL2zimE9DlSJLtxkLTjmv7Ab5JSbhLJ1Vy8RVkfpG8Tqf0R9
2DSQ+33CZPyiZE2zYN+dcwn/sw0kJWHHvUN61TGyOk5l7+dX/nSBZ28GgNbMnh0yrkodwOYB0FeF
Q29we8Kr29CopeBTfng0E7PFG5jhBc6NJBNdIpuJq6JTdzTRrEeLI2Ki+Jm3rOswVQYJg8F64frk
F7QDF5sPHx+zDmdpDydloAGQY8sG0n6oUEMJmSTW24j4IKOepp0gP0n8JE4YHPysUjr3iLt/YXKZ
ia/oLtfMvhI5DV+Yt+zjDYgnBNdjnMw2eea7lw==


`pragma protect key_keyowner = "Synplicity", key_keyname= "SYNP05_001", key_method = "rsa"
`pragma protect encoding = (enctype = "BASE64", line_length = 76, bytes = 256)
`pragma protect key_block
eS81J5xVlZJERImxSxzsz5/Ba8ovEbZkaB9YisTdOnepAwc7Z1wWrXtQjW9MFUAsrf0Wn8VnuzpI
9ptXTPSm48tRHKpCMQyKbTdSbGz+/LoehUVJpwwb2UD5OdIccyPybxBZEWxM0xVzDWDwXfL56ILD
erLoki5FfJp+/nX22FbbIynJaPcVr2YknImCQVsVJK2wlawn4HwhdKLNgdlcVZtxQcAhAODP1KIf
S5/CwLUZ2m82n/7mOuvlBt9SPiNEjydGdz1zTIQIUEr4LfknK3xhPdyJ5pJXdOzmzguSi6zP1QPa
CgPQP9u8o0szoNdRO/I//y0GTE97n++p6OShCw==


`pragma protect data_method = "AES128-CBC"
`pragma protect encoding = (enctype = "BASE64", line_length = 76, bytes = 7248)
`pragma protect data_block
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
TpP0F9H2KJhP
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
