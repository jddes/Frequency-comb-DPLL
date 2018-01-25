// Copyright 1986-2015 Xilinx, Inc. All Rights Reserved.
// --------------------------------------------------------------------------------
// Tool Version: Vivado v.2015.4 (win64) Build 1412921 Wed Nov 18 09:43:45 MST 2015
// Date        : Thu Jan 25 14:57:04 2018
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
oRG4XkLMM/f2ubvtOfnR765xBFfFtwlBqUnsXaIUzz8diKrfkzCie0Qhgzon/wkybR8drYC43KAt
OTnSfqZzVKMw1fM4dbucfElFKJ64KXbW8LzpjypHhNxfmJWszMEd/vUGQSSdw6HFbFMwZoNOwGmD
fhke2Znr7oi9EYHC3xXojEnDPArmi8mkx+0VbdDyWaUPnsR608nto55UiATI/gULaAjVVcx2MWce
EZY370mTH6z55BI2Ibv2Ny0ashGtTtYOtsg2xZqbmqqhN9FAuJsbAanxeDVgAaLn/ns9ptyE4UlT
cYxTrm1EyU+7lAG1drAFl7Z2db/EjiVmo7CPyg==


`pragma protect key_keyowner = "Synplicity", key_keyname= "SYNP05_001", key_method = "rsa"
`pragma protect encoding = (enctype = "BASE64", line_length = 76, bytes = 256)
`pragma protect key_block
NceKpjFtdopaaDg3Sb5iuHUERCckpeB+fGOTmABU2CGd+Nh2nxxdivqM1iA1+sVAAi0Yr95lbN6Y
ht+QxM1d/gzutS9rSbgLszEXcNxFsb1qq4cC7RSVOLifVG6yaPg6qoOyyqBawZALtx9Wp+mxBbLp
IN2gbSUD/n2P/B5dVV02Hd50div4stXxKq9Zdd6HzM51ob8i6qRnjMtT5oDOdV1B7l0LHKLvo8Zl
BiD5S8XVjq+ZQEFT/PqJDxRaGT81b6CpEEVxysOse5cRHG5Ca3jomtZiPmMR4Re1ZfPXRh6jaA3z
azzP9dqiTvgPdZxSzSD+x61CDE7kd+ISBV0AdQ==


`pragma protect data_method = "AES128-CBC"
`pragma protect encoding = (enctype = "BASE64", line_length = 76, bytes = 8608)
`pragma protect data_block
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
9g==
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
