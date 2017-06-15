// Copyright 1986-2015 Xilinx, Inc. All Rights Reserved.
// --------------------------------------------------------------------------------
// Tool Version: Vivado v.2015.4 (win64) Build 1412921 Wed Nov 18 09:43:45 MST 2015
// Date        : Wed Jun 14 18:57:34 2017
// Host        : DESKTOP-OULANE9 running 64-bit major release  (build 9200)
// Command     : write_verilog -force -mode funcsim {D:/Users/Alex/Documents/GitHub/Frequency-comb-DPLL/Firmware Vivado
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
C+bZWv3xHaEqXIgUiBkofPRPdX444sklyE+06HO7ObVnhoA+QhEGm5ZDK29CyS3e2As3rq7Mnn6s
Cwqmu1iysMAO/aa8gUIM4IyUWjfbUCea7jmU/De1gDEwaH/2lmrzTfTKW4zLR50fkbxg9bQOMWrj
yOcNUwA9epUipicUvm2uLg9JIIGt8APUhrWzc5cCD6W5x+GtVACEB4j8sZcJqIBE91hv9rJ1e5AW
djcS8PTg8K/k55cu5BQHWXrK+tGUQWb67Z89mWJt3DDMSBQXKPL9s9HTIMb59nogHY++WJMrqMIE
sDMSzeM1nH3GSaIwkOc1NJbHi/NAxRZ4hGJO1g==


`pragma protect key_keyowner = "Synplicity", key_keyname= "SYNP05_001", key_method = "rsa"
`pragma protect encoding = (enctype = "BASE64", line_length = 76, bytes = 256)
`pragma protect key_block
caoz+SJJ4axRcJD6GdehlHWF8ahaT2MNFqCV0PAjeoMaibkomFsHhnuVMtjY1kAAkxr1HFPntzEa
qI2OGRW7hOEvxKHRmYKXaxYIszjv9+LSTI2zeE+Yz4t/3ZJkGQ5sCrf/KM56hTSycdL4sgGknmOl
hs5TiAXws85n7uZK5sWuwSKuM4FlOTFVkms0op9x/JtzOCaLWwmewJfcN3SDgSIXcaoskLnL9O90
AFzKDOiQPQGpOKvwarMheDm9+kkDcp4sVwU2bQk9qu5+DXfWxkqP3VVaI5Lm9atQyDQRIZTVzOAz
mZoiy1tHxRBF3jt0Av7oC7jvd9YPaKW06LeL/Q==


`pragma protect data_method = "AES128-CBC"
`pragma protect encoding = (enctype = "BASE64", line_length = 76, bytes = 7248)
`pragma protect data_block
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
6sJeqcPNneXW
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
