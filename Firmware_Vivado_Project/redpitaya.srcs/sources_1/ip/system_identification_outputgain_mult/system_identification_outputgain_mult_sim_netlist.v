// Copyright 1986-2015 Xilinx, Inc. All Rights Reserved.
// --------------------------------------------------------------------------------
// Tool Version: Vivado v.2015.4 (win64) Build 1412921 Wed Nov 18 09:43:45 MST 2015
// Date        : Tue Jan 30 04:14:22 2018
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
hgpdIxPrpE7qMUcNvWRWmyOKZyvZabbYoerQOnHy784lB3Gkc3ZuwXpJnAkAwkA2GEt+cD/DAak9
5sjLrP473JD5fRAJVXS/gkNG6IFAprFo2I2BtJbMmIdw5RgKInCBoUhacWFxil40X03C+0Elmk3C
3VxBsIH3txrrE3l3JiK4YugukHphjdcyUv2eN8SaMZPbgppx40RlNogfYiop7dzop9HlM2l855nx
leImm1TyF7eNhJf9wr8mngM+fJ+Mnfb1QaY/c8lnl/7uK7BGt8UgvU4dJHmcvOQmB8JC2LEuy/aS
eU4yINcRb4JP9oh7Fd6Gg+zvzI8HDhCX8YPTpQ==


`pragma protect key_keyowner = "Synplicity", key_keyname= "SYNP05_001", key_method = "rsa"
`pragma protect encoding = (enctype = "BASE64", line_length = 76, bytes = 256)
`pragma protect key_block
ZH5Ac7Kw+Y70IcEtHSx4IBYiethz1dB6P1mu9AwaXmQG1XCxIjXF1FPkaH9Em5DKY8yglsCnVWXP
3a4udaNVvsO6H9D3jvbTvAFLw8Yt7zOskZc8uV3k3KXKqVrCpBEYD1L2QEhVX98ip4hN9MvnlvoD
Zuv7F1+ehmgvu7sgJFcocX0EWzfjwNREgL1XSxu0DmjvkYmEpRg5Ug58MFZB50h/4snbM0DbQ+rA
InSIY/eGuEa8Tp6DnYfbqG1YyyPyTqsDF732UvnaVYwmmCZ+dDTYmbhdFlxHzy5PLdI7YJYg4kn8
ewUon0nBdf9CrLjpVhli8GpQvP5ezBCYy+lieQ==


`pragma protect data_method = "AES128-CBC"
`pragma protect encoding = (enctype = "BASE64", line_length = 76, bytes = 8608)
`pragma protect data_block
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
OA==
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
