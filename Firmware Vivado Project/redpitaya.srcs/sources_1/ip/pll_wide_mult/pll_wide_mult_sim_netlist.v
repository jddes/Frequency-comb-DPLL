// Copyright 1986-2015 Xilinx, Inc. All Rights Reserved.
// --------------------------------------------------------------------------------
// Tool Version: Vivado v.2015.4 (win64) Build 1412921 Wed Nov 18 09:43:45 MST 2015
// Date        : Sat Aug 12 15:54:41 2017
// Host        : jdbureau running 64-bit major release  (build 9200)
// Command     : write_verilog -force -mode funcsim {D:/Repo/Frequency-comb-DPLL/Firmware Vivado
//               Project/redpitaya.srcs/sources_1/ip/pll_wide_mult/pll_wide_mult_sim_netlist.v}
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
chdDlwLaKOZ0wfU+NqawiQq50mcTw+UKGFiR6c/ngSga0yV6kPvE9Euq6gz2T+Io2NaOwDXUfgyk
anZoa8G8lYD5RIfGVKCaqQP5iHHHHCPPREbQR3rPsajPqabxasPK784C2/eXZ1f2xWM8jxpykjb6
++m1KxWJGUmT9gkYVhkhSob7N+DPlKwzMfUDw8AmDo5cxYKFYFro9qhwql3+wP2V7BeZZp/nFUUg
WPCGYDcasuXzRxuJdkrJ6fhtFsZrPunomM8GEuqZs8hXVhYtkFwHIj8HLfZ3da5ERvJpjN64WrqW
y2nFkb73KYbIUp8bCOfx0OYzmEZZx7/zuncScw==


`pragma protect key_keyowner = "Synplicity", key_keyname= "SYNP05_001", key_method = "rsa"
`pragma protect encoding = (enctype = "BASE64", line_length = 76, bytes = 256)
`pragma protect key_block
Q0GP780HP5dy15Qv00MsAYFsiFpUOPWZpbVj10MUNc74HW4vKIYf2ffYp1KZ8f/irDY+WB8GX2kw
GqfhB/Aauit5fHC/UGZCLQG/VGzkbXTXLArZxgODLbNCO7Dtz1o5buiN8GjoRDgGjMd72Uw8Kwsn
fjEXCVyEBUsu/yWuthy7UaXXZK3p7AEIopHqBuWxy0a9HkPPW0u2l5Sg7r7puLEpypxwSfn46GuN
Lk6t8XzOZ96SMp/kGAbhVSDr8/3jpY8f4CDvUesOhlZOy1UIh066VgjpKAcUIraISm951bjgHLXC
+jioz5pizknNPtrsNNTTDNUDiIB9widcGLsQkQ==


`pragma protect data_method = "AES128-CBC"
`pragma protect encoding = (enctype = "BASE64", line_length = 76, bytes = 22816)
`pragma protect data_block
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
0hHHnQjJzoix6of6nWHeyA==
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
