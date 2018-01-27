// Copyright 1986-2015 Xilinx, Inc. All Rights Reserved.
// --------------------------------------------------------------------------------
// Tool Version: Vivado v.2015.4 (win64) Build 1412921 Wed Nov 18 09:43:45 MST 2015
// Date        : Thu Jan 25 21:19:24 2018
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
I9SugYk5kNScscv65w1DTF1niBWV9Wtm8tZ+auANbrtM7KFNdEKkjIVVWMAtqSYGQ//P7bwIc3EW
uf5n1td6jVlmS7VP0S/5dmj+2o2b+XjR/nsepnzi/mlv7h0/u/O2u+yCahtV8tYV4qfcdSTaRFkD
6zeF/6T4dlJlZKJjuczbFTT+Wd352bDYyyQhQ28Xa3tCL9YD0hAS/jNL/ApnItze6DlgvXBfnRVd
SL9qlAgzQFM7IH4QfqMrNsnOFFK4XepMY7CSLqAfow9K36ztQ0cBFts/mtMtDLoyd3xsl3ZdEa8Z
ytFAWN0SLKZE0w6dxPA4N2+A1DjpVrDsBHLarg==


`pragma protect key_keyowner = "Synplicity", key_keyname= "SYNP05_001", key_method = "rsa"
`pragma protect encoding = (enctype = "BASE64", line_length = 76, bytes = 256)
`pragma protect key_block
MJ5sSx1/0P5VJYRXYuZpvCTW/+wtZFTWWC3IcE8I4RQHRJuNFzF3ZSdBvMQ5ComHPjOufyx6nRad
GAcGqQqwpd9R7qBnAQqIvelk3OwsnfS7rKzaIwy6UHfUxtJHQc9BRc0LmEEDA917Mwk/ugMGWLSI
xCR72/N7oC3XQrwTogZsa3AzpFwWX6P16ya2vOn7jPARiZwbbUPfJ6bFQk+kpqZDp/ML6bYUKWlw
B/FpQo+NIDEl8A2bUmoFRGuPLsoPhiOCcuCwlgD1DBKyP4AbRDHzvA+JYSV4rn3RSdW7enE0jXtP
eWbXUuVLoxszsIEJvDj8NCmBKqA9h3C24KHEDQ==


`pragma protect data_method = "AES128-CBC"
`pragma protect encoding = (enctype = "BASE64", line_length = 76, bytes = 8608)
`pragma protect data_block
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
EA==
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
