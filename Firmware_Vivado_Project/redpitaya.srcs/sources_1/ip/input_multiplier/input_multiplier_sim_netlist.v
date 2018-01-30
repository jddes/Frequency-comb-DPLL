// Copyright 1986-2015 Xilinx, Inc. All Rights Reserved.
// --------------------------------------------------------------------------------
// Tool Version: Vivado v.2015.4 (win64) Build 1412921 Wed Nov 18 09:43:45 MST 2015
// Date        : Mon Jan 29 22:23:44 2018
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
cCQ3mJhnnWJG1AakJKdRtNw5Z3R0kviZ1O96rzMx09KBoBtcfRW7iVVDTOiTFDwGHuChFJt3QdcA
uIRkQfGK8iZ3pnaFsS9TFwwDcrtJUmcZyPrWmTjnyl8SpZSZ6tYWlP30/BrTxMlLVmQgOTpbq4eK
M45pT7g4jT+AhsXjjRMNJvYC2cpE7SC4VLJQE5ZcwX1e2Vo0wfHM5HgM5DBeww4k9p2R1vKB9cxp
97bdOrQXE1L/UtdPxy/IpZ4OCXDRpL+wq9f/uo8v4YmFHf7EOLW6jxtFH25Jd4Jc5sjjVKHUErQa
MRk+LbsMYagqO5d6+G4JXQFD5laAeNeJCYiIHA==


`pragma protect key_keyowner = "Synplicity", key_keyname= "SYNP05_001", key_method = "rsa"
`pragma protect encoding = (enctype = "BASE64", line_length = 76, bytes = 256)
`pragma protect key_block
Pw+eshD/S6A0W+q42skPQRi23Fg8V5ZLSBlSDhGo1o14CJX0o4fOQIJBKiLsuK8phUEFKsfXC6Tk
h7RdZWRnvUrDj/y2xvzR4uN/smAkaltxo7gpH34NPLkkT0+qMZI0b8IRPPMyn6hQi1e8Pg6+6+Cm
lcOc+bVvYBq0TJ7GJnbKlvNHykw7rcjupfIUoT60VtwlVQUBmuW82MAdwpYLdhP3tE37rYKKSO7o
7/L9o5x991V2o2l1/p7ezgQ3chpyndTAF9p+INR5moyh0BC9qsLgw4NLWyr1eh6CqSPk2QljJkaD
hFx7S4CE4VejMdJ0SFlm3vZYJ4esqcVdiEYifg==


`pragma protect data_method = "AES128-CBC"
`pragma protect encoding = (enctype = "BASE64", line_length = 76, bytes = 7248)
`pragma protect data_block
+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
I8MgAOqirwyf
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
