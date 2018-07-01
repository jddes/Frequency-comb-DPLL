// Copyright 1986-2015 Xilinx, Inc. All Rights Reserved.
// --------------------------------------------------------------------------------
// Tool Version: Vivado v.2015.4 (win64) Build 1412921 Wed Nov 18 09:43:45 MST 2015
// Date        : Sat Jun 30 00:38:39 2018
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
VlDFwHhdGorDeg6P7iFnBptf8oum65kAUA8tReeliGSY7niCcNlDQfy359XzFEzQRSiBIeJviAah
LgveWCxUjWWNWHKWdoTOmRtuLEDtJ7iXcpEaZPu97RTNCxiRkbBFkJdzWgY0wN3dwNVVhD8v0Y06
fbj1Xwu2qvAc9siLgvENST+pZm+VyxKV4a/B6rff/1CcV+0mLi/NgycVOPhwrCU720wPVmzGQIbz
95uuThGnyLFEuE/qMSeUP3UX6Zjv5L8BpsiiuWJSq13sq/f5eajdg9q/tK9puowW1pIBjj2DUZS7
Zg1jYwhmvvcOSCDuxTj6iymOLaRVPo6Kb+sYAQ==


`pragma protect key_keyowner = "Synplicity", key_keyname= "SYNP05_001", key_method = "rsa"
`pragma protect encoding = (enctype = "BASE64", line_length = 76, bytes = 256)
`pragma protect key_block
a9IS3eGPptLsYT2Uqa0sryIC1SMaPl/8yS0JQ7GYYF0NZoRahbugbddtNyHIoK9Hvt1iJID73fne
tI4rBCqRKLVeVAfH6PiQNRcCHZ9QngzW6oYj5XfPNvHm9lOja4tZ3ZH4f75P5HR/lb8rVUYo+UoQ
YYes4M6t49/DLvbliuqg+IfNzFcYG9A1Ih8LqP91qk+06SQovOAL/WgME3ErhrWu5ftrnljztMlu
cA6MgWF6pB9Tuyb7LFBBSb+VazFukZfuVMojMH9lTEO4Od08RyuMz0KK+qv6Xq6aL6lIkdXIZud5
n3GcRzb7Fsrjun0oi+sp+Rxq86oEHP+CML+miQ==


`pragma protect data_method = "AES128-CBC"
`pragma protect encoding = (enctype = "BASE64", line_length = 76, bytes = 8608)
`pragma protect data_block
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
aA==
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
