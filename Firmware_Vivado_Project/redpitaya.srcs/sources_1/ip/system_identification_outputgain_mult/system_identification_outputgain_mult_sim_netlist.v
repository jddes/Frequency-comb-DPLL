// Copyright 1986-2015 Xilinx, Inc. All Rights Reserved.
// --------------------------------------------------------------------------------
// Tool Version: Vivado v.2015.4 (win64) Build 1412921 Wed Nov 18 09:43:45 MST 2015
// Date        : Mon Jan 29 22:23:44 2018
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
ihJVoDM4ScLXTWo0piZRelib9avffCx3Oc17LjWfwdZZgWnTbcTKiUH14WI7r2NWcLHkpebtNk/0
IyCKDQa2MZhccMq3CxyxtYWRR/kGyW5mf32jsdFYGKgP+qKYr2KTPqRUlYwBBBGjAo3phpgQ9JSi
yg/KOfrvgE6sUpDPwsqzmGoTIE41w946RV8guzleHuk+jX8AAUsl4xusYAEMAT1FK2UnbVDCeyme
5BnSvS1IKt2lI6l+j+eRpBULeuLbEh39X+P8yDJHe/84xitRevQLExmY90YIu8w5fPi/U8Y2bbjr
Hx+dxG+QyoexD99sKtQXiEpfL9fIVT6DMRK8bg==


`pragma protect key_keyowner = "Synplicity", key_keyname= "SYNP05_001", key_method = "rsa"
`pragma protect encoding = (enctype = "BASE64", line_length = 76, bytes = 256)
`pragma protect key_block
amMX3xqax+kMAZH9KPOk4xIvKFuw9nOAGmCii2MBwQ48n8iyOGd87rjc1Jy3K55plERq9I8LG+pp
yYVOyFWreuE8R2iFhbKPm95FeuzYKK7ys62N5+HdnAmhbhHxIkE7scS7SA0gEr9nKIYBOTByrgCz
msb9gKDlXQ8p5xldXPt2cBv8PdY1cIDN8c4tqHqw15m4kU4t5Q0VYvi5ab/UOJs35EWGtF7KVvZi
8DGSUj2vI99UOoo2LgH2M/cOpXXmkJLgySm+ggkZ1CFRfvJSBong0IlH65+Wgb4gezYCKefrGOpZ
7ej8GJ3E49jRMLrGtuZSRlDgfgFglXeBN3t13Q==


`pragma protect data_method = "AES128-CBC"
`pragma protect encoding = (enctype = "BASE64", line_length = 76, bytes = 8608)
`pragma protect data_block
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
Pg==
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
