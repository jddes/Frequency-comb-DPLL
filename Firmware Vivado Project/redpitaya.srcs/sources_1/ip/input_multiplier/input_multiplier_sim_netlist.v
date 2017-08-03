// Copyright 1986-2015 Xilinx, Inc. All Rights Reserved.
// --------------------------------------------------------------------------------
// Tool Version: Vivado v.2015.4 (win64) Build 1412921 Wed Nov 18 09:43:45 MST 2015
// Date        : Tue Jul 04 16:06:04 2017
// Host        : DESKTOP-OULANE9 running 64-bit major release  (build 9200)
// Command     : write_verilog -force -mode funcsim
//               {D:/Users/Alex/Documents/GitHub/Frequency-comb-DPLL_v2/Frequency-comb-DPLL-DPLL-python3/Firmware Vivado
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
Bn4zYnG4qayar6DoZ+Dxn3fN2g1xv134ONQ8ybyqZuNWezHY1bETvmNLqGUbcAG9hagmra97N730
HE4My6fM1+rR3j99Yw7fWgAazM7MKGJGtc9p50cmCZ2YCXwE3GReqWvikOvjQa8lxHeE0WsMqMmU
tpV5jmbWAWaLyKSlxKzoviMsjOCQhfxqkgp5bg2chsiIt1k/fQYmvRZFgZ9LdS/iWY74p6pMxCmd
jsZuEnIHWEbl0XieTLQYDje17DxW1r4ybkLrHTBq9cMrqinS9befeacOoRZVS2GYK7Sf8EkGP3Xu
O/+pbW+5xezqg/gBfH4h7Aulq/48qMVzZMkZ2A==


`pragma protect key_keyowner = "Synplicity", key_keyname= "SYNP05_001", key_method = "rsa"
`pragma protect encoding = (enctype = "BASE64", line_length = 76, bytes = 256)
`pragma protect key_block
NsyGMo+9d0G8Q0eoEsV9+pJO4kxMRp//mzbWe0hjHGZtabIprrk6XKpuXu5nEdptz+WIGLqurFr+
Q9f3bQLtpVcrUnTIKQO9tPdeb1kgcxETyGKAdhOsuRrGZ78n2nfx79NSV3UBHGeAAqjHP6n4BlD5
cGFUILvnbBzrMAoquvNw7x3EpS/KDRj5DQmn73ykbzBDy4tIqmzYzuS6oFMDWoKFyclXhAjo9BOt
eucMHSxd+qQw6c/rJLTPh3OFUNJTl8vuO0+qxUa1D2Kh2Ety+UlGluyjfo5DCgrnLfF+iXbLiD90
mDOZRzUqni2YCf87QBLxNsQzEKkgKG/88C1/9Q==


`pragma protect data_method = "AES128-CBC"
`pragma protect encoding = (enctype = "BASE64", line_length = 76, bytes = 7248)
`pragma protect data_block
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
HfZUMs/JoXIC
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
