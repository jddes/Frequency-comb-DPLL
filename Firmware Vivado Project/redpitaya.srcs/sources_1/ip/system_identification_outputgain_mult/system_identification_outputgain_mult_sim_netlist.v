// Copyright 1986-2015 Xilinx, Inc. All Rights Reserved.
// --------------------------------------------------------------------------------
// Tool Version: Vivado v.2015.4 (win64) Build 1412921 Wed Nov 18 09:43:45 MST 2015
// Date        : Wed Jun 14 18:58:31 2017
// Host        : DESKTOP-OULANE9 running 64-bit major release  (build 9200)
// Command     : write_verilog -force -mode funcsim {D:/Users/Alex/Documents/GitHub/Frequency-comb-DPLL/Firmware Vivado
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
V8XKOs3ywWMIzV865rYbHdkKpnRxahEYJW+JSLm5FScRQfRgehuR3UF7l1wajPhjodSrhScNMwcU
HvfNdu77szI672oWwFfk4Dwvs+YFBT0MgkV5o3goeo+TKrAI/QupL3DR6AUpWAI6nyWJlNQU54ue
H4DH59oR538WRDbSn8HHCVBvL3UB7HGrfsRRaEUdF4JbWaS7gWcKdpN5qI3by2rno+rx5Z4vV3y3
/wkPh7bJOEPRfp4EeYwk83BLlGcV+VVfQq9l0PR/syw6oisI7Tor9CV15HJBK44/jUujZjcvwe9v
jH2RbamNgot7H/XHQm6V6A4MtLHfDAWiuPwURg==


`pragma protect key_keyowner = "Synplicity", key_keyname= "SYNP05_001", key_method = "rsa"
`pragma protect encoding = (enctype = "BASE64", line_length = 76, bytes = 256)
`pragma protect key_block
xWI53JrbLmwU5/sdJwyEMMYgDwyISXcA+qACDZEjBJJJTGBDLyj9FcxhYrzn2B9qs2EA0hvX+SQV
5B0Rq6ztHrGn6iVFBTbEuNYN23JT2Dzc5hoMmmnATq1POf8GJhEivY83HSGYVUtMtqrJP+tbAaGm
CsPRWVoD1kBzNfkpGPWhLLt1zzAJhXt4POYiJ+B9OhGmdatx3wpJa6c0JzPLDXxHjw8CLM09UoDu
MPh5vFLmMch8ss/2qqz4QV7Q+baIBUo/0W66djbAopH4mbno9mc9S0jIHyiGtmNdRGAW+MLF2ykk
nmeMR5VIvBlYbm0GulRKQIAW4bPcZTiqxnxw8w==


`pragma protect data_method = "AES128-CBC"
`pragma protect encoding = (enctype = "BASE64", line_length = 76, bytes = 8608)
`pragma protect data_block
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
aw==
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
