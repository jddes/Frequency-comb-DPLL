// Copyright 1986-2015 Xilinx, Inc. All Rights Reserved.
// --------------------------------------------------------------------------------
// Tool Version: Vivado v.2015.4 (win64) Build 1412921 Wed Nov 18 09:43:45 MST 2015
// Date        : Tue Jul 04 16:07:01 2017
// Host        : DESKTOP-OULANE9 running 64-bit major release  (build 9200)
// Command     : write_verilog -force -mode funcsim
//               {D:/Users/Alex/Documents/GitHub/Frequency-comb-DPLL_v2/Frequency-comb-DPLL-DPLL-python3/Firmware Vivado
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
aQ0wly/E9nIfcRDuCwNhczC8h7LzrRcNzcteeAqrG23Kvn+e/9zswdJy0Ts9Xyd/wvFb5Yg4wF4Z
NhaNKV5srmghjc0qBURPKwEJMsBiXXmb83NjB1k///UVGXDEecO9PWCGLKYjP7SVhiEWnKGMRlv9
aXRA8XC9p/4MTRn56U97L8Td4RwbUuNRMwHSyB7T8Q5EErgz0RjJUhQ5QV3yMOsqVPI4p70m7ILL
mQ5SyjxhkCHMShntH6P3YP6+9SqXVpcgvXKcUgV7FrIF60LjEQ0gKmjDNz//mYT6bl6is327V456
U8tyuNf0J6Xdn13kYUwRpgdjzWYsIsQ9QATxDA==


`pragma protect key_keyowner = "Synplicity", key_keyname= "SYNP05_001", key_method = "rsa"
`pragma protect encoding = (enctype = "BASE64", line_length = 76, bytes = 256)
`pragma protect key_block
eMT09ohkO8Y1GYpJVHPBxZaI7yIXZJGWo1P3YyCAx+8PaYOPaS0sbIsYt/HyTwwBTQYJYQ2xPqHn
LZ0XHzhqHClX86omKXJb9wTPtbCxjnMxxTWbIilwcJPtQyhfUGbqQ4ICq4kvEXu6UJsTg1ha1AbU
WXOFBvdT8qy9WtuxH6rBQD9dbMuEvwT6dlMGcSlBDP/2PqqRoyjDiQd2p+srPFxHjgmm2SZrrPry
A8ZQUlbMy0acQfpGcto0Wv+O8NotbahQkvZ0NlUdEOdq7YGwffeyn4hVeChD3+4ncTB2NsX8nKed
Y1Px9zgYAdBBCSwL/kD2jAheaoL82YwHO795Mg==


`pragma protect data_method = "AES128-CBC"
`pragma protect encoding = (enctype = "BASE64", line_length = 76, bytes = 8608)
`pragma protect data_block
VgkcGjxolQpwz0W19cEwKv+o7reSKJYekbWbsTVzm86BfyR2+AdJxqTeNpW2ZunbXOGtiNkK6ISJ
z0Ul1Z9RxnH5sP9bnEfOKn8CQAml2gZ8rdfULaV8dWJOezUug7DFRQ9BLpS+t/5RXDdzv5N2CZl4
s2BL+3wtOEWU5EDG7y5y1ZvsrdaY+3zrxOwPHqwh6SU8rkm9ZHPhB94gG76V3VGPYX05hbNfa9NX
6MJlMVH6P0Kpg9OZiZWOdqn4Hz6m9eQTnzWxnIupAt9+cPx3nhhSfj3aPchJq+LbeZUzaT4KPc8S
ENjuzce9bQZ24mXhhAywRjkVBmlsmCF1QtyTNc6k9Sp8JO++ZluRPmLB49kQxKNtw3e2lO8L1uXt
LG5nEa3sCdvJrJobhwU8WsoeLuTKGSnkrB9PPHlshdFiFOvg/1DaYdcm8YljAeizCFDnVOu2TWd5
Q2qORA1QuiGwOt8Kzp9jmmzvECDb5ABUuiKQd6WKvDZ4aWYxvEC+0YebalR/3UaG76fhD5dQXtLq
Si59qBs2Vt2jbyXZ3xsS7POh9JTia/FrRKImsSLH3wdSgr6a2N077Bz8pAdjjTsha4AxGXfus2ih
DFMP23tHq8jMF5Yo87JNdmcLms36e+6x3w9huA36gQbrq0GJx2n+0ctEwxxZTWXoV10Or0DPRYLZ
qm+YsZABFhix3XTj6kOFy5lr0FD4rmWmwxI9fa2Jqw90HZKxL84UyjzD0mIO30jdLW6KMH1YgC5x
fTBXeJBH0gKyVGKxIN65SgIgYt3OPHEKj2osXKSOd3KIipMe2h6iJlLw3ryGKzqCYFD91EVqzOX6
XDfe0RHxYNDaPx5UsQP7oURBybVRt9XFLDlGo44av1ke9IwkZJVijrP6cM70LMbq5738A8mOhB8Y
5PYr0W6kElDLwmZXq+1QxC8dkHIg8MhGeLCQrwmgXoZ8LFiZ0+PbKUkaq065QMw5bgovZZYHt5EC
lZ8b1wWjvAguiFkja7Nfb12L1dAmwfuEZhamGg8rqnADFb9oivUr5tIhupwuDL3t0JjuUjghaXH2
Q83hRjZ4X4+2JyC+vumDAKiETKlE1PE8tDxDqs92bHE60mVF1ZPzCcOjmvrErj26ZJgICSJD1sKI
dvYrPN7qKZX1g91Doz8D6T86T+qnHCgKlwdF15VN1i/NOQDydGRTqsGSTtUimO3a3wJR9FfJwVYb
gcQAto0R7WqfEoSw5+ACbP22h1nwrh1Qcj/2iHx3rT3eyeySUv+jxJqOrfCLo588xnSWulfXlYlZ
qiN6mPVUdS7Nca8T3ePrAdVqyh9yyuqGKcvdZcsSfs2jwE45NzBXrUcAsS/St2IgXaVsTbMpDS97
bGM5MNO1iwN3BdsQYw+j9Z3dNYzPzb8vCuNlfwhuQAw0LDwze0P4Fv6LUif7RdS9rnHHpDri3m8e
Wx+9I5Ye5eO2XnAIODrKriSjwymvyvztiOoI/wFb4YjYgmvbYqC5eFviffFGQgRihCxMvx3JzgaP
QQtYXs7ET70BQiGMJYn0x5U5ZkMCceVo57YiPeyfqEny8mPLBibJlaeSN8/pheMZQ5+zxEnCjYeg
P8NFzH33zoUGBoDXfgWHXaCSiv9hJrIWfWwebO2quW8Au+yKWpsg7D5F729xbPriBDVhEeusawiR
pbq4DJCiSyPpLwYLSGCssskqJVkXEur2Ybk8pjPW52d0J28rms636mkR5gdFr2Qsg0n+bbX6L0Oh
PZQJ90zPXwL21bQ6DOWun3201tOehq72D6fyuW+cM385Tv0oj66Pdz9JqovvNwYHtln5U5TPBGvr
/tgPAFcHq80qq1bJDJfZE1nj5kLFIQIM2+zyp+PsjvnspopYwV3ugkxlhzEaCYg2wrgHue7qzwKA
Ne4+i5rj+q2ZKSqdtsMvn6aRo8nCdLpMXCPCnxE6iCiBOQyDxACKqex2+UfuCoDDbvtb5F78w01w
t1VvctqmIF6xCd/ksi3stlZfJSYbDzHd0BQX5dOD/pGwsK5ioaluyJGz/Km4ZSMLwmDesz+Eipaq
ve7jy8ElafqRq/p2xa6uwdACid/4/k1Q0MXgXAr4g94GiqNTpshlpx55g+X22VC4oaq5Dq40wZOQ
PwqXRnCB2VwvZOkYvA7WbOPHJl1A6CPg5jeW08Fb5oybIdno4dVd3ET/jEdeAh6bLb+kEgJcYomD
OGv+VG4TxRwAOfRc/rzAurWhtXpYI1P4ShXTjVDE5CjuOel6tegChok8EfpPB+nOsx/nXZIAbi+n
/52MaTRgTL3p7euwNQNnLM/2IYW3DWVBp09zobur0gjLzc8cgqCHKDvdneQIB2c+lNfX96LAocPJ
L7+nlWp/ZMYpKUvWgHD4vrnWsi4wJSfK4g8zx8f/i6Q6KbV9QFx7ciEVE7PU7MJH6C/qELymsMTW
UpxrHfiwkWETiyAxXXw6r4wUXFXX9N1ZKowYtg1FZOtU2+sWnR8kpocc+KJabBBLqbrZKfWhQOC9
yGBbDpY1sPyFTA0BvCGD77T1y3QYNNRX9feoVYjRkh46r9yDhv5p7VQbsuKZJOt4ARZwHkULjc/W
m7K0Rl5pB9buG4fQTwHzAfjEQwjBhUG8uiQnRiGiEsp7nhheZ4F+KyRTtBNtDJLbFxTzpgMuUVFX
yU02XpcqKpCzTOgC24s4f+vqcUUGP0P5R3jiSFsVN9+ZBtZ+6Bcodfb4U/Av3YHULnK9VXk/fjWr
0j+kMF3trK80OJv9E4m1FMs+6HnyPqC6axV09NGcCbZYDu2U//cLZvUDC75CwdIpyHgP3V+j9ebH
vHL9Q+l4MhuHJNltgBqgmjvH3nJ2CS6PHPU1Q3dIrbaPRVCi5lYUjp97tqWAm8ZRfXY2A0+HOkeY
JN7ty/1bFvE379F8/c9p3EQRkL3aLOGlaRRYTjwYREwkQDKkjeIGX2ZnLFAp/NzoWjycio7hBeYv
k1QXKB6EIpW4kKqVSxlphN/Syvg1onjGs83un53KBKz6DbgXkcMBUkuAnITeG7URrIgJG0WnEwtr
miALCmoWf+/4eUUdgpHbJKAhUTF9IvVbW+PCEkkeSclvOyTpUd8pDTvdy+mv2/bVxX4B0Pn8iLN9
RcBwV6ji1B0yPGYLIWoIVjTq7ikyxfVJ/7ovo82xLka6xfTVyzdBVo8f7zwgpaIUODvJ/5ffDkwD
RkXkH6gDM/X+q3RhLxrI41g7XvSXtNBQJ7zwpb9yBmhZcdgafDTU+y6jcEJhNc1LKY6Lq2gC6v0y
5He6g09JFLUHJzti942Gkp/1UhhP1DV1is6hAIvTV8t7GldR4nQOSzChxrse279ZIiK+KNEtafDK
cTrwz/vrhtPWBiuv29yimbfYpxcZUYdClA6aVspJhnnxT5N32Qsvvw2zYdAGE1blP/xSUdvIEXwG
nm0dkBTn1izX/tCxB/idrVosgVGuycaH8Kj+2ch5MAGtv6hUR/OW9fFz8bcpvji1pIvBBlSRhS2h
Kqa1NzEZGBudtLoRzPpfrx1ov0rbbvKSUB5ZDTLGV35LcGUfwKtBxpWsJvMotbv+98ydGiJXB3WE
ZudXTTUhb0Ogix9RSSqfv7v7yOcrarr8clAClqK+Ja9qgXldt/4UPGhinj5n79CL1BuFjuaLaJRV
ZV88fUmuYASD69+mcBEPAbfjPpYzNKwY5g6TOZSWv0SFWwkQ4Wq9f+RooYNciHtpuHb6YJ+tqqdd
MIgwj2gEKhklTxhgsYKBwY7kSNP2hWM7YCsrsG1z6LcY0MzS6HE2PMCX1/HPFtyWJFwBSYbh6L//
7sriZ9oliisclnNaMKqGUGhLjECgxFiqvmRnXwwXJTUPC6k3psskGV9yDPkvSinAzk6gS59P0CeX
zo03//HXD7tQz8QVgJsdzs76kLVOKrkW3lzqVkkl9g/zAo/cDcB2A2bLqHMe1qO5FO6UPs1Oj0yO
xH17UdgXNUkyPT8YFotYZhK8AOpJ22PcM9DxwL13pnqs3OvHpRF4xPj9Jzr/JIKMi5bSibMvYP7N
ad68tXvTj5M/TrXR8KIt50kjY2So6QMbGSYwhPhy26kK9YjNRTK2vLhQ6JaslEGdMB1L8+ryd2Fv
0dd9u1oMW8BLIpUT0njy6AZw6LAZJqrSv51df1NBycjO51tAK91mHkK9Bk1fafMyHXeuvCIdkuYv
rzzbwz62He85C59sMYu2hrhUBLOyvvp/jXdXlEPahUeNLODbXLfS9N28TueQHt8YsQTwoiOmA2y8
D6YQW6cisDFZC/JY1dnNA6vAgJJh5hPFojCc83sdQaTPL6I0PrDO2Az6/ZtNKHzEDWSdiHULhQ9O
cy0YGJdHOajOoiRL++Cs5ZrFQVMlBmLObdBnJEjuZf6gjA1PGwisCP9v1RGsMgbDyX+qqcufHJQ5
BX6AVaSUJBGNluo9KZbXyZ4iGiYsmqKHa7ODS+Id7bnh8FHkMZhjl4WLVufwc6EFWyvxT3oKOqF2
ufVZIOxjqQ91M4tZcbJkQIFkeiY/ujilwSuL6ghMQxpg4E/754qrgeItk9IRCYI7UijfJsb1XA2e
RxsSct0K+kwR5P3SXdD92IlFD6uKCFawekPQEHlXXK6bClbEpSw10eWcQZGrvPCUI89S2ZywTTxJ
t37RCZQxKykh0ekLvmKiEdByKUromhPVnf5EsJNXs6MtY6vBkqG72ThmJSs8RMroR0g6BJTdUojs
RhVUSpoQKvZCLeMm8FBKiurNbBadG2zP+bsdWcQ/Xbls4MFy4KS7ZawCjE7xO/EC2U0/f80ISD8f
zfCCbzgKq21USu3brfuNop4WIV3PoBIHdNporYz0olrgjLARWJW7TLZSTbvLn6PDNLPWGJSztRSg
hdvEGHV3OoYIbr5xchMsGSqn1SHsQ+xTC5i7aR/r+aVd3hDW8T+A5IzS69e9F7KoV39vbmman4I8
TP0Qt/qOWGTcj2Bd6WYqZBF44kBarz1bXeDZm4MasssZ1QGPXeIZ6F0N5OEeFkW+6zaykQgdt+i6
6PcfKh26v6wH4xarJQsYY4vjif/qPTp6WH3pLUW83rKKlPjYGolGOxRUG1vfINMdisOKE2JVtCbo
vVF5iaWzN/zhVLfespt7Fm7LWE0fHpEyHEk6F5Ne/7LTQtiGUoqJbwwveTm+si0cRRZfFj8pQPJL
BPoVZfaJoZzG25t1W/6ufBt6SXOieUgRIsHeoWHYDwSsMk3W3AUlUe9jYx1mgQlqxiENrMhleeRx
W5i5NdhJ0KgvQJeohsW16O8WVhVWDAgsTjHoXiOFyDx0Pnivm1usizhf+G+QAqRaJHI62usEQr9P
In0lOAbCbDWI0xC7iXWG6Wb0Oa+STgccwpUtg+Ap1zHUK+1eGe+7MrKZIZ7s/OoK3Lb1dSiTBAzV
ydCwQ8XAiBZ1K8EDchY1iikR5GIU1raGS/bDLJELB+WghNVgkj2yp1J+Yd3ahTGbbZ+ENCdFfBYn
5rxFIcHtScMy2YTkHFa54mTFtHdtqJV5Yux2py/F2WGtHuWTKn0Xg8BWElwQd8Oz6O0h6UNQr8Dt
+HBMjMHNnYC57GDR82E4aTfGTxHAOdSZffM5ksvWfrJN1OiwWeEMXr8axnFIVwIPlylhEBmxK9bG
iNxkRkeEx0fSVejuPl5FWYIbtiXPgltOOhRw+W5vEgCHTQFwOXK5kNf0K8GP1Qs/eklqvzz35/ax
Cdr5axM86WMYN9XrjTjOKZ/K6DBaLxxSTm0vek+Q2geeU9bspvVCfunzY1ZpbNqATJgRVAXTMxx4
IcjwNUTxokMvQ6M8YY2TFRQ8vLHHOeoV4s86oNc1CvV/vEiWa/q79Gyw4+VKSyI5fWrJwcOWVhYf
bbRRna+hWsFe+8A6cEQ2PBg86cyVlVmUZCsQocK3WMIAdFTh0RUhdryj29KTwmPgeP/ywVq1LBj5
Vc7qRK54cegCU9587D3zFlFb/01VlhmsDS2Mqxs+pmnjuyt0g4wuuqCSl+5FahCz+7eLeIauMUa6
gW1p8C6wCp4DOzieRk55OaMeqdQlVMD/8a6+Cmj0EId7Wo6fTWW8XIA7n4TOPgMB+/iooi5lBqhl
kwjKz+bUp4SBErjun7XiD//z9zIk3rsUZZU9bGGE7IIjntBogeSHCepl19G79nyeLiRUxHO19mj/
LKcdMTcItH/50RgSRUgCESXLUINI4rM5x9Zc6TtjZK3nmsC15m/dZKAMqTKtdtQELQJ8OBO0o4yn
afnUSSKVrhGMEGvBYAcCyr6+XdMGLYvsrDLpZohffJFq5n4f5ud0Nd2Ppd4LBu6/F/TCXwVUuEB4
ApHJc5YYQTrxyvr/KdE+E/1nQsFJu3PdW1+eGf1RqiVyMLLCWwcL1W34nUpk/xfc2CS90baOPCLe
HznXBKz0PXjO1MTD90vODIsPAGWK6N7xTqjq7OZms5ety+9whvg7xAnC2qi3m+usMmKqXZ9MPe66
3OoNl3S5sypKBjIyMT+/82PUd4VHk9rYMHBlg+3V2m7efXLHdwj2M3wxuTtI+MsbyuLszgQp1nH4
NJptO6Luy/3o7wGC0NxzDJcrLUqTnONAsb8hZZ3/Cexr679B3zSYjYDBayaxDqJfnkmK0I6sWMa4
dPMtxrKzpyqUNP82Wt8hVe6DERT3onf1e9pVgVmvMhk8QOzsAEYO4AfLju194YrR77B2v3jXtDBa
o/iovh/ds94EXrnrMTK1kFXX1OPWSoK/Hl+IPaGGsVp923bkoCIP98EXEQRYWYXW3IU8Q8TOSV2b
0kBKRRWZrcoplNyIwZlNj+Hn7gJff++ls8k+1Numoo6B9LYwYsoLaZ2o4N3VrRdsnGc4EWQO2hPp
tsbNTBZ3hnSM+26TA2T5+H/ErM76DdwIkm1uHBbwG1TlqzymfIkyGYwegSo7bDOuqehTAqobYPh/
jtqTQBeYRJMf56aedRYZ2oeZEB4Kaf75xHTIgcVS/+yr1fNqaxI0mCY1BWUJVCLhKm+yf5NOhCWS
ikVNjuLjnnYocrOng2xlQb6/r4fqeodDLuSBT+s7RdnUoZn5QkTFmziMs4Q7l8D2iSJ9s7qq0gug
dUJIsgCFgPjzf/yDr9LRHTTtLFNUBhJ+aaOacuewldIM5jWGc4p2J3oU5eJqIwxXi9TDbNgLfYZM
O8f8T9JGAryb5iam/248HEKTkPuky3X6UYLDFVwZ8K23AbIZ8iIHXEIy+yfT3MqAzm+woc+4F8O2
dcdY3Mev9QhMhfSRXfjb7ETMl0kEYOt0RAHNNXbCMOU57NdWCC/f1X4TVl8K/9NYpl+8aDvk+ncP
pcWg1H1pYlHCvU7UCESpELgsMudetUounkcT825T1n9GQnGsugsBs5ZafC31+ClBkcJumhM0F6hy
ZZ4vEAJNzoEJvCYxf617yAkyGndE7jhgkYFaV3yyt+YbwVLhRijgyLNkt+BrnNnnjbsN2Lvqx+fj
L84+gLCLezjUoGKcRioVM57d0HIwQJmn/dxh1WBOYT2+kqLvBxCkIFLyeCDunSfKRnom2S+YKuzj
RE8N3cedm2HoI+TIE5erPOEkSckmaz94COMGLdR+sVb+/V76GP2CEw9X5e8tr3gO8pB9V8yo/2co
RNAPPz90YrPV0JU2FUp8RVTbwfty+tqS1a+XGELCASQnepBlbr35q3BaFLG3euToMXqFh3ge3/Id
dpOvkxN9HQfy4hN+9GyiU/pAadx39CteILgCz6maQyO9O/qTnDxy+v+7zKwBlVCmNboxKeKqB0g/
VGv2YDxT4rCdzqfKa09vwQ/zNNpmeW2chkoi9VLyjZFTCdv5TWEhmYOUsmZNBy7PmBCpKeoa3ulb
Fv6Pxjfb7fmpm+BRkzIbohaXcthkFFe84ryIkEF3ZXIb9KSY4PNXiZA+U1yX2jkOZHmh7PUsVRL9
gRpQBBOcpgjQV/E4ol+dx12hKn3yLNt6ubmIIVvnJkqBG7ityoioS1FtcYVNcxObS0FQQlxuUjHy
4V3d3JhOAC0SGdj7zMJtEkxtZWkJanXkhhwncWC9vRl3oDrWVYSeXuZ6jtyz+9fhWkg9eGjWy0d2
JQtVWTpHRLO7DoUoHtl3KAYiSYURsxCR/OP6lZcdN/MD0nK6qlCvDLoFteYOhafIPnQMccuf8aKc
xZhyGt1qpamiemhveFGEz084bwWgiM4PRkGkT0XqUP6G9FbTYATX9f/zbL7IaIpTrd8yGkSa/npC
NefXlKU94jqqV+f4+Yr90JHzmWmsUVCG8KSaLh34650ycm70iGoj2LZNI5wa5IzWYTSvswCJXG8p
LB3hCHotoVRmGZP8yOvPbp0etp1i/OLT9ihhl6PSfGGzpSwpMNXR5XFyWsDq2zb5tsxQpMFBaiw4
tAifLS3pqJ96Mg2+vnWigBUuSlkkmsM3wkHWIH3cmhwDFQwYzRqkqcpGGHqHKc4E8IxIoGzl8H2u
NeOtqSFnt2rCXN9iqGPXaikqrtvlo3iQ6c38doj/83JuE97pMlyE/NaqWnEOu9wL1uctdNAa89oo
7BKmmTaJqTeGGiFKaaISOw/SSlQhCKSyaHHEJJYXPv5z/hUgKoh89DV+gMGBK5ECe8wt8hxn9YbM
xShSBPtDwAzbQshuG+O5Je0IsiONAWEO/DyJraJasF8Pd1NQE1AAvPALDdm3LFxAdbl8KIfLC5UH
YR82jVlTuu7iybYg3GgWP02yyO4K8JVdhb8bHHLtj2xi7uT1F9f6UdWfKgtoOuL63bDZJDNuFzVF
/9ZL3qHWS+iNlEYp1sloQoSol9uuRvqbkl4NtOLqLdFvlL4cnmayka+VrTNVgj44miA5SSpqlYQA
mMIuUeeGaN3shonusNBfGy0jto3esAJOKN9NrFSgs2I5J02+fsfgwdFmOubmhZnGd7dCUYjumrL3
v8cd2KZwy7ALGGHUdCSxM76vTS3Qa55YtvKwUiN4BJFYTuK4Lu1cpbpM/GMqplOeNco56rSecwfs
W1UYODrsXLMwCo+JuARAkvQC39TLh4R2JLjI6m/zutI/JmyW6NwvjYAFtevHR4gQpHjPR69UZ3/7
sOdzqQ6k3ZRPJEaxbZkb1aogElJuTnpa3XzN4kpNjlCpKKnWB9l4U+u36ePTLKKAsHeMoBZOmPdw
L2CTx+bGyZ+0OISeDtCI4cUCo2RqYIv5QUMCzvtKiHUogzMJ8LoixleWWAVA/qECma210qZqXUJ2
qvWjLWcBiqyK8rjJZ4G+SldLMA4bI2XYsafc5yhSMddvwtQFOlNvZnC0p88FjWUVNBjlJUYhg0CC
fA5jKEtHuRJqCOoCATmguM46Q10QSO+gjTGm4/dZUUjgsHOV4pjMqc5hTc0tOX774G++pskaApfM
YaUh2LzjP9/JLWKFBT1gzO2uboudlqSDYDRxuWN2kpLhtn1qFJrbSbh/w3Vdd+SUAyvrUCQ90QLx
4eiX6aDK+2yNCnUQAS3xsd8BK9muZhuzYPPmj3X2sfPplWJiWus7s1ijmHphtTKG2ypfZ5TVzpxN
q1joUHq6yRTXIB0FBulMLkatwlpCe2tOv8Yg9apXTGXU/vVPpjE2hjFBsSpnffJ7QfVPjcLn6s5Q
rcR8wVRKVeHk7LiwbtbNd/+jrXTryt/f8fNc2zZ6lZNBZlVTuguaL4DPKG8wGEl9QO1X67e5SbTL
dWB0WZ9xvKIx3rnEm0r1/WTweg8M1tahoSfvHXHoMsyIFnT3Jet//YBIICqsiwBiqyiWlQ5TVsnK
exH7aEbCax8U3zCixFt+0bAhboF7jvWLiIDECrTVIWJL2h461tbdFrAkqEDT7IdAC4LnYKI7Mo9h
EVRPPF4cAeP4LyOXVdNEa9h8h9i2WXNwXo4mSum9GFv3UPuMgSncpvAiGtoHKhlFRbZ/sNMd0Yvu
UIje1uBm1/PeXeTiBF/zmd27PC6U/Z2dIMDIHdx+51tU4gqznlrjTeYA+MWJSGgOBukxywHN2Y8/
ibOzDbKAyVpzZDKMdj47dmSQz1kaz8qOIVJ0B6b6+nMocNPcu6kjY70WXYx29Mt8g4wTg2QUFWLT
HCvRwxm41aLYbavDYi84e3mKkhvwNrvaxVBunVAJar+eX4OfqGILBCWqJlhgAYKjik1aM16xzw7o
bpsDxr8Vq0i4xnuSdb2lzLYmlHWeg2UngMvYSs3ODuxhfJDB6Ebap+kHGKjtsbvKigL5NAZfT87G
fDNePOC+1ntCrBINJ/J7xwA+5LWHFRC3HHRy9j8kCSM96seD6qdzaMJFCboN5DylrI2GVuQOQLzc
69YbTS7qzczyOIIeMEK9wm2C6lLmaHtZDYxvtJtUH1lV9KzfbGpvAaW3ho/G9P00CTmUH9+6Jm3x
s4oYaVWV1Ykfe2rCWjXdeveSCPs/wUdCR1GHJuwVUnwsXP7Xrd/UeIO6E/zStkP6PhVBulcEUjoa
ExRQjj0aRPRhqDzXIj8jQin8YKLjjUGTGN0jVpgepvpYnE0u7NPALuNxOHZGGpittDia9pLHxET3
JgWXXXJw9l8Zc+ZtpJb9oXzEXcAIQNrbnMNt9xod2cbEw8cIPVJA6ar/IfzgAIgFilj8XTKPSTd2
QR/cAfm5xnoJUyDXL5xQXitrCQrs/3HKjt5E6UwrBRibnIahE1v7k7spsCFVoW+lNs8zY63AvxkQ
SbojtKZNAscKlCias0mp9MLRipNY+baTX+vjgRFNB+wsOVErPRJEB4U6mbebDNkPS9PszcbqiWHd
BUVkC8ioMc/PjXM7nARBgw7Kse9HEe2Qpyx1hu6n6z4/PJfhs5kZ+b1dCBnJwn6j7NwpLudmjmce
WIr4ExMMpTn/b+x+YSOrv+QPyow7BKOvysCf/9hhfy6+tfaeveFyUdzS/Udds8wwPx6B7WPjfkSC
Z2gR6QjRyipeTu/U1giACfTeIfBRE9D28b5L+tqOAu28KV5cjTfunkrSunOIU9A1oXX5BdP6quYo
m0eRL50ylexC1n/Msb0UJNyH7Eqg3gUjMZCWZGOKKJ1eScgfMlm2yPHLYogzVJnqRk0xRJTr5zSn
psH8b8rcYNZQkazjjNjCyqEnDTSMh98biaPMuH73QgTmJc2UnoGx4as35CvbePljEgd4LbJqc/YX
COx+7LOthiIu1a1D1eo6xUyDbkH5gFF145f7BaRjuEQrh8tg+p7aU+vioNMGOGEjEaboiG1Gzgit
bGSIIP1ECGb9Z5KaQH7x25dAA44T3cBdxA4Y7dADzvlLKbdvn5m4eQtr4+C2zCy9y6ALdKKZ2PqO
Y8NNM6OiVHIzvJHLF2M8NRdZ9MUdMIIFNVxP7rQM9jO4z+PCdRE7ZTxnwagh0phTQsERuyhQ+xP1
NUoYOzsV4957Wogu2zsFHPi7NgstRQqV8c85VfsV3v2mdMbxfdXXXnDmqCZrtLP+gN9c3Qq5FZus
O1IfTZ6WHg8t+eFmbABAbwl8R+USMjSyx5U2HuVt3DVHwtPKc9D87B0qf0gcYAXcrCBUJHN9tHc/
bw==
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
