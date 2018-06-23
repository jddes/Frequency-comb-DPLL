// Copyright 1986-2015 Xilinx, Inc. All Rights Reserved.
// --------------------------------------------------------------------------------
// Tool Version: Vivado v.2015.4 (win64) Build 1412921 Wed Nov 18 09:43:45 MST 2015
// Date        : Sat Jun 23 16:43:28 2018
// Host        : jdbureau running 64-bit major release  (build 9200)
// Command     : write_verilog -force -mode funcsim
//               D:/Repo/Frequency-comb-DPLL/Firmware_Vivado_Project/redpitaya.srcs/sources_1/ip/input_multiplier/input_multiplier_sim_netlist.v
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
gNSB7T3mB3TjZW3c0sZmf5uq8+CAQCGlcTBv6f3dT4d2btEluW8UOFQOUZlBo2A45xSykjDO1iJ0
hgSmuZDce7BsV/qBrU4Hf7/0xW+tUD0MvV+OiZmKJ0GmrQDgqziKFUgFXVB+/IJx+pGbRDZCNMqs
8TNAV6dASTiFTXBPMBO8Hu9efnXVdZthBtA/G8m+e0JSEVUof6wQZhuCdxJAKg4Vn4lEE9wx086u
H5oOQqqDmHYpYtIHHC04T/yRF91kfsLqC05czN6eA5uI17iCsgxLCOnCW0eu3u+YJzfPVCC4EXrU
DuZHouRwlA8iUeO1hFkC3WBTpd7O/Pjv985nQg==


`pragma protect key_keyowner = "Synplicity", key_keyname= "SYNP05_001", key_method = "rsa"
`pragma protect encoding = (enctype = "BASE64", line_length = 76, bytes = 256)
`pragma protect key_block
Z6uLWX8+iTaMTSyXG4sa3xxwfKAoBybfbZrvUUVOdmnNBEfXreeNHfExKY9TjsTiaWW+iWRQfx9j
IX8TmRk2uhH+jVsvE5/jko3F3qhlK/+XNZBvJQik+Ov+nFbqqr4WLWMmIZJ9YX6fG5/j3p0auXDK
jlVAlwGKJsgtTUopvX7g/jaXQXlL+AnjUusRW0EFzBIgmSU6nhJI0644O2sXdwKeRJspJXhPSq4g
GFXjBlNEZU5NPVxQGqt90vMWe/Hj/L1mdLicCchtt6aAoPTSsfpaHmRoYP9hV3DAx+L8mi6seZtX
NQk7t92PNeH4FbNmZZP0xN1iuIUNjfTz38nX/w==


`pragma protect data_method = "AES128-CBC"
`pragma protect encoding = (enctype = "BASE64", line_length = 76, bytes = 7248)
`pragma protect data_block
fH212nSFAt+FbyqABDQDyqagAwl/ejxOr5sdOeSjLDnLylAjMkZgRwIEIPl+guGWe6/1hscXEV1c
lz5JqbO04XgeBYywwxh5hO5Vx/SsWcKUpxelVq13/vKNXuoXbQI7jzluu8n4pShro2ld+ewGn19c
B5qWcFIfmpD7tmaEeBxhZCirVKG/Q5Q65hj4tWJSV/kM99DtnKlyjTKksFea1JsfTsPSZt/Q/L9H
K7jk9B+DIE/Q2AGggIHyrux4vrv4AGSFXAlwY3Lme8ZZPUx+wCyJdDTI3U2IVXW6t3D4zHJfuA1V
SpzsioXGyo+tBoM5pUz8hmG7ZEH9cEsyUYistxdfvurlfj8q8QGDxS7YalIrOU96zhTJysJttdot
onOVJUkZOAeKKzdtjf30iTfv5xbMPDeG/LFcem9N0ZQvHvouGi5vJpOu2qaRDSgvEfp4xX4NjE1M
8ahTlnANKSzgCup5bx1Xefj1XnBJScmKhqeCM087Ww5Win5qLsbyWKgoaT7ILEOxfY6urGUjoJdq
3VAsqyh1FCtzUG8hVMN4vQA5K7NcJ2QvCuZZSWjQFgAbHhYq4rbFRLDqJ4peN0vbbWTJ6q6kNth2
UJtwKtTlKgPLO9EvsvhNvQA81ZolOGlvJRGyMKTk4GllseqXNk3zkXRBSJvy2YcyhQgjKCe3Knc8
poxD6ykg57OPLLwd9RPkZcpTUdoLL1rn082j8tkm0GUHnCrHI7F2wZjrG+cr0JLdmYL1bBUcApFw
wwMELIKSqAKUfDIHIzChPwWCq72CN9r+riCSIjccNdEzbCht9nxTT7DKfvY2E/foj9k6H2JKAyJA
lFvUipLwCI5SDqkp7fODpEDq+s4Uuj3XOKRNAD09QfvIQBYJIRIyirTtIsh989O6C8sBQmkeHV6W
zOy50qooVCTQIeIehCXF5g41YfwubM+5lajMK89UJHS8P9Lk+uROPEg9ZCmXOwkmm/bhEEMcOiMQ
8vT+rA1Ta3qJmXdVFVrTgrrs/b9IUGd29Ba58M3XlTy7R+iKm1UGf4SNTKYm0e77pd3QCBI117or
EPoc2+XhCd+SHB1A89/Jz3poaKyexiFpOs9R9fgtwfFgT4f0PHmsDPZVdxNBgWJANZZZn3i+CFn8
rVJY0Vcew41G0/vbGfF5vovgpE/cWLlcLXlcZXABful8oKKGXdBONm85xQ+bSmhkYXOk4L8zJ84S
VNcgb/SXh0M2NPLSQGbwI6f+5eAmLXU0uGNiAtobuClA2veEbKtnB7gYhwR7gzcKqm+MCW2CsRGb
0Et3yPz7NmDyV5zkQtSd6KOhP2j+89aPaCezcnqtEvX81sN+5LrCgocuH4V81tBZs5rW9XHUoim1
d+r9bIOhrjokQBcWYYGctqQ8vh25kegXkHQtj3hdg55Sukae6NhyQPVtxYfLdLUVWGVgwXMcZ5mG
f7+jzk19DW87ra3Clq7mwF8BPFU2N+X+Y+zpv0cOsH+KfP4lT8nHkLRyTXYzq9PsTaaOOPgJJwhF
PnjKZYnYOpH1wse9tgfg0OVyM7gsl148ZJ6sw3cgMGlxqO6UwYS56Npho0+bTgZupuYuAThGKP9R
rbt7Z2svO1R9YwedKEaX+EiFSKif5IUbDZerw0M7joDSNDzzcnVkFyojcbkyyNv2bM09JBsZDPlL
oKGGOKuPv8VGx5YTl1Jm+e34XzajNXQEKTX55hgsMVbT5W5OnJTXJIFkg5Wpx4xiF9qypEye8IAE
VqjlVkRosgjTOMFknbA4uxcOT25mudOJJg+L1XDvY60wBWt0/BU7rG8sg9rFx5yzaNaDXKZGV0IR
1v4FalDOo7mbkd1BGwmLZ7zgwRKyNa+KqPeVUYN4Mg+FO5tXf0AY9XMv+iZcHOYJTf5pa8jI3hQd
aD18+gRi8Xk0i0I1tDfzHb0iZEanHJFRhSV401872ncS6jBv+Zng0bcbFdf7hvsBQpe/y1ha6bF3
+gxXna9E72TGEvaPBPi+mA0wMjLiT6S+gqi/MgrYWBzNPJDHRqk04bhAooJeUNZDfToLWrucFlhB
rJE1tPGqhrF4naQYBpc20gwUkNb8sNEIXlEGQiPLikULaxY9tQeRl3KHq0ppE5VSG66Ep0IzoxNV
casVtY47jiMKM19vUNX2PcrzPIAm6mHpy0Hin2lBUSTrwGmcbo9xTPMSfgBlYYhgMTr03AnsfLzy
cIgHaHFFed/FMdQ2kIAreqT8JatmLvYvfzo+w6criv7y6Om0SnRc9Io8NPWrUtNN/FXctIZUo1cM
GEGRcoWAeJg6L5QB0mZhptJqF6h5qT7dYwjvKTuqjQcElE8MEWPXNVX90rFeQ+ggr2vPRKtiPypG
/UaZakT+f2/LOcJfUYbAfBaCsNwD+bMbPmfvENFSeFqhtHo3XhrPk7SRHKXL5AaRtWkHN0hrSnBe
H70K4Cs8pmhjHnx3dgtD/Nwiz3ii51BUXg8WJqamp/BL7C1UHLC9O64q69cFK3pYB++97v0Fvorz
1wTQ1WWpu2TSGAAAo07jBqnbQM277jB9ZKcbu5vB4Em7yduGX6To6Q10HqQbu65PJpWZq3alwJTM
5jiBttWGHy+rv8rIGE6EQ9qfQ4y13XRTAV++h6HfKtue14o1U9PN5CLWteNpyBbHLFZoJqNAaWp3
J3Ln2fKmAlXlzsh9SAhtvNaWLe+akW58dB0WqSkKKHVbHujM13UeWmFcF93GaOTckka/ma7Viyhy
W0REupDoBJOEeNO08uZobLLCaSWoCHPoa1MFs0ucMhxSR+zh0UQ0wT1Q7urx5Up5Z5q5RO0funOn
ZuwU/y8S2x3g2XSov9ycDfP/cjCQF+4lZkHm5wLfImRxeqFxJt9r9yyOkG8WXBtyBNwzvdsIDd2u
kXcYqbwiXa9KrquTp6NL7J0hff51VxTJqecHEThLUDd/JyDxgOGwxpSDn8ZJT0XW2m0YJmPcYobi
K38J7L//uN8817gsNHF1zuZWncFdNq44tmKKnv9O7a5FK8DGiXgZsQExOTujVoYHvFRDpbHaHJdI
lWeRNd/0rGU/eYuy+9XgY2Ibh3Eo1aQjc518yHyGD+XKFbO5d4qbM2hyMTptlQ0eE4k8OELTz415
HK4EmXnTx4V+mA0Ek9K83rtE1sJD8X/P1DRVpM/gmpoyGeMfGbVCoWxZe91EFeKkeABUNxuBic9v
mfhDleOQWAXMUKxJycPR0g2fcwpQXY6OrEBAvcM4j0b9vSZFtJh8kYu4YuiL2umcM6ri2jwGSpYj
uSWXdliHM8oFUPN3ZlXKcTpOVH4oS58YkyvVO6Rt9DdLhR1RXIyKrQSVDQ5sVAH+6BIV5XgHnuq/
jEst3YTE+YMVAbXaLzTE7XcfR51UddqcIUvWdlFdFUEbuNhYGMMJrlo1EJHfGC9mfsdCX2ZT5Puo
Y8NLzLTn9IVUU15HWs0KBIzNf4HUxm8GYQgi8fsz0A4PqN7WGPTg+2vFK2s54IBNnMlQbflurzSF
ffrL+Q5ztGz/1pQvDnoYhUfhK1ywcpwhn1ppcEmfuKq+IVHnEoydmIxtC6YMRp9LdMG+lclotrJH
+rOb82cECSYpe3K5Vc8zNlfIss+fS4uCE3DYkLhdiziRmCb4NEwYmnYR7ociRmQsVC5zxf3lo8PM
U/71pt4jLxlnu2f4ceNeOvbm0jVPTDzK0mFOPkhdajqxMW79Oj1KgMJcYRO9mmsVbM7hFqUNJYP7
VtEuJe376oeAizSyNLQY9GKy7ilQDexetCu9eGvSWzsdDYmd4ubHJ/x/mca/sGNQ+WE8fr6qWLR/
9OCYnGqKkMlh7upcF9A42PxsjcFVP6CJROG1wBJETDBVup0HRqapaAtufgktfn+Gc7xIIavj5Vic
lVzYzcAT82Pn21gAzULpU/3XoIDpNvReu4DopbaEtK8a+3fcEQohOExb0D1R6mX/IHcibeyBJPoQ
LC6zQX9xYuREOOh+bWAtbIrE0cGPHUv129TOhX1xSFUN6zZ6ogHHsYYXf/Lm24mVbhqlKJZDWgoO
w3kHT7MsY9+fe564/hs5OQvi3Jjzm0Pf2MaiuS5x067m/9YvP5oAw+d4A5ssIIy8Dx9RmWIyT6sZ
lh21xPinxxW3WOxbs/BhQ9u5cVWL1x4plh9X5QHeGaM1lVUG/Pid4odIUcHSR4E4HOV0C053q4Fd
ofVH50eVqXvC9M3d3J4PzwgsAVnCQJxfWWBzFMNVl3dBex4gDpV8Zg5urMLkz99zkbKJjU2RXjHG
sJeapvXE/R6mWoiSmuVI4r8Io4SxwSfjpQsQMyMMKuXFeWFkvsU83vlYfc8MpjmboxhIYNMSDX5n
kVqcZOfvRCOutF9LK8xPH5MYH/LirHhPeK+rQ1RHoDb1p9QAuskTe5+N57VJSsVocUJNAAJ5ps0x
jiHq6pYnzSB+JjcgJjsv1+FKOowEYi6YUd2ogYumtVEqZr6V2ZDa3NdfewSJSyNZUMCrtHMteNLF
PLdzVQDQpfCywkQb9OYbL4sADF2Yqzt8D/ccUWWzqpktviGRPT4DJVnNL0AeVIiumqMJEGXcxxAb
lG/0U9thvEiqRFWwTTxCZNDi9bO/fuzHCYFlSdcfcAkZNPvWXeXlHHO8vX9t9eF+jgQIdCPFAFmt
TjjHDe8CMdUoCzAa1BYv1gTyJVIHJKylSsdNtUPGdMvdkA/mChkH08D6Fjx0H7YuVcInw3puLZby
danF31j/nA/FfUeFsSZBRS4xEQ0AjMkG1W8b26bxLD4MTDQdtag/7aBjLUO5Ndsanq77+EMqM/TM
2XqYDrBHqD8nyL1xCj6BZJRXUZ55CuIQZxa5gXDtJ3QTCd8HOQ3vPxz9s5toBZL0MBBi3i7/UnYj
E60SoB0qat/WeA6felIlIecUHlSdX4bIca9BiKqUFrp0GbxRBI/p2MrAtoo/EHs/yiavRcZyB5aa
CDDDctKvwRYaqadTxmgvfcUSzRzzNIFLlXXBWzMKDFFXzjOMrZxTcCZzRDSDTZLAwxmnyhwF/SHC
/t+U5qlCXYZ0iDjaV5QJEf5ZexdJQxF8S0u/FTUiUsNW/iY+mR4qyWJF9SoBh7CtnFUpaN2UWMgi
i0pKvsI3HntJYaAdcbeLebCzVvROBLloimd5oUWSwvK0Jdi3JHhs3kUO7HvM/Zf2cQFF6jvfpCjl
phYn2blFLa89TNXMN6X1zMPnHZKFM2WAx1twtKyJEopjV7WhxtrN0KTQrAiANA+3rB4pIBftt1xw
U+bYzeXI2AhtfzLLP+Gs91H29zh99LHDgi3uzGWvLeONX913ku9cv4opAs+RXqCjvZs/vJDsQeCW
9w98VFvkDnBhOWVEmk3bPkG320Ien6iQrB/5FCHsblt1tPg1KaEII1cglWqCywcNF5e/PCTfQ0CX
P+QnQbOZwmC89a6TA9b9ikPzh11RWviFqIYhVI4O5W4bjje6ASbYCvLUVWjXTC+65sVnpJj2O+h5
4kRPX//Mj+zZWHtMgbu0UpvzKzSaAeCBgeLybVzb3E5oICec3VEIbN9ebv6zUMt++rOy4tqlZq8v
iPLpAk/AuUglXI69uTecDrrCDMgkCN05lLlYhwWfotMLGKJFhWg1gkySI+ABdJTJI+is/2K9roIy
rwsOOdS5vby0o5kIpr5BxMXendahrUt+DaYAeT5X0G3dhKsIODyWxlla/GpKNne/7EL4RFhYmnSw
IuGT8DELEeGVe224C+znK/hCc5nauRwEa5EFfw0BtvV4GIw79TSE572cLCyyU5MD01DkOrg50fC4
/E2RTI+61NkgjT3tjHFZH91n8Z12d9yor8myllsikqLI6WEuV2LdVdGZrJvJmVZ7Qhu5NMzDSQUj
4Ax/hCxCLRN7Kf4ns7g5OpBugcd3cnuFhAA+UHnkcsFVQfP2H7jmX7MlTT59sVVTDmPTTb6ofS7O
LwoBC3V//l1Hl+nqr9CQi3spgbpH7pJn5+dNJhY0t0z1QXitbd3U8eV1wV9UJBlYVZ4qStJi6SYy
YyOpQdhsdHRm16FDcSf91bQEuLXUbdWXaLW5+oMQmudniiCpN7gJRyo/TZYz67jhmtjGr0390pAM
ij4305BurZ5QJuchv+xNYsTBJKwbg7AVlz+1TAuK9giz8m2h1OJ1ufz6HZVc77q2kpQzjD4pfMQT
G3M7F25JU1llAXYjqAaLMKy8yElWiNX/KJQWRCTYkHo0xUqEPzpeeOg4KHmrWcRXVJ5n0YUZqnMC
M+IRTaopqvZe1Idyi2imdIn/v+EWEUK/FgWQNz4SlRTXbUwIh6M2lSCvKMzLpJL8fuVMl5diOP82
MWYGmu7QNzgdZKXoXoUmuvPR+gHWfl3RlfgC0hSyUFx48XTW/KlTOMV/PBdqKcPTGYYN0m49CyMw
iFBKmxzJoknruCLPCteVIsu9sPviZ2waKTF9Q5MTlGGxQzcFOylkVIZqcYo2qJFd8UqkuBg88hDs
TxbJuDrprAQmbo2nxSigynjIUmBJg7M34UckDRNxsnp03KnkBAfuHDeQsQbTBgxo5r/rrRpQvqfm
CtEkzxK/VXj2QeooUWV+j7I8Md6G1vGFVmWRYRVSYEPEXmBdxBf26jZ6DizB3327KE2iMoCjJmSP
r7e7rw7q4s3Jp2yo2oGJa6/5mZuJkMYwXlp86rrCD33HzwTri7u/5Y0Pu3+dTLMijLzfHkC8Iq7o
EgIRwD9HdBmODPlv0D83ftt+5c9Xab4fhzoAilHNURKhku+LhbMpGchDPMkVlE84/hYI2gvJdKcr
EMpytB32RYk1CQ9VHQ+F0KaDilrqvCIY3bq6uvk4L4l1Ciz2DDhDjl7f/0BLqQPT5/CxkcZw/eAJ
flqBw0N9r4FITHhYPwI9cVaM0+72petUgOVEb89fn+ojoN+BPSGNG8EdQCBy0G2uoMDuCUan53OZ
dMBo+fTuNqS2JVwiDj9GMnWDAR7zN9Cx+mP0Gzgi0Bqb+FbNV9xuMWGMB58RyUGXvmSRfIVDwvgZ
fMgm2w8XhieHyuyCJbtdBUuwUi+mWSyz14WxgfAxOmqcTGJfzUogyJOsLPqdz3zRTD5ziibkEtwc
i5PL9L/XGf+MAMmpIGOKHD5+tw+gIb+kSJOQZ5RIdg1mbGTcRSeuG4y66pGFaILiS5R/S1+iWHyg
BFHfZslihSdWvHsNnQxcjE5/68ulNE1JQC0Gh+dKSix2gLOtbPZ0GirXLKDFWu1lWvPSxB5zppAU
9na4GDoGTPlpxtFmq50Eq1ggvBIGhXYfvVKj1PoV8Z9vKPz0QlhU2cXtoDk6wsLHxstgLjBTkNT8
5KE2kmUtDhXb6/RhxtT2TJp5HrdnWwdYlomC58wIYjY8t+AZQvLbC/4qrzQME8BnfXFFrJj4fa41
Mm8C6J2iaI1NaDvC5h34pV5wkHPtXie0s4vYg/GjeBMChBW21aHxvKrRxvWFyTh0dg9gQgxAwtn0
Bc6qXY9mOfrKVVV6wZW/ZlfQzCnVq+PLudFaFOMJXpnAyLgYBI1A4/r7Em9BprzjCGVUUSpePA70
WyxBsXy4ZFrdoor8b+zNOrBXuZEVbIPMstQivZGwIU9CV/OzIeml2DoTelbRjaMxceDpljprFdRt
CnP0mcmE4bZoqApl4Wkflv/nL878QS/9tBD9lwGm7k8MFLkHcx7qrJuFPqC5KCsyWHzUoFdZLd4m
nyTAiAnvyVUlffm/CPqcuc33349oKxjVDR7AtewiOsZs3jK2d/OopoAio8/TgG3hFlKNnaZFywia
KLWuGHErAy0/OxOT4ojMNRpZszyXcOZ3umi3lg5cvEC1AM0XeE2yrD9yv6wCkUhA+775X9l8zIs8
hsLbyN2mCq14L0p7aLxqI8chR7fJ+tCPSuto92Hk+4wqGXNleq4nII9UNEOJTTQp4jGJY3Tbf2Le
dt0HrYzczHpHxgRKehQxtCyl0spPfsDjJmhMyPod9TYwTtHo74XbJ2muFslEeEYEMfFVLz2LYQpb
TDBAdH8Zz5oS9XInRFGxjcqVcXf69JvvEBFjWTeLrWKLAHqf7Jl64e/XMdgCdS/+98esGdGTNaBv
bsyELjbe6Nfbqwplw4AauJctDQHTKOl+wUEJzT6/PauwTe9MWjB35kzFK6xWdJF9VA+/2Ro0OQ28
bT7Nw2awF29AM9b6GL6TSt/PayDFVaDrlcVbjOUC9lJtteaK8XszZ+9emfixP+lYUfokSuYQNWEn
8OWxJdVYeL+UyTylasV4/UiFfkNrei+gdY3NPPk3yfo2cya0HZyD7tut52qnj6iimw4LUA9rH6Sy
7KhWBJpTEChUJ9nHtHTCmCbBKxH5anbhq+7xjlTIOom1BF7KEzDKMtEj9sGUaZxIN8apiZ8Pj4L6
1hgyrosALuOgrRAmuMrtcCeAp3D9fbZyJXPcRzC2xZ785PMObCUcPyPXUkgZVrR7BeABAfgDdDHd
04PMBwJXDzxr5B/sFCsXd9HgAEJmni3LiyTQLHKceKPV4X9mkZxJ67bAZBxQiCAkaAtIa+Nao3Ml
riX/LiXKP1YIfg4ZOVdK4/xOyJQBmZesNIaT2b7XYxJPl+6aYok20CeTjRlTQVEzZVLRHkbcri8x
PtYc3GBO2c/8ctKi1b1HYc6krbc7GhC5/znVCEVDImJFOkxfzQWTJTmSArFjUOdQm+dczXK0FZTG
FFPnOIQtT1LafGqS3OM11g0yMcscS8BECgnMsuZthcCvJZBwpQF5ho/Va1KG4xZHXLZZMoJNn1Bd
A+Kx0XCZ10av4TX5/Wk6+8G2zqvjzFPkcekIXmY+0GVbYvRaWJw2SYzEAXGxmHfvqD0+NWMyyCIg
dHSRlHmzZovJqAhGzXAXlnw/atkXv1b7KZNL6ZqImC0K7N3JdicImdV09hlN9cNukBWVf/meoJJP
T+AllpNAWqQh1gEooni+xkJr3c0akS03pYdTXYOB/tdsrELf+sv5GmvaSo5HQ2jGALLPu+U953Zl
B5hpqzUvNemXatWYO7i1QychwA2Zd2uGMiOUb0BT2lYdUcx2qWZvfFfgn7+rmNki5IOm3oLzRRJX
3wYohnP3Jhic9LXRyo2I4eCGrFPzrEcpo4qaoYYnr0TcvCQqSHp9B00GJdQKVKj2MBGbFHRN/+Yg
qJNISf4JxjF6g5pM/IkyQ9bYZf20uhzm9BVA7gmSucIkb+7VU9ZTqPdVsFokyyQkJxhyRHARlaI3
a/ZeHC9L+Bx6YagP1HTD/1GkSoLyk5S6WHz6e6BGWT8iDYScZ02hxXY3WWGcnj4lR+NWXVMErj2x
Kmrl16kAIzTcNqUJcU1DhvPcKjeXZeSHhqSi9b2iUK0lOdAjmS4IcelvNTPM3ZSwZec49JZeEDnr
A32pEOP+Y+XrUakE37qyZ/+FqJmR2WCnLeS4BLjewp/U02Q/k5lKxTYrJ738T2rnjn27umIEs4rw
cf2L5kHF7uYPAAtf0XmDq5E0IecoeuUSqhJlWbFJfyFgSsCRqejjVeVjKM8IcthCsh7444vfMvHH
OfHeEuhUGutMHC8GB0vx963CdeEvXa3AjMZUoHH3FXP/bFjm2WPepKF/WmuE6UxhOLNXLWdlLhII
YqJ8Zerc+j+naC3Vns2HhUUt4FB+a2dhzg80halTIxP65g/CNbGldEsxw4X6tYNLxAFLb0F3LjBf
Lw0Lu2jTYDgw
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
