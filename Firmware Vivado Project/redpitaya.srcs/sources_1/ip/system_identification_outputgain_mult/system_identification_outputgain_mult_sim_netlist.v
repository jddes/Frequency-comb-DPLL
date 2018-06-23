// Copyright 1986-2015 Xilinx, Inc. All Rights Reserved.
// --------------------------------------------------------------------------------
// Tool Version: Vivado v.2015.4 (win64) Build 1412921 Wed Nov 18 09:43:45 MST 2015
// Date        : Sat Jun 23 00:23:08 2018
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
EUrpuBgOHNnfuZBhzn1oJMf9NUgYlvJrNUuwro6H44QxDB+jlkqGoI2s5tWRd5/+szb5TNdjEi+L
21wwnwdY4/E29rnX6Rw9IUGaEvn9rD7eP3/ranW4kmbpkTVD6s5lS4VSswpNFGqzJjRVIKLayqEs
gOPz9nnVDZ2cADWXifWP3p0UjIkmSRc+eZrqLmNnOeed7nsKE3dEU3bEKrsn2a5gLg0IBrIjkPbn
QQTBueZsVWfgMr97oMTSS5pu+iTEUdRG3uz889OaWxas1FqB7kp+JWup0yfFiaFQV1zZQCULtA5N
8e0nqBQo1byUhRk0mIRIs7fbJpHTBaMq75lt9Q==


`pragma protect key_keyowner = "Synplicity", key_keyname= "SYNP05_001", key_method = "rsa"
`pragma protect encoding = (enctype = "BASE64", line_length = 76, bytes = 256)
`pragma protect key_block
A0RK+/w79nuDoU8kMkUYiQ4o2Wt+gBaN5gYiFtOeZS51Lpt+zcqHztmDUTGFkipxTg2QX82jUzna
ejaTFgT1F3NIuW3waozs96G645uCGs77l8q6v6y8n99jHRxJj6ZYV9/55ReuEQUJ/oRbzed9huSV
cFScG1RIqc6rD/vsR8Cl2Om6O7Plic1W8zR6p4VJL2TNdJN1cHCT8lUl8UGLSd7oaYI2pRXxAqjo
go1ni23GnQyaxP6CwsQfZ9UeY+uBm42ttM6XLr083LGt5uBb4lgzSfiOm9b9LHb/FLwkmHyPCUUH
i0/+kFQr45zvJ1iOxBXn8CbsoIrK9b0hyJj7Zw==


`pragma protect data_method = "AES128-CBC"
`pragma protect encoding = (enctype = "BASE64", line_length = 76, bytes = 8608)
`pragma protect data_block
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
gQ==
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
