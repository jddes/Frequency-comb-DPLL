// Copyright 1986-2015 Xilinx, Inc. All Rights Reserved.
// --------------------------------------------------------------------------------
// Tool Version: Vivado v.2015.4 (win64) Build 1412921 Wed Nov 18 09:43:45 MST 2015
// Date        : Tue Aug 01 23:37:41 2017
// Host        : jdbureau running 64-bit major release  (build 9200)
// Command     : write_verilog -force -mode funcsim {D:/Repo/Frequency-comb-DPLL/Firmware Vivado
//               Project/redpitaya.srcs/sources_1/ip/system_identification_outputgain_mult/system_identification_outputgain_mult_sim_netlist.v}
// Design      : system_identification_outputgain_mult
// Purpose     : This verilog netlist is a functional simulation representation of the design and should not be modified
//               or synthesized. This netlist cannot be used for SDF annotated simulation.
// Device      : xc7z010clg400-1
// --------------------------------------------------------------------------------
`timescale 1 ps / 1 ps

(* CHECK_LICENSE_TYPE = "system_identification_outputgain_mult,mult_gen_v12_0_10,{}" *) (* core_generation_info = "system_identification_outputgain_mult,mult_gen_v12_0_10,{x_ipProduct=Vivado 2015.4,x_ipVendor=xilinx.com,x_ipLibrary=ip,x_ipName=mult_gen,x_ipVersion=12.0,x_ipCoreRevision=10,x_ipLanguage=VERILOG,x_ipSimLanguage=MIXED,C_VERBOSITY=0,C_MODEL_TYPE=0,C_OPTIMIZE_GOAL=1,C_XDEVICEFAMILY=zynq,C_HAS_CE=0,C_HAS_SCLR=1,C_LATENCY=2,C_A_WIDTH=16,C_A_TYPE=0,C_B_WIDTH=18,C_B_TYPE=0,C_OUT_HIGH=30,C_OUT_LOW=15,C_MULT_TYPE=1,C_CE_OVERRIDES_SCLR=0,C_CCM_IMP=0,C_B_VALUE=10000001,C_HAS_ZERO_DETECT=0,C_ROUND_OUTPUT=0,C_ROUND_PT=0}" *) (* downgradeipidentifiedwarnings = "yes" *) 
(* x_core_info = "mult_gen_v12_0_10,Vivado 2015.4" *) 
(* NotValidForBitStream *)
module system_identification_outputgain_mult
   (CLK,
    A,
    B,
    SCLR,
    P);
  (* x_interface_info = "xilinx.com:signal:clock:1.0 clk_intf CLK" *) input CLK;
  (* x_interface_info = "xilinx.com:signal:data:1.0 a_intf DATA" *) input [15:0]A;
  (* x_interface_info = "xilinx.com:signal:data:1.0 b_intf DATA" *) input [17:0]B;
  (* x_interface_info = "xilinx.com:signal:reset:1.0 sclr_intf RST" *) input SCLR;
  (* x_interface_info = "xilinx.com:signal:data:1.0 p_intf DATA" *) output [15:0]P;

  wire [15:0]A;
  wire [17:0]B;
  wire CLK;
  wire [15:0]P;
  wire SCLR;
  wire [47:0]NLW_U0_PCASC_UNCONNECTED;
  wire [1:0]NLW_U0_ZERO_DETECT_UNCONNECTED;

  (* C_A_TYPE = "0" *) 
  (* C_A_WIDTH = "16" *) 
  (* C_B_TYPE = "0" *) 
  (* C_B_VALUE = "10000001" *) 
  (* C_B_WIDTH = "18" *) 
  (* C_CCM_IMP = "0" *) 
  (* C_CE_OVERRIDES_SCLR = "0" *) 
  (* C_HAS_CE = "0" *) 
  (* C_HAS_SCLR = "1" *) 
  (* C_HAS_ZERO_DETECT = "0" *) 
  (* C_LATENCY = "2" *) 
  (* C_MODEL_TYPE = "0" *) 
  (* C_MULT_TYPE = "1" *) 
  (* C_OPTIMIZE_GOAL = "1" *) 
  (* C_OUT_HIGH = "30" *) 
  (* C_OUT_LOW = "15" *) 
  (* C_ROUND_OUTPUT = "0" *) 
  (* C_ROUND_PT = "0" *) 
  (* C_VERBOSITY = "0" *) 
  (* C_XDEVICEFAMILY = "zynq" *) 
  (* downgradeipidentifiedwarnings = "yes" *) 
  system_identification_outputgain_mult_mult_gen_v12_0_10 U0
       (.A(A),
        .B(B),
        .CE(1'b1),
        .CLK(CLK),
        .P(P),
        .PCASC(NLW_U0_PCASC_UNCONNECTED[47:0]),
        .SCLR(SCLR),
        .ZERO_DETECT(NLW_U0_ZERO_DETECT_UNCONNECTED[1:0]));
endmodule

(* C_A_TYPE = "0" *) (* C_A_WIDTH = "16" *) (* C_B_TYPE = "0" *) 
(* C_B_VALUE = "10000001" *) (* C_B_WIDTH = "18" *) (* C_CCM_IMP = "0" *) 
(* C_CE_OVERRIDES_SCLR = "0" *) (* C_HAS_CE = "0" *) (* C_HAS_SCLR = "1" *) 
(* C_HAS_ZERO_DETECT = "0" *) (* C_LATENCY = "2" *) (* C_MODEL_TYPE = "0" *) 
(* C_MULT_TYPE = "1" *) (* C_OPTIMIZE_GOAL = "1" *) (* C_OUT_HIGH = "30" *) 
(* C_OUT_LOW = "15" *) (* C_ROUND_OUTPUT = "0" *) (* C_ROUND_PT = "0" *) 
(* C_VERBOSITY = "0" *) (* C_XDEVICEFAMILY = "zynq" *) (* ORIG_REF_NAME = "mult_gen_v12_0_10" *) 
(* downgradeipidentifiedwarnings = "yes" *) 
module system_identification_outputgain_mult_mult_gen_v12_0_10
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
  input [17:0]B;
  input CE;
  input SCLR;
  output [1:0]ZERO_DETECT;
  output [15:0]P;
  output [47:0]PCASC;

  wire [15:0]A;
  wire [17:0]B;
  wire CE;
  wire CLK;
  wire [15:0]P;
  wire [47:0]PCASC;
  wire SCLR;
  wire [1:0]ZERO_DETECT;

  (* C_A_TYPE = "0" *) 
  (* C_A_WIDTH = "16" *) 
  (* C_B_TYPE = "0" *) 
  (* C_B_VALUE = "10000001" *) 
  (* C_B_WIDTH = "18" *) 
  (* C_CCM_IMP = "0" *) 
  (* C_CE_OVERRIDES_SCLR = "0" *) 
  (* C_HAS_CE = "0" *) 
  (* C_HAS_SCLR = "1" *) 
  (* C_HAS_ZERO_DETECT = "0" *) 
  (* C_LATENCY = "2" *) 
  (* C_MODEL_TYPE = "0" *) 
  (* C_MULT_TYPE = "1" *) 
  (* C_OPTIMIZE_GOAL = "1" *) 
  (* C_OUT_HIGH = "30" *) 
  (* C_OUT_LOW = "15" *) 
  (* C_ROUND_OUTPUT = "0" *) 
  (* C_ROUND_PT = "0" *) 
  (* C_VERBOSITY = "0" *) 
  (* C_XDEVICEFAMILY = "zynq" *) 
  (* downgradeipidentifiedwarnings = "yes" *) 
  system_identification_outputgain_mult_mult_gen_v12_0_10_viv i_mult
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
aVT15UcAaWP5ATvbV2K7uHvN3g1mYpee690t19I3gneLX4akXWf7Z835MV8UMdjWQgbTpJf7Ww/a
+OSvQfKfViIrAFFJkFFgWC3RVMfK1+EJNzKlk174SP1fygo0WlmjRMeQ0VtHJ/oLluvbFJrjjotV
ZY3ZJTHzxrIVs2DAfGYMwTAXTEAZUy8OLAHsz70QLn1GFajPNxTA2w9POmIdxyWqXPaGShIQvrfT
yh0k35T0ESPLOmPG8kBDROj4kPM6cw9OXA+K6azFQm39T46Vt3y2cVXuBjqOPzbVr/s2Vy7jWriC
iQlwDobuaSzWRRLApk/NnBhpt3rBDqz/zGg/mQ==


`pragma protect key_keyowner = "Synplicity", key_keyname= "SYNP05_001", key_method = "rsa"
`pragma protect encoding = (enctype = "BASE64", line_length = 76, bytes = 256)
`pragma protect key_block
vGv+KEn+OYaL6Ro2inByIbKbqwCAQ/IW2TEesPrrgxsp6sxpKaPnWk+meMhLxpvauoX2Xauh1Nzc
FDnX19/gON74nSQTh412XBg5qfdjAcpaTRyu+AfV0Wh1aXmEcNdUlmUk/I4UNgoTxs2jBi/ucgau
4988ls+xOyLM9/e3xVNa+x647To8w1LVYEQzA+twMKnDEJ4n1goYfrg9w2T6iUCtY20d5F+6o5Yd
fNhSm00d/UtsBzLcn0PChvIJsKqUD9Te06e0VEUiE9Na5uPDm561JWGCPpDGFvt0tS+NyqY8d6Ir
p8BkYLzMMRphYhjuSR+x/Q3QLsJxxtQhIqNkew==


`pragma protect data_method = "AES128-CBC"
`pragma protect encoding = (enctype = "BASE64", line_length = 76, bytes = 8608)
`pragma protect data_block
+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
9w==
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
