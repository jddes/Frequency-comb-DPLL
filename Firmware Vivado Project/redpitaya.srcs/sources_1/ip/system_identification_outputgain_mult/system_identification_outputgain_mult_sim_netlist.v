// Copyright 1986-2015 Xilinx, Inc. All Rights Reserved.
// --------------------------------------------------------------------------------
// Tool Version: Vivado v.2015.4 (win64) Build 1412921 Wed Nov 18 09:43:45 MST 2015
// Date        : Sat Aug 12 15:55:17 2017
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
f/fr5VDuC1kIymtdd7+v8uqRpXW5ojhK0dW71dKL2W3kAbGO51eqf+eUdcHJvBYro63xx/NBqLhN
h9ebas8CcCk14WQN2Aq0heZV9TctiEq0bG/k29pTInFYkVYWSIPDQTCd2Xb6KqIGuz71iKh93omv
/E7EH/V/f9V92o1voUUyULH0nGWaNPMldK+PwQpK4YpSOuhcgbEJ+vct9fsbF7Sv+rQqJ4HCbWbe
yDTnom9uwSc7CpXtMis37JTga9Mzpmf39X14vlvPSNvA65qjahNhjhvIf6ZwDoMu6i6lZ/HvB2JT
rC0Tm8FcIt08TPOE/H5Rh5KCEef/6iZ43o85og==


`pragma protect key_keyowner = "Synplicity", key_keyname= "SYNP05_001", key_method = "rsa"
`pragma protect encoding = (enctype = "BASE64", line_length = 76, bytes = 256)
`pragma protect key_block
Jjk86CHysmETIC8o6HXu5irCSaMqzL3C4pFYSyxH24n+avNXtXHu8YLVRdh3uVamRzeJOhDAHshe
0wKAp07vOJUsg3qzB/MUHXNXmwubfxoxQlco9fuKS7ecvhpOg7kPH2AR5kQtbyDPEJ72w5Av4o6o
3BDG4pay7GL34wiADSFJceSRZttK19EWOW9BRVOm9qihwriwUfyJTjSkQzq3Lf+m3qXnYCli/CKq
Su7jkA/xVKClFB1L8VdBRkBZlrfF01BVp6sHktGDKS/+8j2DhF4YAvdb/DGvyoo+N8bvwJniV5nH
cdP8wnL9cYFvtLMBLtxyWmh7IwTWPdu0scUQBA==


`pragma protect data_method = "AES128-CBC"
`pragma protect encoding = (enctype = "BASE64", line_length = 76, bytes = 8608)
`pragma protect data_block
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
8A==
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
