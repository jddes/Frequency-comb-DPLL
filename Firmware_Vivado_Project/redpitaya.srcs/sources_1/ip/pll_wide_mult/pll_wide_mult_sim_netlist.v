// Copyright 1986-2015 Xilinx, Inc. All Rights Reserved.
// --------------------------------------------------------------------------------
// Tool Version: Vivado v.2015.4 (win64) Build 1412921 Wed Nov 18 09:43:45 MST 2015
// Date        : Tue Feb 13 15:26:48 2018
// Host        : laptopjd running 64-bit Service Pack 1  (build 7601)
// Command     : write_verilog -force -mode funcsim
//               D:/Repo/Frequency-comb-DPLL/Firmware_Vivado_Project/redpitaya.srcs/sources_1/ip/pll_wide_mult/pll_wide_mult_sim_netlist.v
// Design      : pll_wide_mult
// Purpose     : This verilog netlist is a functional simulation representation of the design and should not be modified
//               or synthesized. This netlist cannot be used for SDF annotated simulation.
// Device      : xc7z010clg400-1
// --------------------------------------------------------------------------------
`timescale 1 ps / 1 ps

(* CHECK_LICENSE_TYPE = "pll_wide_mult,mult_gen_v12_0_10,{}" *) (* core_generation_info = "pll_wide_mult,mult_gen_v12_0_10,{x_ipProduct=Vivado 2015.4,x_ipVendor=xilinx.com,x_ipLibrary=ip,x_ipName=mult_gen,x_ipVersion=12.0,x_ipCoreRevision=10,x_ipLanguage=VERILOG,x_ipSimLanguage=MIXED,C_VERBOSITY=0,C_MODEL_TYPE=0,C_OPTIMIZE_GOAL=1,C_XDEVICEFAMILY=zynq,C_HAS_CE=0,C_HAS_SCLR=1,C_LATENCY=5,C_A_WIDTH=10,C_A_TYPE=0,C_B_WIDTH=32,C_B_TYPE=0,C_OUT_HIGH=41,C_OUT_LOW=0,C_MULT_TYPE=1,C_CE_OVERRIDES_SCLR=0,C_CCM_IMP=0,C_B_VALUE=10000001,C_HAS_ZERO_DETECT=0,C_ROUND_OUTPUT=0,C_ROUND_PT=0}" *) (* downgradeipidentifiedwarnings = "yes" *) 
(* x_core_info = "mult_gen_v12_0_10,Vivado 2015.4" *) 
(* NotValidForBitStream *)
module pll_wide_mult
   (CLK,
    A,
    B,
    SCLR,
    P);
  (* x_interface_info = "xilinx.com:signal:clock:1.0 clk_intf CLK" *) input CLK;
  (* x_interface_info = "xilinx.com:signal:data:1.0 a_intf DATA" *) input [9:0]A;
  (* x_interface_info = "xilinx.com:signal:data:1.0 b_intf DATA" *) input [31:0]B;
  (* x_interface_info = "xilinx.com:signal:reset:1.0 sclr_intf RST" *) input SCLR;
  (* x_interface_info = "xilinx.com:signal:data:1.0 p_intf DATA" *) output [41:0]P;

  wire [9:0]A;
  wire [31:0]B;
  wire CLK;
  wire [41:0]P;
  wire SCLR;
  wire [47:0]NLW_U0_PCASC_UNCONNECTED;
  wire [1:0]NLW_U0_ZERO_DETECT_UNCONNECTED;

  (* C_A_TYPE = "0" *) 
  (* C_A_WIDTH = "10" *) 
  (* C_B_TYPE = "0" *) 
  (* C_B_VALUE = "10000001" *) 
  (* C_B_WIDTH = "32" *) 
  (* C_CCM_IMP = "0" *) 
  (* C_CE_OVERRIDES_SCLR = "0" *) 
  (* C_HAS_CE = "0" *) 
  (* C_HAS_SCLR = "1" *) 
  (* C_HAS_ZERO_DETECT = "0" *) 
  (* C_LATENCY = "5" *) 
  (* C_MODEL_TYPE = "0" *) 
  (* C_MULT_TYPE = "1" *) 
  (* C_OPTIMIZE_GOAL = "1" *) 
  (* C_OUT_HIGH = "41" *) 
  (* C_OUT_LOW = "0" *) 
  (* C_ROUND_OUTPUT = "0" *) 
  (* C_ROUND_PT = "0" *) 
  (* C_VERBOSITY = "0" *) 
  (* C_XDEVICEFAMILY = "zynq" *) 
  (* downgradeipidentifiedwarnings = "yes" *) 
  pll_wide_mult_mult_gen_v12_0_10 U0
       (.A(A),
        .B(B),
        .CE(1'b1),
        .CLK(CLK),
        .P(P),
        .PCASC(NLW_U0_PCASC_UNCONNECTED[47:0]),
        .SCLR(SCLR),
        .ZERO_DETECT(NLW_U0_ZERO_DETECT_UNCONNECTED[1:0]));
endmodule

(* C_A_TYPE = "0" *) (* C_A_WIDTH = "10" *) (* C_B_TYPE = "0" *) 
(* C_B_VALUE = "10000001" *) (* C_B_WIDTH = "32" *) (* C_CCM_IMP = "0" *) 
(* C_CE_OVERRIDES_SCLR = "0" *) (* C_HAS_CE = "0" *) (* C_HAS_SCLR = "1" *) 
(* C_HAS_ZERO_DETECT = "0" *) (* C_LATENCY = "5" *) (* C_MODEL_TYPE = "0" *) 
(* C_MULT_TYPE = "1" *) (* C_OPTIMIZE_GOAL = "1" *) (* C_OUT_HIGH = "41" *) 
(* C_OUT_LOW = "0" *) (* C_ROUND_OUTPUT = "0" *) (* C_ROUND_PT = "0" *) 
(* C_VERBOSITY = "0" *) (* C_XDEVICEFAMILY = "zynq" *) (* ORIG_REF_NAME = "mult_gen_v12_0_10" *) 
(* downgradeipidentifiedwarnings = "yes" *) 
module pll_wide_mult_mult_gen_v12_0_10
   (CLK,
    A,
    B,
    CE,
    SCLR,
    ZERO_DETECT,
    P,
    PCASC);
  input CLK;
  input [9:0]A;
  input [31:0]B;
  input CE;
  input SCLR;
  output [1:0]ZERO_DETECT;
  output [41:0]P;
  output [47:0]PCASC;

  wire [9:0]A;
  wire [31:0]B;
  wire CE;
  wire CLK;
  wire [41:0]P;
  wire [47:0]PCASC;
  wire SCLR;
  wire [1:0]ZERO_DETECT;

  (* C_A_TYPE = "0" *) 
  (* C_A_WIDTH = "10" *) 
  (* C_B_TYPE = "0" *) 
  (* C_B_VALUE = "10000001" *) 
  (* C_B_WIDTH = "32" *) 
  (* C_CCM_IMP = "0" *) 
  (* C_CE_OVERRIDES_SCLR = "0" *) 
  (* C_HAS_CE = "0" *) 
  (* C_HAS_SCLR = "1" *) 
  (* C_HAS_ZERO_DETECT = "0" *) 
  (* C_LATENCY = "5" *) 
  (* C_MODEL_TYPE = "0" *) 
  (* C_MULT_TYPE = "1" *) 
  (* C_OPTIMIZE_GOAL = "1" *) 
  (* C_OUT_HIGH = "41" *) 
  (* C_OUT_LOW = "0" *) 
  (* C_ROUND_OUTPUT = "0" *) 
  (* C_ROUND_PT = "0" *) 
  (* C_VERBOSITY = "0" *) 
  (* C_XDEVICEFAMILY = "zynq" *) 
  (* downgradeipidentifiedwarnings = "yes" *) 
  pll_wide_mult_mult_gen_v12_0_10_viv i_mult
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
Ixy6B7gYwOv7lYY7o4EKeE3M+3epUTeHkFgQHKpUcHbyMkB89fvONRA2SKPYSniy+9LW4CfZgHI7
VxnKCsBrZnjgx+4+Jo7jjxMvEYXAVW4EONq+bmCz88M7Val8Md2ck8cJeJlIns9So/8cKDpa8O6+
xSO4JlA2DqQeB0MjGxlAz0IUu00yB3KhZaM2uVE0ac85GssPufnjedf9T+9N541w5uOMHdlrvJaS
Xs+uB/jNRZAkV6SK7BSymUTgNn4TDhfkALh71OOAICl0j0PYUkZLr1fPEujNM+/53nz+DOeCmX1v
4oHN+HHhcowrmXmI5DmfSAgIFVUUNrZVt+8gvg==


`pragma protect key_keyowner = "Synplicity", key_keyname= "SYNP05_001", key_method = "rsa"
`pragma protect encoding = (enctype = "BASE64", line_length = 76, bytes = 256)
`pragma protect key_block
t1pqwIWcZt4ZbzoccFVixI9+PFUKJrZfYoOOc1sjYz6hA5ArwmIYxDOzSEa6JJ342osAuI9Hh1eG
Bk6P9/7bP1oKPQZGNLLZoa/Zh9VcRps4jxqqmIhcKW2TV5fEjSB2UWCi9q48jYu8zLO+2cX5YdaX
GHMLjny/sczaUgCl0bRpRTa9mspf8UbEB56DfvOkqzmC7Q31NCPAw0bTPQSMe41HT4gmCSyk5LEV
HJNOcVw4cpjd/gHb/wmjflW9rxnvnNCpC3tbr7y4KqCtfq1OpNX1dDnLTvOvkJrf07UDWfCWzrMp
HcikEPFZYfgCAokCRFGZgmSOcQGAZV77zuVE7w==


`pragma protect data_method = "AES128-CBC"
`pragma protect encoding = (enctype = "BASE64", line_length = 76, bytes = 22816)
`pragma protect data_block
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
j9jUVK71BlhItkPcfd/jeA==
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
