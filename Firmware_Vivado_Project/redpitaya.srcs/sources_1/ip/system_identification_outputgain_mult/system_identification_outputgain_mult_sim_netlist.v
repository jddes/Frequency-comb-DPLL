// Copyright 1986-2015 Xilinx, Inc. All Rights Reserved.
// --------------------------------------------------------------------------------
// Tool Version: Vivado v.2015.4 (win64) Build 1412921 Wed Nov 18 09:43:45 MST 2015
// Date        : Tue Feb 13 15:27:48 2018
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
pXQO6k/yjWbWJ47MbvQbFsOgY6fQ12bIM7lox0i38U4GcCKFbFKw5rpsmeMKmdHnl2GFWyskEcfH
jtpYzwROHlt1M7Dkq556MmHKaIpGtKGUCZnwiK+91FHnO9aECENFMWRYFbTy2obZDRN7HzGrn7WG
g/vkPklEIV3M1lRaVd3OYxWbT+VffL+uxyyvYDczrx12qNDV4ynSXdQahH4gJMyKl4HqF/PMvCIR
HcyeA56XiWD6rpw0pmebzaIz/E4AL4/GdxrWayeiNmu4uqVcUO5d2doVShPgm95zwpa4VRXCjpE/
Qbcvt1jSJ2wyD1ph5//GaUWczoV1d+B4ltRrvw==


`pragma protect key_keyowner = "Synplicity", key_keyname= "SYNP05_001", key_method = "rsa"
`pragma protect encoding = (enctype = "BASE64", line_length = 76, bytes = 256)
`pragma protect key_block
LhXGY3p2/LXOoL1tZAxyZxinD+ZluqfuFBS91/kvzs20WgRtfgEgBEJ6ENTIJKR3DSOsgRbu4ZQ4
iH5+cqyzxBdf7zi8q5yTkCmYhl73knYL5/U6kywOdGrq2yEj0N7lD4UO6//I92T/EUmSywY0xTSj
zzZkOAVGz1jQc/soaWNhehbejHKlFbwB4yLW/QbQLJ0J4AgQbJsxlOtKSucMxPCRaFHLXuoyvrd7
1YXa+H3xlPn+toeBCXhqcGdBo2dNVwuHKlpJ0iC301rh1d/qlTmFqJmuGpxe3RG5sto1f4MFPqVL
EBs6+sCwWRRjpGKqZJaHe1gZua2cP2BQ+7eFVg==


`pragma protect data_method = "AES128-CBC"
`pragma protect encoding = (enctype = "BASE64", line_length = 76, bytes = 8608)
`pragma protect data_block
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
zw==
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
