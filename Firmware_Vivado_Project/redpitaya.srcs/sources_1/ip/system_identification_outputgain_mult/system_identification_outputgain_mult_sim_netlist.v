// Copyright 1986-2015 Xilinx, Inc. All Rights Reserved.
// --------------------------------------------------------------------------------
// Tool Version: Vivado v.2015.4 (win64) Build 1412921 Wed Nov 18 09:43:45 MST 2015
// Date        : Wed Jun 06 20:22:14 2018
// Host        : laptopjd running 64-bit Service Pack 1  (build 7601)
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
q9nX+U2oV67WalYnlXFZN2QYYKcG1b/CQG0Mjum+N1ZhICb8nJ8nsx/kwTvfIpw1yi5P+YrkGv7M
kAMndTm4U9zBMbXBPR3uiYX9LAR+HdFN2O+beKD5kx4UqwI/SBJAwy9oCdF2bEI+tdS3llic9fgv
BNKcclrtDcIciOVgPzx159ZLZ77ePuAiK31hHyiTrDFEZuXNcDsV7ixOLLBeMVX/RFlb6MxnXk0k
5NPcr0Qj4FYW+U8Oc2kTlOAZua59IOgF8UJpNd1eUrJ7f/j2ydQw/3K64j2+3hkvw3X8Cm//5/U3
vVjLU3QD8kRnb8/tv2sU67xUYwUU8lkXPD25GA==


`pragma protect key_keyowner = "Synplicity", key_keyname= "SYNP05_001", key_method = "rsa"
`pragma protect encoding = (enctype = "BASE64", line_length = 76, bytes = 256)
`pragma protect key_block
NWfPb2j3ozyo5u1Hf5xbXOaZf8ofZzCDMVdHy208C7nrdmrTC0p0JuuRNvBFc3+CG+9vEeRj5e/2
DDx+YeK3aBdybQBd9UNHJPDcpriwRMnDRd2e6v+D0qrv7xPo93SRApFdnfz5ATwrcVpuxHwafNEa
LF5iU1ifpab4t7VIOgEb7xpRCCNkt+MuP1AsOuu8hLoHzw/hUSX9wqbrQHyjV146nUnBeBbG5BmN
KLBFcneE8PM4MUoH04G23BRjARGL9iaJmESoiiZ0LsmcC6Qo4btTa1EulDG8erdGzykhmmMQC3kU
eNbpkeFNJztg4q8OML6JHGSIqZD5MBxDm7M7eQ==


`pragma protect data_method = "AES128-CBC"
`pragma protect encoding = (enctype = "BASE64", line_length = 76, bytes = 8608)
`pragma protect data_block
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
Bw==
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
