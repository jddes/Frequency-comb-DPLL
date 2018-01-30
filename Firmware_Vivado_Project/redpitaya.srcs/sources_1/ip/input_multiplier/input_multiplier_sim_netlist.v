// Copyright 1986-2015 Xilinx, Inc. All Rights Reserved.
// --------------------------------------------------------------------------------
// Tool Version: Vivado v.2015.4 (win64) Build 1412921 Wed Nov 18 09:43:45 MST 2015
// Date        : Tue Jan 30 05:13:10 2018
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
m/yM9b8/DZA/Jz7edCo8JRG3KbEy+KmT1QOGM4VCE3mYlqQBG0c0/+JfzRR5L8ufAInpv0vA6QZ+
IFQNF+sY/dmWIBDdZ8d5V0or1S8uqEaV9wegK/agX+g11A1aVfh6GOgrW2W4ufgBSRdEaz8uSnjC
6QzW9V0QV+4sqsFWOyJ7LBr02Oz4bJRtbE5ZRAlOP6E03iyV4t0bDcrtPidgNN02bJd4thlKjsLn
qY9GohdpLlYdFGWitiNa0tdRAounJx0+3ygLQuT46oblD6/ppnbCdF+jpB/CRxOtyqtWbTS58eG+
rnJVRkfmQy2awMeY6Jc5tR9lSuIWrwOTx9UQiA==


`pragma protect key_keyowner = "Synplicity", key_keyname= "SYNP05_001", key_method = "rsa"
`pragma protect encoding = (enctype = "BASE64", line_length = 76, bytes = 256)
`pragma protect key_block
T0R/sVqrwo2XxsC/ErfGLlpLbOxMTNSDdKspnikZuoUdaUVP8Vmhm/RNm0iVgBT7q9SXN3VVHSFh
Q4RKXCv6cHdIwc5EahOYKXwZbkeTzVWWL/1kB/WLNyPOlFrkCUWwKSXmL7bFT+IRALg1RJNtVLbC
E11l0t3uxC0RWUETsPZp9z3+gbaTkdz3TREnv/c6zcYMN2SIhdqRo4wkZQWHyxQHWEIZqvVt8Ge0
S/cSfHTWHZR7A9vvK6PwdZtAL5gzEUOrg0MJIkHJZ+bcWN9u7WilK6YrdkwywoVgI7qengkZX3Lr
jXNPZKZiblwSMDo1FZR1/Yi4UXFtk5XWSL4KTw==


`pragma protect data_method = "AES128-CBC"
`pragma protect encoding = (enctype = "BASE64", line_length = 76, bytes = 7248)
`pragma protect data_block
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
2tkhfTDGThmO
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
