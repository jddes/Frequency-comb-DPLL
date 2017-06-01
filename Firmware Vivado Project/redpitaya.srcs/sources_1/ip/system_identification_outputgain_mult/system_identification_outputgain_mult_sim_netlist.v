// Copyright 1986-2015 Xilinx, Inc. All Rights Reserved.
// --------------------------------------------------------------------------------
// Tool Version: Vivado v.2015.4 (lin64) Build 1412921 Wed Nov 18 09:44:32 MST 2015
// Date        : Sat Aug 13 02:05:58 2016
// Host        : jd-VirtualBox running 64-bit Ubuntu 14.04.3 LTS
// Command     : write_verilog -force -mode funcsim
//               /media/sf_D/Projects/RedPitaya/fpga/project/redpitaya.srcs/sources_1/ip/system_identification_outputgain_mult/system_identification_outputgain_mult_sim_netlist.v
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
C3P3fh8lZf8ytbMO0uebw2RFFXPvsoOyXwOLRAzmIfrcESwig0npwC/kUE1ww1S4CwRc5Ew53qoJ
WMRaL/jnhMukfCsvUGwZuBgDbwX0qwmfEm6Hkp25PTRNjt39vm5ihzAiwca40TzIy2pBCnzN+J5R
G3OnHIumHiBcJqIEvaCWyJHdnxzk1mvew8Msj/uBOknUZOZKXEATRVlu3CCloB0kDYDhklgd3gTL
FQHOkDzA9XK7gk+1Gnuz5l7CRHinEshcTIjr2KI9B07XLRFVK7brrso8RFMeLlCiturcy5IZ2sXV
ap5BWBK7fIu53Ujr11XvyveEF3KI1DNBCeRVpQ==


`pragma protect key_keyowner = "Synplicity", key_keyname= "SYNP05_001", key_method = "rsa"
`pragma protect encoding = (enctype = "BASE64", line_length = 76, bytes = 256)
`pragma protect key_block
idJsUDaA2ZLz2DZ/4LH7NwV/Ki0bWmuUg41H10EsbUfs1dupNmXYU0mfNBtd+KAJf9wGfzSkuJmC
8Lt3i1Nrws4xWLYxiEo1zCVjTLofmsmgQWnnBT9TQzHrwKE49rF2lyGf6bsR8ItxEqCJZhKneCUZ
SM32ooQXGpxhOhr0uBPDUfFoNM35TnIh0+HQSaIXcBLFEzKDbN+6FksAGymbRmUWhr6Dt2HNZe7D
4uE6tiRg67vbGBj1axd7M3R3u/orOpyZtc8VHwebcKTkuiAII3eDGO7yHbOS3WB0UGPwz+6dssw1
dkuFjMJ4dXna6X7xngSsPcf1ScXEAGWCiqSRfw==


`pragma protect data_method = "AES128-CBC"
`pragma protect encoding = (enctype = "BASE64", line_length = 76, bytes = 8608)
`pragma protect data_block
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
Ug==
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
