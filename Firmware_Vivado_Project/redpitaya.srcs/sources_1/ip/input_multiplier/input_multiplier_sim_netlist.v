// Copyright 1986-2015 Xilinx, Inc. All Rights Reserved.
// --------------------------------------------------------------------------------
// Tool Version: Vivado v.2015.4 (win64) Build 1412921 Wed Nov 18 09:43:45 MST 2015
// Date        : Tue Feb 13 15:24:33 2018
// Host        : laptopjd running 64-bit Service Pack 1  (build 7601)
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
pXnRc9gfe7N8KqlHoGlYAI+HlfvxdVAI9AxchoOCZGXxk5+Mh3sknhQ74q1H+PVyTLD5tB4dEDwF
cG4E91xpsBLrRthbsTlPVOa/OZjxNKE2WC7baPp3dlEHDcd6TqXgJtJhVJdCfnJkEWyeptZtsI2L
qmq5H+v9OfCcXkdEXyJE8WpAoXdRGoS3PbEfwEqh8flRtYaKSC9YGtiQx93Re8YDXha5616AVEtL
QOO8HKKghq4aIlzCDGjmMXkq5FaBSJkSVsO1Cv1G1rHYB9JVq6inWKFE+JWlSS1f2BoAhSVa1U5G
+/mblZhAQWqeYX05hoaQT9GXjuUqwpBQu66XPQ==


`pragma protect key_keyowner = "Synplicity", key_keyname= "SYNP05_001", key_method = "rsa"
`pragma protect encoding = (enctype = "BASE64", line_length = 76, bytes = 256)
`pragma protect key_block
Q7UgYdwuPzyn3UR1jMfa5RdFvIntrYooGeM/aihIwbUuv4W7UAKftzPOrvdRK/GFd8IpUmSWtVN7
Rg1CAzAYYDqQWSO8XcmFR3V9y4GfmqyRZufg24LtuVqkHby4qUS8CR9Qjr0jp0EAFOIICfng28tF
dzHeDZeUAXZWfAPV3BkW/eMEGqojAkeM/Xb+R8D4sz71fJnN3PH1/8KoqDqlPkeq/vIKbNlAF9mK
u46TxCrH6KUpsNgE8KoKq0wqutISTMSVp5sYNL/LJCq1p21kW8D+tVsrunr5PEZxS49IiPQAH851
DRgW7HQs+62G13uD1WbLI2jxFdPCwevTkKs6eg==


`pragma protect data_method = "AES128-CBC"
`pragma protect encoding = (enctype = "BASE64", line_length = 76, bytes = 7248)
`pragma protect data_block
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
7XEiaaDmPFFZ
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
