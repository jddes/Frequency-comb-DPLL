// Copyright 1986-2015 Xilinx, Inc. All Rights Reserved.
// --------------------------------------------------------------------------------
// Tool Version: Vivado v.2015.4 (win64) Build 1412921 Wed Nov 18 09:43:45 MST 2015
// Date        : Tue Jan 30 05:13:11 2018
// Host        : jdbureau running 64-bit major release  (build 9200)
// Command     : write_verilog -force -mode funcsim
//               D:/Repo/Frequency-comb-DPLL/Firmware_Vivado_Project/redpitaya.srcs/sources_1/ip/system_identification_outputgain_mult/system_identification_outputgain_mult_sim_netlist.v
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
G/v4XROpKPLn76aG+d4FqVPxlfN22MnD9Hb7f/jTRsB27cOPtLanaDw2SFXXP0jUCgeyEkgLX5Hi
B0VnE6VMyh/lnYpKTqJG6/qYS6SE/irHW6HbHGPryE21EsC847bfxOGCSyhnhWl0nIDdjYKkF6kD
+GOToydpiY1aelSb8Aye4+P9uTJ6Kt+Vm/Ipe95YB7Xk3foCoHFwCV99VjpmVfDcqTlMMn/aXANU
bKJKkEV1mxNCm6RKunSLR2ighsLdd6EfG6MRMhml/aQGvv+cA063YGjGmv0c020EMfqiDIROysDP
ag7kWzeGsiW5DEbupA8z6cK/rWOs/A6aHASk3A==


`pragma protect key_keyowner = "Synplicity", key_keyname= "SYNP05_001", key_method = "rsa"
`pragma protect encoding = (enctype = "BASE64", line_length = 76, bytes = 256)
`pragma protect key_block
TZ4nI0dlY1iGhlwwwl+5MoONLvu28rkZrH+N0lSajODH3VwXYv/ughmP6xEoI84bjCSawRz38mzN
6Vz9YEWibDsrBKU4OFqs/FyrzOX8tgO73XHeO6Z5Fes5IYJevpuEz2TKKBhdBMtRapEOsssbVYA0
mzi0bnO4Meh8Rte6LOBRtlZ9TEMW3A0ZfdulDj2Akoq5kHKwIpQnFpjSFSFyrt3ChjInw6IbN9vX
3gYrZCmNH2zhhyVMvgkO1ENMkEDS77HO83pzVEm5AEwiNWgZtbAWZ78hCvaENguBwCZhzZfb41yW
zVIF5Ro+IYHbfCmvf8RRIAfmeKP4BOECzOtxGA==


`pragma protect data_method = "AES128-CBC"
`pragma protect encoding = (enctype = "BASE64", line_length = 76, bytes = 8608)
`pragma protect data_block
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
oA==
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
