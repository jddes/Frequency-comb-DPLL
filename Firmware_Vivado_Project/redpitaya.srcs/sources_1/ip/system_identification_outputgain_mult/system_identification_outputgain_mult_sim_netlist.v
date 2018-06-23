// Copyright 1986-2015 Xilinx, Inc. All Rights Reserved.
// --------------------------------------------------------------------------------
// Tool Version: Vivado v.2015.4 (win64) Build 1412921 Wed Nov 18 09:43:45 MST 2015
// Date        : Sat Jun 23 16:43:28 2018
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
c3toNyw533ANIF9on96TN2zeTNunowZ/Qp5xklMaFiqU+iP1QlW1k30Sqk0zbblqLEe0tezrv0BB
EYVl3MjwQYDi5gZryw44Rd59j/UfigYvXpZtMk2higUKVd9vt76FGmW3/V9/2DVHNAoru7pGuu2t
R+BPs88t0CltPvzXfabWXcF7fjrW3A9KbPiT0jrPJdlMu3PVPyMlNkmrPTe+ESpiHsk6CAlxM/v2
YirtygRcHsPqwI4NxPRKdOAUeiQs1fDu6QCXGc9RAoEvD26NSl+Rn7ODCKPeQ7rWbWLXamWYPpaP
oO5kgKR/8bnxDBdT/j9sCBNRujpNew3Gs6o3Pw==


`pragma protect key_keyowner = "Synplicity", key_keyname= "SYNP05_001", key_method = "rsa"
`pragma protect encoding = (enctype = "BASE64", line_length = 76, bytes = 256)
`pragma protect key_block
b5StRdzXn7DlDQREMlpveTlCPmvcas63xM4yJIyBlh7xhEy9Y2ZJk5Bcop2W2HkmDHx2m4UZhdjv
Eq9vFGXEywJV1W+um8G7BOaglfH1PEqCfHw2836NcBTfpnuHMDNyb3o6iAlLthNPv51yypJClj3W
u8U6Zv98p3jvOyDCsSxYbUhUBm5llFnS3mEAX+3d5EZPo770qX2NS7wXNfwFEdBMS/p/6T9B91Dy
Dn+qG1Mcq5zZOwEKHFzNVJ121Dn8Q/n2MfnBBABOcR5qyRgqthO2XGvYf/b97QwRxR49ykw2ucUY
P102cyYjMpDFdPpOmJGsMzy39CwAWKmGXZn7Ow==


`pragma protect data_method = "AES128-CBC"
`pragma protect encoding = (enctype = "BASE64", line_length = 76, bytes = 8608)
`pragma protect data_block
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
+g==
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
