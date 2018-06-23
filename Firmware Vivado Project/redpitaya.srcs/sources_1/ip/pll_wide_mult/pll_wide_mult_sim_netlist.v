// Copyright 1986-2015 Xilinx, Inc. All Rights Reserved.
// --------------------------------------------------------------------------------
// Tool Version: Vivado v.2015.4 (win64) Build 1412921 Wed Nov 18 09:43:45 MST 2015
// Date        : Sat Jun 23 00:23:14 2018
// Host        : jdbureau running 64-bit major release  (build 9200)
// Command     : write_verilog -force -mode funcsim {D:/Repo/Frequency-comb-DPLL/Firmware Vivado
//               Project/redpitaya.srcs/sources_1/ip/pll_wide_mult/pll_wide_mult_sim_netlist.v}
// Design      : pll_wide_mult
// Purpose     : This verilog netlist is a functional simulation representation of the design and should not be modified
//               or synthesized. This netlist cannot be used for SDF annotated simulation.
// Device      : xc7z010clg400-1
// --------------------------------------------------------------------------------
`timescale 1 ps / 1 ps

(* CHECK_LICENSE_TYPE = "pll_wide_mult,mult_gen_v12_0_10,{}" *) (* core_generation_info = "pll_wide_mult,mult_gen_v12_0_10,{x_ipProduct=Vivado 2015.4,x_ipVendor=xilinx.com,x_ipLibrary=ip,x_ipName=mult_gen,x_ipVersion=12.0,x_ipCoreRevision=10,x_ipLanguage=VERILOG,x_ipSimLanguage=MIXED,C_VERBOSITY=0,C_MODEL_TYPE=0,C_OPTIMIZE_GOAL=1,C_XDEVICEFAMILY=zynq,C_HAS_CE=0,C_HAS_SCLR=1,C_LATENCY=5,C_A_WIDTH=10,C_A_TYPE=0,C_B_WIDTH=32,C_B_TYPE=0,C_OUT_HIGH=41,C_OUT_LOW=0,C_MULT_TYPE=1,C_CE_OVERRIDES_SCLR=0,C_CCM_IMP=0,C_B_VALUE=10000001,C_HAS_ZERO_DETECT=0,C_ROUND_OUTPUT=0,C_ROUND_PT=0}" *) (* downgradeipidentifiedwarnings = "yes" *) 
(* x_core_info = "mult_gen_v12_0_10,Vivado 2015.4" *) 
(* NotValidForBitStream *)
module pll_wide_mult
   (CLK,
    A,
    B,
    SCLR,
    P);
  (* x_interface_info = "xilinx.com:signal:clock:1.0 clk_intf CLK" *) input CLK;
  (* x_interface_info = "xilinx.com:signal:data:1.0 a_intf DATA" *) input [9:0]A;
  (* x_interface_info = "xilinx.com:signal:data:1.0 b_intf DATA" *) input [31:0]B;
  (* x_interface_info = "xilinx.com:signal:reset:1.0 sclr_intf RST" *) input SCLR;
  (* x_interface_info = "xilinx.com:signal:data:1.0 p_intf DATA" *) output [41:0]P;

  wire [9:0]A;
  wire [31:0]B;
  wire CLK;
  wire [41:0]P;
  wire SCLR;
  wire [47:0]NLW_U0_PCASC_UNCONNECTED;
  wire [1:0]NLW_U0_ZERO_DETECT_UNCONNECTED;

  (* C_A_TYPE = "0" *) 
  (* C_A_WIDTH = "10" *) 
  (* C_B_TYPE = "0" *) 
  (* C_B_VALUE = "10000001" *) 
  (* C_B_WIDTH = "32" *) 
  (* C_CCM_IMP = "0" *) 
  (* C_CE_OVERRIDES_SCLR = "0" *) 
  (* C_HAS_CE = "0" *) 
  (* C_HAS_SCLR = "1" *) 
  (* C_HAS_ZERO_DETECT = "0" *) 
  (* C_LATENCY = "5" *) 
  (* C_MODEL_TYPE = "0" *) 
  (* C_MULT_TYPE = "1" *) 
  (* C_OPTIMIZE_GOAL = "1" *) 
  (* C_OUT_HIGH = "41" *) 
  (* C_OUT_LOW = "0" *) 
  (* C_ROUND_OUTPUT = "0" *) 
  (* C_ROUND_PT = "0" *) 
  (* C_VERBOSITY = "0" *) 
  (* C_XDEVICEFAMILY = "zynq" *) 
  (* downgradeipidentifiedwarnings = "yes" *) 
  pll_wide_mult_mult_gen_v12_0_10 U0
       (.A(A),
        .B(B),
        .CE(1'b1),
        .CLK(CLK),
        .P(P),
        .PCASC(NLW_U0_PCASC_UNCONNECTED[47:0]),
        .SCLR(SCLR),
        .ZERO_DETECT(NLW_U0_ZERO_DETECT_UNCONNECTED[1:0]));
endmodule

(* C_A_TYPE = "0" *) (* C_A_WIDTH = "10" *) (* C_B_TYPE = "0" *) 
(* C_B_VALUE = "10000001" *) (* C_B_WIDTH = "32" *) (* C_CCM_IMP = "0" *) 
(* C_CE_OVERRIDES_SCLR = "0" *) (* C_HAS_CE = "0" *) (* C_HAS_SCLR = "1" *) 
(* C_HAS_ZERO_DETECT = "0" *) (* C_LATENCY = "5" *) (* C_MODEL_TYPE = "0" *) 
(* C_MULT_TYPE = "1" *) (* C_OPTIMIZE_GOAL = "1" *) (* C_OUT_HIGH = "41" *) 
(* C_OUT_LOW = "0" *) (* C_ROUND_OUTPUT = "0" *) (* C_ROUND_PT = "0" *) 
(* C_VERBOSITY = "0" *) (* C_XDEVICEFAMILY = "zynq" *) (* ORIG_REF_NAME = "mult_gen_v12_0_10" *) 
(* downgradeipidentifiedwarnings = "yes" *) 
module pll_wide_mult_mult_gen_v12_0_10
   (CLK,
    A,
    B,
    CE,
    SCLR,
    ZERO_DETECT,
    P,
    PCASC);
  input CLK;
  input [9:0]A;
  input [31:0]B;
  input CE;
  input SCLR;
  output [1:0]ZERO_DETECT;
  output [41:0]P;
  output [47:0]PCASC;

  wire [9:0]A;
  wire [31:0]B;
  wire CE;
  wire CLK;
  wire [41:0]P;
  wire [47:0]PCASC;
  wire SCLR;
  wire [1:0]ZERO_DETECT;

  (* C_A_TYPE = "0" *) 
  (* C_A_WIDTH = "10" *) 
  (* C_B_TYPE = "0" *) 
  (* C_B_VALUE = "10000001" *) 
  (* C_B_WIDTH = "32" *) 
  (* C_CCM_IMP = "0" *) 
  (* C_CE_OVERRIDES_SCLR = "0" *) 
  (* C_HAS_CE = "0" *) 
  (* C_HAS_SCLR = "1" *) 
  (* C_HAS_ZERO_DETECT = "0" *) 
  (* C_LATENCY = "5" *) 
  (* C_MODEL_TYPE = "0" *) 
  (* C_MULT_TYPE = "1" *) 
  (* C_OPTIMIZE_GOAL = "1" *) 
  (* C_OUT_HIGH = "41" *) 
  (* C_OUT_LOW = "0" *) 
  (* C_ROUND_OUTPUT = "0" *) 
  (* C_ROUND_PT = "0" *) 
  (* C_VERBOSITY = "0" *) 
  (* C_XDEVICEFAMILY = "zynq" *) 
  (* downgradeipidentifiedwarnings = "yes" *) 
  pll_wide_mult_mult_gen_v12_0_10_viv i_mult
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
o/R+cJQt+dmm6sqqDqJ6HnfAdvC/T6UvCd7hh8VFfMiW2Ubukwnb6baarRI4TZJy3+z25RHVzMFQ
ve010WFoM1muVGXdg47hl5kbQJ5HSBc3PD41bixTGUv52M1rHr7YgTaJPJQkoN1KjCB5a6NacL/r
/jxG4t1JH/n65N5phiVzHivChQhP7ksF/uL5k/YP8zcO2eeffpuuEw0HlqESZpYmqUa9Cn5DxoCD
NCjUQmONy19yu8135jM7HtL5Kr+tho0Z5u/GH+USRexBl02yjR5Sp6cYSTgstnMNkiqzlahc2IC3
5AdL5VACrVHN09NzojVw6QsoYRxvShrRYhgvPA==


`pragma protect key_keyowner = "Synplicity", key_keyname= "SYNP05_001", key_method = "rsa"
`pragma protect encoding = (enctype = "BASE64", line_length = 76, bytes = 256)
`pragma protect key_block
T5wqn7IrgRdW6UVCHz/OiEeRp+C6QPZskYETTm3G93TiCttGDUW156DMN3vls+JC5RFyrleFAEs3
jB83Qq4WUY8B83EdJRGEGDNxuuDRslTvhq95yZriFGAKEF/IdTMu9XQteahoxOaHhfP52Zmk1J2j
D8s7+Cx6pCGTHXmacAjO+YKsz1kXA03CFT4cT5Flab0EVrIQ2+bfd5Z24bokfAk10dzkHt4DNU3B
DCceJ/7v5N8kRSWT414kZSAy4qo6365t77lD2pzhrYq08W9SJH8dvTcpGZFprvOR0YE8gprDC+Ib
JUhciEnQiaz2GXcM7NUhGDHBnaoJ3HxsO1+DqA==


`pragma protect data_method = "AES128-CBC"
`pragma protect encoding = (enctype = "BASE64", line_length = 76, bytes = 22816)
`pragma protect data_block
XVF9Ix+9lpLSeonTsQd1vm/32PKM/w68voDehywmGaXA2WaPY9buPULbPI/Y4JghaIC4O69PjNQo
JiiyzAxeHsB2pKw0bsFfAiH8ysWsdofTaDVb/hAMJwiS8JcFUdPI7TrcPZ/C9nEusp70AGLiJX8g
xMoKmQw1IOJuK6lsrKP5pI0LZR/2xYRFkg9F2WDOO4A1aePw9c2jSddYe88SmSFPbqO43L4qgb6N
jGoTqmb6DgZLpLfVV2qGcfHi2s7hfrzYJ6MjdmqdBl9Y+DrHcZzjDBXZ2NMt4+G/oaNM7WRe7HU4
hQoCcsHRmhzv8BXCbhH2R5oHwsxd3oGriB0RqId62TRAeM5GhmKGogVEldEkroS47TPw9kByyeI7
EIUDk9ckp+PWDQ+07rd1MPSZtKppzCBQK/8YDGkwpwqx47sSZuUk7hsqS4M37Lx7eszd5Jvz1j4/
GbS1NAxM3VZPoHrsUbUFUugar67ObHWKF36845N5kar309RFueyESOJkVc47kBs1sqhVFBCexPke
LYw6/8AELpnF3cesZuriUAlGqDTC3lc491V/qRcw96F6FtK0zsQJ5ulFbyfH4oYw3DdbY26T7dMq
VcGzSgRYRGdu+KQUHu2SDhdnryjDQZMZpJfQkHV3tF05JxZIw82PIwpeOLZlKZFz3DWEsApyO6JR
hnVZdGrwUeeLgIidtoA05Thee7Ld8YkWE0DQmXZp/o9V2+Byi/S5Mjzl8T/G7aUiJPG49kUURt/z
R4JsbbUUombhLOIKhzjZh7CBlTfgdbBR0BSFs/SYRBKcyX+so0+8EwKmr2HUSfHikf0yRZxU5sFX
K7+dQQ15k7cQK0FjHd0A09mos7bfD4aofZzaSVVzV8FGciRYXPY3409fnuCNaBf+trPAyA6xIL+C
M1EApUiDHoJzlEW9WcRWKUPQabGqekD8YVNQeyhBkoMahRV0U8JplrZeSTKteKM48F5tnTnuaOUE
pH/Ca63/8p2QnqJYtwAL0wEXGQ/8an8V+idFUt/8iw2dCLb3yiDPHwDiM0msM2i7R1nfRX6Vak9d
ynXqKs50mPtGSg02WTkZNbB+avWj1h5YxlkQltevRpEKJV8eIWvX0WHBda+E6+azwLdHQOmbb91Z
kqN1E2bIJ1tftTXddHIZPPInzbHnUaTQrImjdZoMmxExnm/60a1M6xyi1Yya7/XK8tZypH3Zdx9u
aq3X8leQnD0/+lehf8V7CeEyxEtPTuuN9OusImlbI2fPsbaBEMGwO5LMHn9/EVd9kSY5DCuygOKK
fQSy7o5guTG1EbzeeUvcPx6yaoVF/cDmAHLHz32egBXLx08Xr66gwALHJCc35idPEwkUXa0jDorj
U8Mgm9N2JI7fDuyK6aWmrX+uxpctbBBEmct6CNszm0kJL0paCAfu+TUrrwBcz1D/Oqhrcal1R+LZ
9hXZWjk/AF0F6oD8Kcq1NPRYYo1NOxpgN0e4R69eITkQk9Sxx0T+dFuhyj+FQ4gGBLDwYaAWka+5
KHtkfuOUKJ6BJE7Jh3aHQjAnKYsT6w/MIkaTLO5CUGDwVxSWU7Qs0wFeiBcd1+2zuF6N/d+sHswX
cPcEu5Bvg6dUqy/IDG9P8dV6sBRR5hiMPROK0Zqsltp4FGLuhCYcngmMBbcTui1+JR5B/hQhTeaN
R0IKf4rPuIZhT68h/CJ1MdxAuk8Pe/Net31+yd8zAnDhRx/ZspJz3A1u71giEMJZYcka/5aOqHmr
x/Hotst2scpNmY6Hf6rCgIDgKZZIeqsNXimppwy358DY7CxqXLUzQKxQMG85QGKY/iKxNF8zi4Ah
ys7dNytO/LVDU6eNvnSw+/vC5Kcb+iJkGnzxsrtJ6ueWjvRGSoOcxDyPJ4eJVb736H812x09QGPN
XjJA4T8yrw8cf5sYp60ThOlT621m9wgHozbi6X654gwnsAokliVCyK/axEmwTNAaMzJHI0p/vxD5
rKR7wJyDsaULAjxzBusjwh+fnWq7O5tFgru7I7X35URfoUSBYPaGSKjzJ1wxbcHGIktjaW70k3QS
VNWYujRbooPVvZQwnFLY1Ih9ulgiO0mauTAeT8gwtKMcp2FiR62/QKjjXM0sN9DomT6UVT4kQgde
UqYkvEe4Z9GDFLYqByfz3P+UJTSJZBht75vA0bCldmqCkU1s5Bt2GCf4v8NnoFYyEN4eDccEXuDb
uWg8cRNrEsV/JqO9CvtLxqcJmqZ4rxKeyKA+ZIbLocUx+78rCRrY4z1/iC+xxP/iJ3yOF5K/BQVE
qTcbsmQ9wHBsUu+0jyu5wLq2EPE6wY/D1W2iELeZ6c1y2UffbYu7atKQTbO7hjbd/5Hp5tD8J+T+
9p3zmRigG5MKTPpd8Y60XlpGYfCDOEzGozGOKbTp2W02+Dgj62T68TdMzPWkLBAOC8g5V0gSqAAu
+BsmLz+tz+ph27uApRCIk243wR31LevoaceMKgJEGG3MeUX0Y01VRgWVVq4Zdfo6Tvb/Q6bt03S8
3TvMoXyUKUVS2uAzXAhBvtcB2tH0ukVPAVKV/hW0/d5wppRVVg7X3xUe2+x9tmFTnpAxHmAYskKv
L0w6/wG56aggZypiIxcFnEBEr4royCB7kFo4MrvG/n/6KJPH87R1cGyON+mHAxNZk/t5UgMX2lCq
nQwB2Ug65nBg8NbQU66v7ti1xpvp7sO1Fy35KGUlbIK5RDZMX8L+JbuXBr89qkpFTWGCW7tSSdtF
/keuI4jZnyqB1zaAI6byQ5Ec/sejYLnLAhx69vp8cRW06o8nvse1QmqDA/KJqLMGB+/B8wtqXbsb
S5KfyoQsZ/4R9AHJM4tyVHBlYiES6JmzIYO9sPTZCkQWAadop2DU6L5MuVJj58CXw+UmuQG15IkS
oIiHcEhQ8oT5kQY6jAk6kC/Q5GCW9wKU8xF4NSYsyfgPcAiFOvqTwqJZ6B8mfsKToCjzwEUNyI7z
F9mPkn1rwAtmCjQiBRukiCUqYtxsBTzHjiMQE80L8W/y/TV8105lz+m+hIfk9TdcY7HnIvB0Sgb1
slBtz39Bo0E8YRurAwJD03RsioNNwguF+vYMxkVTLykuAdy7PVmY68+LyoDH5e9pdlM53TUKPMdo
AAAJwBHr1FIn3x2lQJUcYovW89IVgxnIpnx24d+JFa47gZHqGZJrndaGGrNdEt4XqhgwR9QN/U2+
wRsRXid4XN19ZInQQ/7+s1/f/6vC3oYtgPww0kaIbL7i+PRoStyhMAaIHGhDYC04reIaKxaBdDTv
08a9ZG7f5XjDQcUi88lDtgyuKBUh3C3lKK0Ziszmpfm6XAx7+fPY8bEiQIPtkYkbLRE808muZQ8r
if2dNHAokwd8eFtA/MPR8nfM6enT7/HOe0zneTcfnE3GWG1xkZ/uwVh3ZmpqOq4HXMAyY9ohjcrG
wzRCzrZxC7rMi59XYJ2fMPR22hjOnMnPllKoAgF0egSy3SXISH3rXi7PbhT3Yo8fZz0xUEsnyH5/
tJ9grF9MyMo3paEiOMvzPYJDjehVq0CYc1TxqqCz/ypDknZtzhvCT1CTf6TwXqsXMxqSO7tHXn1K
CvOfIK2Kp/FpELqZsZx9m+4EvGUob1b7tGAJ9hStpNPAqCFtMjJCmNwLfx+umCqXyKA7GkKCVg0E
csJWLM4LS8JIvJNCm9B2KbP6VtzpGu8+jpdCZDptawyJ6yz6q35t1lyf8hgAqZdIBoxpQFuGKQYU
fxekMGsvX/Y8djXFYikMt7Yt+LY5sa4KfLj7q27PdvYbdddgceoebBZqrPNhpkCEfupwlioIItTE
HAOjfCVD+A/sPFlKZH3xcjky6924hIKZLgzL9Zj+Kq+OwLRDmHQnFnRwqjlKZRHe1h4HSOeNtavq
4JHXj2Fhba/vBlUAn10A3NvgkJcbOP0+QmoDr2inqDWpE6P323IJgGPjPHRpFcg/DmtOpt0Q3y4U
bekyRZvUyTh6uG61was2YGS7KfQcX57rdgB/Ab+GwBvteloj0cGF2InzD+iKexgvGrwRdw2TKD9X
yx19HhPgKzerPb+s+cZ84HLNUCajgjtlqGoU/f6O+PQdnO8Qc0vfwM1mndWfw7zzbEBc/AoeeaGK
wPB20GAeRYXIqis/I0NOQtv9RFzsnW99EnBeRxdQUPBv5jWddhqVEYo2Ylxilvqeu0gm6O9s5bCA
L14X7LRCCw+7lFMoexKQnOCIEnGvqPtXPm5tqiPjDfzlOA3/RzNXmYV1X7Fn5I2DpsTFlD7mdinN
7jb4sqe7yCGIETufdP+qiNsSS42dZZGahr4uDjNXxQ1BMmcO2HaBFTH9YZUTmEEofeeBwTnedDeQ
IberLkkApXESOf36AMbmZHjU4cQx9MpYExEPfRgLel3CxX1WyBZSE1PIOf82mc46Pi913F5if5wn
Col2UzWVAaULgVWP6FQOaEKn4Y6QlXHQnB1RVlMRSAkUBxNGYGMDS+3sgoTT8ldH/LxvJkF9UbkU
G+3o1WXOakEsfx0916wykdwdUQvU0bes4aYizwjNsRFvWm8jnxjTagRrowBIyoQX6f3EusrK5bI3
Nngiyq2LZs/0bXKuhshHAOytcQR67I+i88w4CnIbDhCyVxDnJsdrfMQygpm0Cqr5Jj1Rn+3KFMSm
keE0QVB6LtusSW4mv+hvWNXAsYN/mVIg1sXL6wkAfNoGRNCszgAgywtDlEOn9164IIQrPzG87Fo/
y59FWQAD7RJMf1V7dh3h9y4k8Qf3GLmG9MvW1/gpyCijhdRdO3F7WvPyUxYsABW/2QNEc7G4GYyD
Ehp6unuTjPRmQp656J/9f09nFw09IIfeYvpeO1iJtfUfzYusRUoYKIkBqxkF8VkciorVXilWRPJT
CSPr/jNKqOIKM1Bp6dqSrmmaCAlLKswm0EMxv4VXgd8WTfRNc0YOEqQ/xAdOFdR0nlkAtPsHUIJW
3KTsaIEQuHhvdw+bd+FOZLVcSsogDANrUuDRwXwAU7uvn1yqL2FWydAD8xjkbGeOpDDf+qEBP9dQ
L+ckEwp4lo0FkihCSrwz9U6nA5+ElqY8+xF1KDrofQ8BqaEU1oX55f4I7O0ixa5ppXwishTcL7L7
GeSjOe0mxx04yfTl+j+Ni9MoKAhGkSdZrvJfkgPp7GY+SZfkrVvroQTH/PpDMYJCgLZvDhsXg8LK
heGaOFfmi7Dj/98stV2v2fmdWB6buD1/c+Hxvs8rAvkyj/L3qSz58iDue19nzwHnHvJQjntT3E8Z
I1kqGnRgRDmNsP3UFVRXbhMefoKiznMWyfgONipWTyQ2GT0w/z/HTjCv7hyA8ELhTFI/gBsknGrh
WBZRFzRZ03dNSAkEX/Mft5Tp/qEevAp/LUprvRlNV6Gicbs8lJ2pz3rYFN//9iUJHnsDxfXYbfD9
NPgzd6Y+e23qQu83sKaNiILf6pw0H0SBpi840g13PQ5QvT1L7qcoyPZXsouMROPZVYIDxxovb/kQ
mai/xGhOUx7h2CdZImT7dYv9a9vO+XZ/EpW6ggOglGtRFU2zwTk8+KmXM2lg6L6qhZSYXRqSzV9g
0QEWv0hyKyMPuuCNemipTGAP+v8Bh/uKts/U4oX55FagvCfqg1ev8c5WMZESHyjmPSacP7aUukeT
lnZ9o2MtguCfTtpKKwqifmpQJipWwQzFcbgZa+GwHV5FjXaqV1g0l5/XzknmVn2yGFZ2qsfCMEEh
xVSuldVGlCn45s2JvqRoMYYogx96YpsWP8ccE+HQ/CRY5xuUD3CmVgFdD57HE6szKvO+yX3zZBge
y7HumO1A3PgOvB/SioPAcnZ8m5se6UaXZI8VNuCeFoZKuul6H+6hzwyimuDjI7+dgHHrB42qvvGj
UztAgtNdGzbXLxXiSgswGAEsRwg6Pw/xCjnqr5CWuu3V7tqN2s+McbTZemqeEb8TlwfdDE6d+B9y
7KoH1H29s1Cc9NtBHMlsKk0T3OtdPeqY6y3byei8veq5IXWLlD8SEsOrIv8r+xZVjqeY91OuUInc
/cjpZfIJ+agIQOURwCBXsS3r5GPSVnVvKEns6PSHQagg8bKq52LCrlxW3LeeBWCmX3+o3xua/p49
dBQTDUoZWRVyzM+ryJXLDc62Fd/t6ixfZLtqhry/S0ubY0CZj459h+mOExo1Zd3QMk5ZVWyQP8D4
lyhCrtixQZJ1R2gIhnG4VCrtgR1IbvOvFbRZZlySXMa5rGg8NjW0npnGgbK12HSIVmgUAtcIAiNq
L7M13p85sZq/HVIoXGI39KXq/w8Vh2E61n0UofDXVFBDC+ewwRdUwoLcKi+bGxBW5HaX0BvQL1qH
Cuxwxl+zRk3b95suG2dsT859bg53IZgPJShv39OeEH38Iwiyt2S+MNYR8v+bb8wrXj5KWBEc3qPc
pYbF8uJB619NHISdjQWirh8p6X1NXgbPC//1SHCLlb5KagHthFSnh+hBGXyDaYebl+bBt9G7g+vZ
UFIzGKAu0hv6GQh2EqPz69pQCaI4UkkI4zGfS5iKkFxX28I8WEGgE73L78Rz9spIHjC40AhTRBhi
MCNgsz1QBLBhNlaHrReyptJGS8qMGD9X+yh0LvCabcJ7Wtgh7ohmcwPbXgWyC4hE9wu7OS2OdX4h
uk1Xop8O9UgUIvsvmJBud+PfiTwLGyKlMoieaY3t5y44qKoBC8N4MXI1SBtCxWdF5iPOrtet32tY
g7Bf1LG3ziosvdRNkh4LFTDGZFMW55U2JSlGtp5BWHaUqwC1VAfO8N6WD+10vDzXzxh9JWwa/RrS
sViFwhQ5CHCRPP26i9d4awwAk3xf7Cb2VeLgY5/y2ceZwl2nCA9G7pofY6Wsl2ONkVlbLfkL4gxW
urkp0OrJLFjTU2xVzVrosJrnKGlZMCfXzdmuKlqR8lvLRfXyCbvy/9yHaAMzeLzSBDEDrwTIvr0z
++/ynCdwHfUqfQmxRw2GiRxttp09nRY5YCBShGAGbqkFQhzRDRfpBzzUfMuN5dXP9adBkKEmp1VJ
xl13d2TcAWiOSlrlPfyL3AlC8wrco2eFsrG8pjkYZdu2DIT3FMcDxJcMIYjGqJ9CCZKCCJgbi+Gt
uGxHmPNSJvJzrdPm46cxH1mUkZ6fxXP7yL5aEqswzbowix0U601HzUsoARvKR5H+7QJCv4UYpyBL
50uL65Y8dwfs7zybZvIPBdYUIJV+ou5/JwTqFHvki4kPV8yWMmKuNo9bnTffn1YpJzQOkRbQGobh
mbeNrREMUevKDJSaYY1fjGaC48iAeQCQnUvA634X92dNjLkchHkXDJvu6Mnglfv9AOj6W5mCS7o3
UWF0rw5OBfbVgbENEDfPy9upa2YV33O2kC6xSYSO4vmljQS0KWh/e8rbZzd6kqMUOdj31Soy3OI4
vHaW3aiOVfIAIhVXnZr+qMDvCMZUQ7UuAQNBNxMeOVYO1VCn4PA/Jncnef0pQ3+goLK0gNwcO1cF
/5foHL/KnGEi9Y0/a3zd/kkU6RJ0GOSKQFEU6SfNPQGSAu7SrT7shuprPdHXNurv+Ba4lJo7nBDy
Jg031brbHPAOVDkYVOE22uXPjS0adzMNy4qqctqj0e/ElkbYIaGczLfTQKOUVTxghkd0dlzYdGLM
ZfO8ITDjUx2UaK/dlJPi05XugItDL/gYyhj9ESze4gmyHCHafIOc49QXKqSEQyaVj484pkDruUec
uQJ9fzWT0z6WRzQAD0oOopL0Bq5NWYcxFmwoxxUUhjlB/BxrthB5k+jp5XdiL7DQXg+Q70cGoGbt
wQIgHlHC4N5rrpdZD98iNopshYlItDl9LlEgUVtnaBt+QAaEQlnztjreX8+E1E04VjiZIZahyNc6
aNnVIeKf7ymgH6LDsrGaJ8PlL/QHbBl8yNBx8ZNMhaRwQl0KXEX1uDt0EomiSu81N7LzwJSVWvCJ
mRPKydcLquzEpSVIOaS9x1/bNjIz4x2MKMe1sCJEekmLA/XWUIBhcoGCQVYnCjiPLSttzry9qTR9
sDzGw9tXD67//YRXsFRUNPpGqbvgFPo7z5TF2SvYdtsbEAZH3CfT7zYK5gQrY78Li5870Q788GkT
C5/Bm21mIh2gVEU4OeEEMWrsbv6rSRdmzU5KKg74tL0aXIdWF1sBRY8thgWo6Y6ErQ8Zv6EDl8qz
0pzCKRz6adNT2xFjoV93NMWdZYcUGUCYJQeE9AgWaZJ5wgjWVENCjRq6wQWZ9QrPRMXeDeE9ZOF2
nNFmVfrsiWR6nedBGNMxnWaJl2TRZy65BT2hODLP6Unx7YplOhO/lbbGRlXHPPR9dE2jqBzJG/1x
HorpKbTy95QUaovNZm7oSpQqlyWNZ6/kqgwX7XMfDtf/phb9mIxETbxNmmywDJSuW3mT5vmc48Mj
Rtuk2/Nj5Jj6h13XJ6P0NcLKAb0iAU/WnDocHQNMyL6nboSFa+0/IbcP8fI+M4nyK9WAp3DcjR3s
IzakLUPkaps9Efuvfp+gCAIZA8GcSTMruLUQuhVY/6mgGvB6L7Tfs6vZ4HBBnZg87EekAlqm8zCy
9oEMbWaYprBOqz+RoizP2AzaOyi2fDac+7CgkbP9N1y3NlEBFgUSpG0aElxCDrnL46yJejhIbwOL
x0FqtaHV+cUIOC3/ykeUdvrwDSyodLZqPNlGVAWgLuDj9UDAWoy06zbgOQWQBAR2M4IEbIBZNFEy
Wz/6jpu1UaBMhA339ZxmT7ebP62jECeiwqYasP5eHNLtzGHaYTL8+oraYEODvHOZw2C+X4qRRL15
c2vhU9A6vWDY4Cf04RcEQBN8wVSlU/ELkkZD9cBYplnOXBz29GOl8WlOjLmKK8mJZcSYqnuaGk65
k3RCD0qucToj9z8NL2/7FH6HFhVDVv+SvtRj1q9STq1vL+9Hve7dNotaQuW8pO6YfDYi0+3T2MFi
6IYow/ZEfFL8qpoF70T1aJjMJcTfiTL6458defur3igy08HkJdFlzIsaFyLIcLTtMOcpCntM6f8l
28H19jukcLMnFuIrQT3WjW1C2jtt+HUJgeR/iPwNZ2WjZnSnJIzCB78YMHXFpd9e968W1rudqvfz
azIeDUN5j8j2fcdfpqlULwdDjYonKw6/u0oym+gOaf6y/Szdny3hXntW7WwAJuKERNLW1B+oYS3D
cKrbsrH/xrWrFlqP4+gvsd//6//Yzy0XN7vxj7dCv822DeMoGCPZJvTfx9S9fsmqvwgkGh3vm0Rw
6ojMrq43B/0/E9bmGTU9L5hJH6RV7e2bB0EgTnrr+dhI0pLhq2dTm0At6zQ4PJlG54OFZy0QNtpi
+fCMjycswkW4uRQK1E1nHWAlxMhp4i2b3Ea407ygRdVE4L0N5OzqOJH4G/LOUriokrRTaTe9FIQ0
+myrjON3486Pw+/SxSqSSf6SjERi6v4ZLV1hLUoR8F2Th0zE+q1tk/RjYV0lZheqcIbx1RIXvIMR
xsPzCUe7oZTFmPtpo00TpWkQ4AUy8A4fLn5ZwS/gQloMQbKKTutBitLJClzLWV3ZYFd0SUEzY8GY
Pk0O3ejPQCpeFyB28d0gC0HjfDPeI5SqvGF8b9Hc5kuCzAOX9OXfPcnHCYleskCjGdta1ggsoxyA
dn4jH14a+baWmPF5NqO2IZvNutC3otOGWP3w/GJ6HG9cVwldUy7JHtRlpYVtY9BwgFbbtODFf/RZ
ukDN0xB8YBGwitgM2r5f6TF43qTtmLq8RvFjXKnezPOXg1Vv1uF9/ZYhzV3AfPxgwsIiEsf0yhNP
a9jK2v1E+E6o3rnATYiNdq1+Fv6LBF8TS4aCRj8qM84dRkUZzdTJb3ksietOsRqkBBG0GbCOpAKK
+xBLjDO6VTbp5XOcLQvTWe1OJYlxVIoeKT1RYdGP0iC5YpeaT81UE4+jcTfq5NAx4KeWY35bLIPY
c1eSy6x7sfBz/wFknfweDiZjYumRYCWDQUVC+5D2ylUnkSoVClyeJURdEtjRZdD0/NaKPDU/WEAH
BJ2id8C9TCdYpbneSJ8w8sjo8CJb7u12KHrck2byEB3rq9bbq62IY2eqYf1XtzPNXoREUl++UfX6
hz4EDO1Da1GxDYm89eMkJnQlS1tJZtPt5eka8S2k5AJ99DoVw62vZHf6WiWps7qXqNII+wPSqxBl
d64/qmliPsmDU5ycy0ZYS6h2Plep5QV2EEU+DkDutX1aYkaRWoma0dCkM1/lQNi2upER2qmIP9aY
JxILKUixt7DetwgIK1+hFoivdtjMApN+XAO+VBRi14P+3U+rrviF5oOfZcdf/CtAL6sfY5HF89tO
JfFLjGBpwT36/oJ83Xs/yXGuvu9wWHZl53Tt/bP8IRG8h2tGW9YVm0sAUlcJoIssYBxMerhB1/pL
Q9LAdNZ33oXWNXhQbXMETAyn3IMLlMHj7L8iA/kNWVLqUHqDiY+VcWieTw7mb/dyteecerNHS+YF
70ctjOPK2kK+j6ZkeAzsEpXUYmNC18imh79DaTQeBuR5TqT9E/yHZsjhrQtqz08rU4HJHeI4FOBF
GCXCqXAhVaH9CLnsuD/wxviAeLvpT9fT7J8yS+H4Jonx/8tb4a+ZJtBs834Q1U4rJWUBqd1A42eD
/v02RZGSzgyg8bfX5gmrLRBHL547g0J1ZoQAkG4/UPiHeomoNtXS/GYmO5ii1RXAPy3SVF+Tvc4Z
ciqsBIpmvxsSJNZGsjcussI3zLtmLMnIDujVaMISvJUgy1w4r1vKdxXst3/chTINgSQiJug4+XL+
Xpf9JGthLB+uBheX/82YuE+kHAnn7peSUGKpXRrxrB5RyRLx5YfA98kshjXQ7Rg8m+UIJf0gH9hY
kUubkgOG/FV53CSzfyGLt0/f4o1xigNcFB8l8gF+5nyIfpmABN15YHojafnhjMaXNYcxB8sK4n/g
vZxuJ1nn99+Iy6sKD64QsST0c7hKwcaq/Zy0nmoSWe+hRnJagjIYdBa2xrAsdl7APHZb4KvA4yEY
WAzcOrhCdZ3sGAxSxw6xB3dVPMeFRu8QIeRfaxpfyxxR5hHZAFnqzqxUjF3eKiINDCCGrx8eH9zM
iAdLziNCoLc6O8E8rzQ3IdVCI1L3DHRbCPQl2579Lr+awQpjl1PTBf5VgtVFYDSB5O03wjnOemRJ
MlkwAt3y2thOxc+7p6cQEr70BgDBJED3CDJNI9a6bvXv8yteGY91TjXiSScXDbxMUUIp+M7xiinH
XZ/5tDsswsmmIZu7fMWnqqwmWBnUKv8Os4zkiP2grR8s2xR7BFIHXiBE8RYaWmquhmdzYCbWi3ec
O2oUmr+AHEkp2qjAf7Mb0BJhXMJmR26Y9n9iBMZe0qW6UwgxSLHm2M/p9Z8xGovYa+94EaGMs5uu
IX3LsEJK2cdUE9LFfCH9b/8ZDPsnhXWmsau2SorHVSeUhuqOOBweHByUpmOKikRTN2AZe0QiC/AE
pBRKIET3pVBLPDFjHkADCK9pjaBm8ac8P2tKyLHhg/OYFIuLZDmMcxqZU903yZWvE3KFVF0p3thd
A/rlJZOCJF/8rMf5OjtuQEi/GMzGS2xUZihgYMbeyYIOi9J4JlOmchj8btHFXq7KIh52fFkjkNxC
YdiUcsyVCHirUeTCW8IAqcc70MRTSL3xr2LKW2An/fgpgrsNSwjihKHq/FA2UNe6PsWLp6qCyvya
05ouYk4CqvIgCo18yBQaiIE2fpoRynf2ce2jU+NViRMusZQJjIArELPOEn4PWvjm2YnccwroiQ6y
VTi+lw4BUjzef27EEsxSI9A+ISHoo86EsAl3Bh+R8GCUDIp/qXGFXzZU51UPuV76tZgnteJVZfEo
Xyjo4qqs0OLW1Yl7wLTCuC36UFIL5ja5Vr2ka6XJhP/BQmEwp4E8193f0qiwWBiDVw2bnmcOfkgo
1B2btaKlmAfwCyzGNVMU1QOXSytTfmLYmnerCiDTf+PIKmFOczSQ+inztqUTehpw+NGnZsykyhqJ
ZjmM+9tB3wKRl5Vc2rysQj20bkLGRSbgGGbJ2SvVLkYD5/ACeKOEJ2aENWfBZPqOqwUg5v8MHPwP
Zfn1qtPKqUEg+f3WSoq+wtELHYn6jhCMknrD4q9x8j4qupiuPyz0zWQj+O1a8vurqpaeV5aSUh23
94NInwNOowIHzA0S2HIwfRmhRZveJmzC8RByXMN/p0xPTdceXaTwfhqCp9jHk9eeKuX+XbiYp+E8
3Yq617Zt2KZCXR+yEn+06sye427KIpXjOMYRXVv9XiQd0XOPRIBOMF8W68PNbW1K78pkk3Hbd3Tp
ESgOajX+5UzwvuQWufXymnzNACEGLXbRpDO9HEC9bKijGzRh4LelP3HO/CE+WmpQ5Ojp1BoJDWfp
v9vR0jJpN7ouI6PYOHvpaDkPeG3ndVnWHwPYwk3dBPxBLQQhraHRMasvf+u0nY6+Pm+TcqyK3Wbo
2vTBcJNfJ6HOMyF32tzOtqVK2HZrbWTfSPLKA97gAcbQDr0k3iZnTuO3ghEU0LRpI21HLMCUD5CM
/RWi8z8KRGCzpxNMhjT7wqvOqQVE124lLPTWfB3FK3bOcV85Bbd4lJvm+YkZLTVyYvYz/nNHSXjk
VnZCcWod01nB4kPH4KxFHvSM1ncTY4JNK9tWyFhF4l7qN+m+zTFXU5EcrraLvuBO8OQBe66+FYEv
e3GaOzMGD0CSuMaXu1i5RI/39lLkrj8EXJbuRLWuTDis665mzNa9K93Kea4HilDFszWWd6lPaf+1
R6K7chQ3Plcvr84ZhpUI28GJXeMnEXSe1nTCwmP9eGpIeOccPy57jgBHPuTy7fhJYW62cPwwv9um
Nfgft4Lw5IKCBuu0+4T/2mELdx/wZAp+6i8Mh39dq86FdvrD8cTGEgzUUD8wUplqqhUSNi9MmoD/
+S8ZEUNE18pJaGDAyhXuIhX1QN+EaO9OxFQ59ve8AYdfGvHqhLgEEKyEaiHwi5KtahDi+/CEKrlW
Spo/88jqhrxHmcJvQYMyVOnJgi31G6PYhA2YJ/2aqeNTo7wDN6y2msGuzyF1EuNOBR/nd3XEfoKb
Hj0wkkaF+1PuESnxLWosUF+XAqHC2Ou2xer+0Lm10l55sfzCuCcnLjxhm7RktqsbbGvlJLHv6X8p
yiByOe/ITGcQqgyflwc4nWExWwVFtoy7kmiTzfa7KYQYDJsbZwqRou7Es9LsAlcjikSWZhiayBdF
VaxbpZ2h5/MshIyqo6oBKhy79uDz1eWjbNQuWAzlRwg/btCMsc0UvTEOIqVlJVsH31B9bfzy7525
zgkIcjjfjAj2pf/pxhr9iEmVbizIdY+55MsydroBo2/Le8IyjGnhs7N2GqTNmTFPDgc4eE3erI7M
wry2721xwwfH4v7YmFAP5yZlEsqkr5TsNK8LLJZproAhkZofyyIglBWG5V+G+Ixi+TXWGKQnpgBo
emA2GJKzxqcBposOlhF7+cUU5B6STUgF/YZxEJCx47tqSKDFO9YEciizN37r+1S+FjoFb+S9qGEw
CkBR7vQmyRjmOqewA3ed+Ruy6twRG1/nEGwS9PAELQ4I3he62GhHB7du4Bcar6hcbPzYzeB3W+0m
P/3VPyyaGsAaIDXwzFZ1iNEY3UKbrLHKhG9oCuBpU0EXzpfCCVE5g6PTa6em/MtkaNT2H30nB9I4
uAazaUzcD7CXAFdCHqJaXrNzrWQOB8z6ojbi2bh6HJfBwKWqKASCn9Drg1n35qegcNUZaEleTugg
pOvE7QY0pDEHQpA/a5ibZSJrJ5Uj7RBAXO3f8gAraAvYF8K5YbVvrvy/DeQAP/vNQToV0AEdd8TP
jNdmRUjV129skowSsX9Tud0zn+uN1W12bHQkrX/cNkaiYfhr2npmlFWFLFqfOSuEXy5wH6OUmn16
cjWFVj9XHMis26fbcTnBHZ4AsTp7oJUYIqCOn3EhpfHqng8nPapre7xRDE7lKs5jcnnO6r1aTc1K
VIq2qWrmSV2izZRJOTKGSuKiyxB8Czppx12RV7PyYmMqJn+jjFVg5S3GuqlVEcQOED6z2ylktsL4
FMCkvPPjX6AouvR3VbQA2fjEakf2xSVxlOPfQPVRTQ23AsceACMEehnbEqV14OnVAaQ7k+VpRmoj
1BvEEFSPsdxHT3QWEJ4uL1WwnJHW6txx6j2DnFMYKwoS2GOhs4iFxz3FV1SdLd+KAZBfsmnNjlGx
C0QmMvLtlgSr48TAQpSWhcmZ/oxkaNvInTnzg5nE7AD5BwvwzD/1VngARAbIYABEgipJd8dlaznn
nWHKMI2SZIOz0jvKYPWjM5J50ML9/n22kZ/3q+UKXSICztsVvhftWVX8S2V8zkvIacc6xkVCICBh
sXPsxCB11K74Mb/KLnEIOQuZWPKjPDRZC6BsBlpgYShhFGKFBCi36FrUkVdbXqUhIK5/2EyvmDPj
oj6XZqV5wRQYLf2uKES2uONDCg06rrGukD5ju3MI/Ed23wWYkbhcQ9LApSWJ9ZfjGFdz2xzHFUAK
IaDcxlsjj9b8+Owm7nIxDgryq4C3rAMSK4ZseQBhni4X7WizYcT+JdNl1DrsSpW3+guI976xQ9Oh
VTAF3Tn3cA/xBq3Q0GYhH16uW9OKwG4Mz2ntqBzHlosIKH7BQNgzaApJc2fJLgjXPbNLf08eoWxC
x2cfPiJL9vBm+THUt1cXbwJB29y2CKoyKqWqiaruHQXFLaJC/ZRd8PCtpMLvFhmXOROuj+++va7N
+ItZBcL3BMulsl4/XGM+REJsyfzbl9hoWTH6mcl7V128k4aJIpYSQ5CweZnT2qxaMzAvdJfJlGEe
HpNVIJ7lj8Nrxu3iW3Z3/47wvuIlstMQZRELfQVtAmlKDbwzTHjNxIZ6k6cYNjy3kgu8Sp0fWLwq
W76SDwbWEj+TnSUiB2xKuCMe1KyYBtx7sNv6+fl8KZ65tzhFwcAoRm65YfhE3y+j/gVOLXoo6oJv
9N/CCrgieTz4Pz8vuE/2SdGTAN62fzsVPQC4/Sri5eS2O2J2Qwl4NeQHOGiNZwfZvgwj4yR06qya
6ZUz2wQYKc73d3OyBBu+PGATy8cfcRUpGnnJECtmAFI0hb6zF/UGVj8VkVc6B5zU4zrbTn3hraCl
RE0OEGz2xML3f7xZYKTYI6ZraAzonQURuW5sxLGzA3tv5SZ33z2weevXSB7RXY0teutwDnTvLyDg
vTSb91ekBlLZc1v4WIPKrTlbOOAhhjx4F7HnzDQMV2hwJ+oSHUbATUS2twjXsVMn0M/B9gUXkmIf
ezr08zHlsRsm4P9DdwgWM1ZuktgwiiLZz2yqGO+N0awFnft5kYkr84XPX4RT2Ct9a7uCard/DtH4
fvCGpmR+XOqVL4dQyMqxUwz6jaR+SsKMfIHyKtnd6D1uAJETTdl+r85xZjz5Ed3R3FlTBsjzW5S0
Q9T05lhojuB2unvht1cLwaSmJJ8nx2639By+JS6cQ8WQzP3qft0rdgSilW55bKE5y6CfJLoxn1+D
aITKEm/RBPUaRpCB5QFJ/bWbfXVHaK+LUk22yDktdak4uXrKm1CG0r5cfUcFqq6moNZfvGD2QXBO
IC2mHgPo998fHqcqYigcpFySZr5ql9lHs7zgmygwTc5MzkOCAxbQS3cB1r8miJVN5VABCqJpSUQE
fh9emzV4djvwPJt0AOu2ZMyEKsn8ikfr9NMDeCnDIKuoVwLXCy/WrhaWLmgh8TPDq36L8hXT6K0l
N7ndHqHc/bMKbW4JpwR+3rm0vzGPzYpcuEG1L1xYApD/1ubTWxPBZQJxD1wpbzY8GOtKZlbK5sP7
fzrV55Hfsb3c4L8zvXBgihyjR+A85S2AHaTrocfJWZn9DHvyEvu9jK/3tq8AvmKRR3rjam6GRmdP
QJ2Dckye3u11Iet8rU6/AcscqByZsY8kCFQEEw6wTs0/2wROb9hf5bDNvblbJbniw+3wChaqBwmN
IMZWqU4HQQLP2EGalFX7Xj0EeM1zBQNGU4IjpEhjBZPcXsuXWAKkUprETdB8Yc3P9st1vNzji3W5
XTHvSBJXGs3qFevSxAhITx2y3eTdT6tKj+/9IvsxUuW2cEPanixjPcBKRszrZy3ttOXz+Rl7lKE3
v4GrN+ufem6IfDXkKWfwohgD3b6G7KKB43lDTPVP/pD/9T1ZKtJBMcGrr2XhLkDp+WQv9PSpwNOd
Qx7PzEsjYsuAgjLH0akC9GLWY10z4adXwjN7JAGY9ICZ3I8Nt3VK0jk5U67bRmoLn3tvgS1sxTJR
NLn3Maz8uLcHY+WQ/vM8eK2HTJmpvD/t9xDcSnbdtgbafxsmCquaL+41grPGfDLXIk/QVpeYG5gf
4RFSuICKsOtK73kTrkeKjmy682UFrry9fWh8+Xt6N+YEGLxJQ13SF9ILcplWjcOHco+Iyzm64W48
iX4DpX/Dx/oE/2fuDSHb4izuygAl8C6I9aS8XWkVnU3VcFFICD3amSPwwqaivaUbyQULGR0Jpg5i
x6Ty784s/io+7JLibsZuzAGhjUZmGfQ10r8lm5RuF5Huz6r4DayH9a+17B9o2Nfg999yR0pvCZ06
7WPuz9f0H6gEKaRbrYbm3kQ4YhKtpCnHHABZOpoR2pc5pzcIMRjIbm3aFNLcBcX/6XCnGudZpy9Q
S8WjDvxwu/nFntwN5sFMa63rKPxG9tvCMFdFnH1bQG3spbh1oBMldV3ZuMcJ860tNP6uiRM9r+2d
XGyzhn39mKt+5AJG0WLqzSUJlVaKXYdgGBTvcM55VXUSDYrdoZkAYj2Z9WU0u7W63M4FRiZRxK8c
I0O5Vvvnt9vH1bDxSTOikRTAAybozK4Vfqa5gaFJwXrWYG1m5x+6Yx0KB0QqiToWR2UMdH/RoirR
ONKsc4ytdGlNgmtTXNFw97Lxu/1sudOXuHhPnXo2LxwQDgxaOYLXzyV3cwGyxBLTm+1N/F95g8uB
+qacuAhkJZnZbPUZrcPOXt50DgDd50eZLrdyzxQCYw44Bqxci+Q0cR7+Iol0Vh+eFxMzqGVIZyBY
MLvmHpHqMP27rSqZxdyKYnGkBe8g9FbSOE7xHo4rV3z0JvmVlG7cCsPXqx+qOLL8yz81CFFJCWU0
GkL/O94RfHOCPstNU31ywAdt4jAIVACDJUY/Ag7xfX/t6f40DMPlr9GgARy2pzV5aSoBGbAOJYyo
uRJZdyNeWnaWGska9rVJw4hhuMnYA2VOaVuwOTKoKXgpSWlkf+J+Yn5uAxPH0k7puMDaNJjKZFr7
o4Y6Sj5p8VdSUrscTYWNSExR5Dwvu0e+gmRHIM3LoHQTCgtDLG0hjbhwComexqfPe/oaGzA3EeoM
mIWmDetTkujdBNQMbswkLppIxwvsteQVkJPoYVClFMhADmAR/MT1W9M+RlU7OA/GGiFi+PnrQkQ9
P7+eWBarQj0j2ifzeqTClI1NrCJ2zDtcqCPo68a/UbWOKVDF0MTgNbclEMUgPZDV1UEkzOWeR3Zx
Ib+AZFe5/d1tUqbK6M7Ff5QKdUOcg70WPL6l8BNkqIKFZkN0oSdaYFmRrySCzQ4knMkCSWsYfhHb
USzqwAksojngjWE9k9+k/UN+9zzlfZrNmokexQCp5My7DeZ2DYN+z0O49tabQ/UGXz9JtN5IUdJ3
5/8YxLvM6RWCP38kW3nZwvNxXeURB5/7mVGLW8cJRrPjz9HPblh39J7+2KvFgHmt5zxw26Mvmrwa
1KlndVl0I4AWI4lfGvHFI/QzCEAs1w11JpAdrtnFaBVpMU3eoAUWivJNuT53CdlDZag3BJF79Ujr
zUX7ZRsnue4s1H/xNVGnMoK0UeRNa+EZxMmMsb0LKhqYaWpaWeEuM54oPdBx3ualoq1mtN9RbZKR
oShKN7xXsn9qapRTcWrmR1hYFxCr3mZxHmrFY+lFwSdx4fR6Ze0tI9m1lfR2u3A0klxdFxBxlkSr
QvsnDkRGhBv3lTWlmNl7tOkM16wIRtmC9aJX2Uv6yi67RlEPYZnZcQEqGt5EhO7faBep2rhkAvWR
TYfbWxpduC6JT5eOzXoFnQ5LJuPp+hVGt49+LBgKxsWc/NmSm6rU9XfsYw8R4muthw5b7pRNqFfn
+CXjVz0kmw+xqoYoVqrtgq0FesN5Bigm/Hzulz3wwaG1h4lA/sH2//6kZXPBhP1EsezV71dCEMVq
dDfkn5hlNI5hsTvhFxrj3rCuMG32Swq5KUNY2kCjVfXjEswJRTlggTCePuQjvdSM/HZJ0h/tJSp+
Qk8ZGEQMZMgXzY2NtyEC/soEOozyThJ4F1Z940xFbjOFEyP4yjM0OXQ741RjZfKF7ozsld1DCNRu
AlyuzY5hT9Nd+TyjbnRFMKXWw97TUw3V5GZKoJiEUM7h7v+lGhjBe/UuyDYOKok6yCLd7piZOvE9
cBZf/FK2rrcCDwCN+pBFHN/bGHyY0/vRfSzPEDPAEGla43rAz5EzAXEhD3/XF8/qrdr5mAu64oeG
SFxvOXsmD21ubZGxWx1Ssd/N6n0TS0cQHfCS65DjnIkAQNR9+/cdiiacn0yxzZoLuZh4CLhrPZeT
USHXPwZEOEI3Z+amEnr7CK7H0b4vU3vynQdqz4JK7wGNJ771ed5lRZA/ornUDAgP+9SDAfIDMLVd
OuL4+MWia0IWVEDcvdDk/FmceLCg8E5R21D6cYsqRPZGFfkIKHDSoQntspbtLMzhdcGCzK6hqA7u
N8aFxked2SpG/wcIkjA03TaPh8EN4jYBeevfxmkHwbgo9CX6eXKkZwR6PhVuVeN6l4+VJIXacJ0N
KQzUr9/Q/KCw4PUor+2NmGmmS5gFEMGDI1dMYjgplIZvmR6WpCb1u4gNrIy22Tzu8KuGjXMXflYH
YreDFnDnHvYAtBjnIB/YRzMgJsTJYI7oRnVh+r3ay8ppE55Cm26ApFDxEXmmbREvpuUMJ9Fwu9wM
jTK0WCn46xVAKNocvzEOUuAQ9cahqqRPBPgcwRfHGY4wQOtxMWlESKMpK7OATLhsmrqLCIstM+lw
LuFF9g6YNaFW7TcSicZkETxEwUishcnZBP9p4c9d7EkUu9tfSFooFBcV+YAyKZmnc2Ck0DmU2wxK
WVIjtYwJX79TaGff68a59qxhqEHdnWmvmdXMBRYa9BYHalkfU4efZcNdjo8RhdcOgOXOvMOyKU68
sW8/W4j+mudBcFmG/YPBIUaqRpkHDrMb3o5xzOKvVR+e/Np0hDgS9q9CrJSU2jK7nxkwzaIESIuo
iSDJx48svXUD5QHDlIr0vbb5y+nW9nkVBWw0p274jnleUlxYw8/4cxfIVL8NY0tjNcgUDgTc3hXG
OtvCtZu5bUTBVekCfLx/iKi8+INvMktZyyz2MytD/XZPjyTUG9BK2L7LzMWvTjFK1LB8Pk7SfUqn
ebmOYYtNbq6qGuFP43mMA83lbP2FWCC++jvTgZbrTWMLWUCKYusMVq9vCFdlTQ37ABCKEangRMh7
EoOo4vGRVKEHChB+hzjnZiB16kQQrgrcjIIU65h47l1Ih3gFeQo5RzwAOiCFBJoafqZKbkECn5My
hdlTKP4QUvcg6f94Fw5pDBstbw5Bc3yM6x67M3G2iGWzDfIXl9U/ylDgX5ybUercAAb6OLN2EJbR
uPrwWL0PB1qG42XwYf4H4DAw+SSCeZFpwf/g+42YZVUQVubXp6izHGyi3x5Pv/Qk4Z6v6FG/FNp+
r2i24bOCjeHbDADK7pUl0yA6D3cmnSHFIKvaQNBkIAGcttenwSdxo3k5YsrY6sKeOSV1GCwPEv67
VXl9pVmpJb81HERORs9N1+4QiLcAgbyxXPiNZbV7UFWML3LxIYdjmqQ/Om0IsjM+88Mso3cpDg+m
fuZ4gnCrQLEvQEphXhahghEd6k15vZ0wOMkJAcT3YDxSckccO0TCe5grmpNoMOTq13MxbqIMPfdR
UFiJwmwfGYoTZOJZ0aQdag2CWu6c+dtztsYkjaoMkLLre2yyfLjA4gwtllOE2xJ1v0asU2RHsBhG
wIGntv7HkQKszDj7hA/pDAh9z8x1V5jGOQqWn3yDqMegSIil474Pd+C4Ahy1PJU2ZDo5CG7fJigJ
AajNvKkjjCoFE8RSuT8Kp45u7ApOEckeKkQZeeu793D2+AQ18qyQzX6TL62r202G5PawPPdv4WUo
8T2/yHV3VVxBSkgShL27QhxVTRemKHPWZwL7t+KoO9Fq38p/6PW7xCgDoB04y16XjrXC29RUSAWs
ycEVRL4o1fZQHrhzLsi9Q+fG/hVScilJ8FI53Lxs9tWvfE+LgLLEBv6vszWJ7HYORph0hAJBhUPn
RmWbLDaa+ZwyC61c/MeTIBdaTwO/8wHgxy/mTduT2rYx/jcwwVLijSACeXdkoMA1+jrNm3RVcrkR
3TQ7rKbYjzU1lywLduHIrU0jiZ2dfWBwoVRyZkjJYX1LVsgUxQqDTPZQ9vo23AxUPkdugYtNBoWT
5qAh6AGjAv7czZqZAwEJC8E5ob3MOXlGB7rG77laW1AOFXjvEV0+INilSNUzGdDxkxtNlAVEOzRQ
uYdXZkpzYEezBmnxq/tJefELwnKXDATsSxn7nySboRnBbFOVcC8EuDTnPIIr3NPPSRmWbxwxLVlP
M8xXao1reBwYp3Kk9zqY5EMfJo0MbcKt/kcDBWaYZUcLGeQOnHqkMGDS0GhWdanvqFs8b8iXgjEA
n+Cn6rxH/t4YrV0CsPdiZqqgHR3rfRGFUjMNc7mRhGGu2JnzrXgZKwbDUMoW0ZJ60MvXICsQRbQ5
mk1CWU5EeR++20Lz1PEmBy2Zi7g1mP1qDJz2SWp+FbOETAq+QeftnmOkuefsbuudS5upQLBTXREj
oKHqIFRquV32Y128a3yQgFElmaFbUdfdDTaTHEhxsdOiTyQRnB6nK0ExtDtAZzSo3E/jFNHqzVei
J2wC9XeeWvq9f26fu9refPGX1REJfo6iE71DstWYDg/mLLd4KC5kHMo4tYmn7wnD8xUJisbFPHt8
RxTljtLPYZ8iAvyv27ZfK8JZ2b/QDC4NkdI5TKAvc82bBAJskLwOrYvrXCgzhYrdss6sKTOF+eRF
UyaBzergKUHVTSf6uWPrk4as6VUlTOHjcjgoU7cuifuH1ieAS9xx6Uy3cEibtqE3lfceiZinq+bH
PaJfRO9JJMpFyD5GZs7gzc1Cw23dGn1CgZM1s1X3M4MTk5lph9id6qKTs9PqZqtwvzVfWvYZnEeW
ezPB4CWkEqIqrc3GqaomQvC154M26giUYwT6QrzgbBpuI4HdLqwd4YWookUQGegNMTgqk0TJEm1e
tABC4h9uVrkP0GOdEYwO6+LxM/BwVfQBfW5F3FdKtWM2g4iBzCv3iWapGi5GxmFYrmRS9/z3Lzkt
scxcmsRFFdJdBormIm1wCMvyVcx1uDDxrH0GQ+jPo08izLa89k1Fph6jmbGgPyCtPS5m2oF8vjYc
HhCipNSNQikEP9C6xPSeNSAi6gevZuI78jWgPihyiQUXl1Jjb2BdKYabV8n34kFBpgl7eBrICjOM
wnBLrbOKeyHfkuuvlR1+JLAr0eAW++i27jvLksrY90qo88L/gX8votUSkYUIn82DVWD9golanGZ2
1kCqgCSicIF6mjLzxqpmttKZSFGXf9/RCEKMpoYkZzY3ys0eDGwpp4PFuM9mViNfsKaqxFQuw7gt
al9JuNu4ZwyWVPS+MOBJl/j1U6moOZtsIA3N39CQzw8pwxJBmtIxJYYgQ4igkUuaqTQt4t54j6HX
fR1ThslfTb3s4ACbi6bQsurue8U6gHGKnEZuQVREs+QACN4N3b5N5js9GYGmMcWPnKwlEEiyEUOQ
9VtebIiBGv4p1FF/KUTHuVwIZXVQpBx2noLhYaleRW/H95lbQW9mCi7h/VRJ02EPwDqxY6bKq68m
ONOaP2E25RRtRM3wuXtKKmORSdBQ6cZ/vG62HZeGHLZL/EqYLN5WynWVWCPgkCURNDOjtQGKnSvV
237Wq8ESREG+5rGeix2k5t1ulMpn8yG8oq5+pPk+k5esAvgoIZqdG5FOgEf3ahFtbmom5zbZRKbk
eggOONumZifew1JgChuec095hMrK8FyeNW3atuyeMAzKihVgzUATo7hnofsKfeBjUKTB+sxLBlgG
g8jIFQsbZQqOdXCr5sSvJ0EpPpSM6CUlPrRPEJbMBr3WDgf4HFIYRPfiVlZWy6+ex8luxLD04ogn
sdhE3nKLgRRzekUQ4OlcwPugPfvqps73J7sIPpwIeK3CRNjRR3RiGVo3Zo4vl4f7eHEtOOufyXYF
yGEwKh8PFM3kwLAWVQHJZ2IUgTmM1BCQ8+bgx+PDX8Keqno8P5hn2lEozPR/fBwihpRnWoj8NsJH
R6x6BWlG7+Dm0BbXFZyxLUhrOqccs52nfvcyWjKULntVCUapFB+Y3UQEE/uS81XYzx5sojItdsuh
YsICujnoQCG8AzjW680uj/N0An2BbWumyWbY+cYd8g9/mkcVxWRxjtkA9qGmw1jWcm53WiRS6V47
vlQAymDxArF8DpQo7Rdu99HaEfk2VMfhDzm8ENgKwiwhh9hcbcRwdOPSxlgVqy1xlpJumwZHNdsL
wPPe0UtlbHTNzSVuXGGxb+eeh6Q3B3Ym0Us8pANvY+24AV4J2SW6Sa1jQ7AU4iFx8l9jEfyF570x
oWkXzQV7WfG1Ntryiwgl77TyS1v+MiSmTRydxJc3LonMXR+DmmL7I+pXIodfVZvhRTJg4z4xGQ7J
B/bsG7TkPyr5gO+0SZv1EOY8DadYdEkpP5iyTnOnwKRsJgUFDJ/2mreqYpUYi4O2Vj3VVooMzKqt
2HyUJmO/UwC4UaI2nicTIdOL8/FAHwEo0J+zK0avSrhQWOmC245zCFE5T5TdfrUAnazK0g62rony
QgcoSLY0OsVDlbP9I4zpKDe9wH2wc7QKmmwZL2w8dYymVWgvFNA9O3sTn5qmDlbLBmwpaCsdkvM9
H+BWOFhpxs7p+6iUsg8wRUeRlVsAd3Hiwl/CHjHfcVjB35eZNieQr2Bbb21FL2Rff5icbqIamf/H
j0uouvm6aaUEaPQ3JxtcQsLacqknlOuUaWAkqlP8/Q9QGPe9to8dR8jUVT95lZIFr2+qZkZbLMEi
70037n3R+S4Gf/dXdJBsK6/0dhMIC1G09ABIfF9XK3w5j5uRkNk/MC1LYdc0uQDOTuYfqeVwjvFg
R9P84MghPw6d1NDcaD3B/u+MG08oCnpQc957WkvTZjRXJCwclqT/LWO+AlrySamd0IVL7OmVfiuq
ENEo/Gjz8KYX2JZSsDDdqN/nMLNFEH0mobhrTzSX/gm8QCzQRvn9rfYcfuUq8Tq96aS1hpgL+qT5
k9a8pfxty0ey9bsr77ix6dn3jBhlbNdKc9NH50TvFLDIlYXiGWa7jxHLtu4oxWJfmpjaNVTd4d/7
F998kY/hpRXjyh4h0ssYrc9jROhAf78JZhs1p0j7WwOm90JirFdHgbvxWrJlqhFcYING93ypa/9Q
WEvb8PeQjoKJ+1I7WqOY/iT27FKXR47zjP65BE6wQH/hP0NIaM0KmYBccZbg8wiFhdsAzHaV2DmP
VrgG5+eHBR1zniJUQkMktqBCdipzIta6IAGWeM1a0JiaSMVeaiy04VSTjo5ExYHDWQ0QgVBYefU5
RX3jfM4lBsLTsvI1vBo/xq0fJfP3Nrf4pp7zQHopql1vBybrDaGr2jH4OoAIG8cXlkmRBo06HFDP
QxUX9d0xF7rm1DQmB2JCHH5/rK35B+wcm1XXoF4njn69B3ZigzWRzC0v0aOWYKiLigtFGlYJnTbP
AEI+eoyBfH2T0q2MyB0COAwFC/yFMaI7RFd5GaWgMAzQSUAW26vLk7jBjQw+DdfJKHfoTeQW4wLx
1WPp5XndFyTTSDjR4XWEOAHJ2nX+it62ubBMP7BlngJHt1IeupLdjScQfYIZIE/Z5vNdXbE+zRuJ
nQQZ59Dj3mUTB7qRQ/WCeQYp4whKZ9VaE6+SfylTtnYuq4W2TS62etFIa+EKmxFTAr1GK1yzgcto
3lzU6pkYQYfeCe5o4aEkZQGBC9KzqBe6o0bRGgoMG+kKIyCZjnCzRFZ56I5JNqAI5tAwlmBnsliK
97mrAX9vSJshvlr7TeXaPCATbTOypaUxRJQ1FIOf5hcI4I+OaUCx9DtT5UGLt0NMRlwemqAf9wHT
IPEzZDzMcxVXsSDFD7ztgXs3GhcHtXKJEs2KzWpdyieved67QD69L94oE8SYf32baR9saWn1y5ZB
6lMV5eELPh9ZnTq9VqF6u40mh5XpasKcUsD0FTXISLNOwsS+VkaaFXWA33ZZND9aH5w+KLM+7EQ7
pKygNFVkLR4yi11iFUQyoy4ngQeFb/jYKdswF/j1bMpivwA8NyiWfv+K9P3m5cylvNDYZa5ARlA2
7eHn0czLsmKhIzdEITXpM0/sjMn88syKPpEMk7nbh9+Re46l4L2SwZ1WbJAbd4sXwBb6alLMcIaW
4lvxUSbRTPYDxGlFREM9qI/38MBSeT1J/OWqmqN7aQOWiZqpBO7i2X/eUN/hK5Ur/vqMpB8rxHw+
itKEottH8cMDfzp85ru2ark4BTWtdLbuWd5cL6G9CnC3I8eLMK4qEzjbXDATUip07OtCtebaeHJ7
uJtLCHdixdWIECov/9FVEla0OEAa4aPPggLyKz+kboR+5oac5nYHrIvxwCj+t+Kxx6jI3zE5ijsU
3yPDbj1Kg9+bg+qDqpTE88P88VYFp6OptomcSRwDGxFyXu6QPlKuuUg3cvZKDvUTdqu/RN/mcPbw
fYkBwGdTh58L8a+WuCGPYyZ0eBg7cEnRfUniVjdlqgG/zsLHrZbmgL5u0OixJ/rGrKtBiH2cv3MK
EOgFv+5zNaO4TsBTU25NaxzebU/ZifVB8A0iXoWnXfBpiUmWl/Qy7QW8jdNRjhaXF/n6Za26MlkN
hkS5aBtn+aK9++uJlxZve3V2R0ZDdVAnY8884F/UHQS6az7obu0cSyNbdKn+GQwmsma8l7Mnot1j
ewb+rifdMWFT/HwdNsAmL+fQlUyN3iIHG+8CzUBl7lHn+o60RpIOz/F5WmnISXyWKWQcen07YdEx
6jPhKxOig10Nfn2BueWCHZGGLwCP5AWNrMVbwzBj5ezhU5HRFFH2/ykVzXKm3BozoWRLmn664xOY
lkFdk7/dB9FM6x5lam0FigtuNIyEeuqVa3YiB1PK+wmqBj2ru897v461oNJxfibVJ+SKsDo+zHUN
/FxUqpGHYjZKM9xy1puf2j7esaHPS+Uzmwh7EowYLD/+dlKo16d8Lr3fEHEZG4Raudmh5Nh2SdW9
40f19aXBN+d1J9tZIadcZnvgIN/gxP0sg/HoaPqBFkx+aQclOc9RWwr2oPp5Acs3tGLEBb0uScIe
YClsa6cSJjssgUj2SwZuJNir2kiy/Hv1seRV/VD6g9yZhlk52+jeNJNC4bre015Th3LvnG/IJKO/
pBybDS6KNCjODv5JFdN9WdhbTFIWzbLoTGDr4K7LFiNs4TuzloUBZKU9RL5brv2UFqO12BJpD188
ut73bv9vEvCGcQThYscUMSn2u4bJNJSQDqp4U8taV6qjThlvgOAQgVoowLHwzSPwdxQCJFC0V4SH
uyoOHTHvHd8TH3SwnjIEScilHawEVaCpVf7fUhQAxazxStZOatcZMrhpjONr+OCR0YJ2yVF8v0wk
rkCuahPJ5wBrcrRqfGrHSavqWL4DmpliF3fJjIwGCsoCGTCb/AmjUIVI0vtpFBIOfJjgm4nBqVMc
/BX/Cx0JlAfr9rt1rl0zT6+qsbcuJs9TbdeY2pPmCK21W7UTbGrmZXsr9z1pJuTpre2snSP0IMek
K6r201Sd4X7e4CtbPfDxK2VeaJQlySqpe7EV4B5dfr50nBvFiXJjXwrDn2aVMHU7+6Ulq+Tj0+/H
5bl30hydXcyigKLXlWlKFeptAEuvdDAzlg79oVAX670g1kv7Jz3IGntVv5tZg0jgpzdp4jF1Nw4P
5tZCyziJipiYtHMpZ/Mzx3BLCciTKgfJA1CvnMtzd5Qsdl3wXdvAdKPxgUEGh3bUcZRXHrFGJGYm
9q5o0eLtv2s2CGmIJnZCbcnpg+lnAiDGICRER4+iy4T2OcEiF2rTpQRvRoS6gkQBncefKgn2+6tJ
/pb7ECUykwihjKe0bSmIt2Bd95cyHyv0NaPf2cSlhWtcwx5IapCH8d8okpOM36Mp26IHc842iOuF
54vZ8JnbbiPG3YJKtKijC2w+nmFkG1jyrzVZZR29pjX5TspE2UsyTHzwdIuewmqe1cbGC35Bomp0
4ULkINrz/lNanuJhQwQv1YgRKX8Yvm/b9+TFmPzWXkk3uwRz6Bqb4nN7Ta4NYEJFQZm7gZ2kkMvh
jFuPdBfCUZajAZV9FDevRDDBCsU5TYqtbZL0h0/v7/8cweHXvaEz23P88RTUUhGkvpDfKvgiODmt
izFUD1QpdO+cKJfsGawHAr2i3N2eLrX7WQKo2I1hcdepWUBiSK3Pku2oSMat0aXqosrrkIxgM6zt
vJtjREzuC4oNTMlaimDn/Kq+ckanVb8UuqYjNmCSHMtOBkVJDVqQK+r859D2Ie+ogzuLHj5ReOUf
lf2wBNiorZXY9g6JBTpXUm6B1D7mKnwbpsU7Sl28D0XKaAHj1ZqYrrThDJj1PXn4vwVhKY1qZOV2
FAUU0/1de8ryoQHm0/oxGibpyz4aRlVa/5LzXBu7qmAL8S99ukK2kXINftzaz1Gx8LXv0mCdH/F9
mZ5KgVAdZH5Wx8ejbLM0Iem6cKnB6mKp5HadeLoXhONFnX9Etx36VGCFUYEdVghK8DmS4n5me5oe
z+Z8qifGCq0utJw+BtmPQ3K4OzoZajcA8LE+nhnzd3SX+0znS8kvj5wYsCobGPNq8W6SbVUpnbAB
GtrhlwjPhQz2ffoPIbzWHob7Xt9C9PIgARQQUWGzXKdkm/IrqCGKtNc8oatIGbIaEMRUWFhD40OY
ySSlAdCY6H6xx6EHSf6Rb8xfHUBXK8mJJW2RQE0q8zalfzYhAoBZ6md1jPWaCZnlbE6dvFNOxOV4
4oBe+JOAdBVFExQmT4LQ7MANISrVxMuqFvorXRpqx5fvvjAzlz3YIiE9P1GBdWcCZvWGp0KY4GbS
4XKJHC3svItzudo0qSJ025BMJOD9zHzLJ2HNvzx4TnhLbo9lfgnW5PezDz2QE//nlEkimMeJYF4H
ZnHbYe3U9ByTJTHBryyoNFNUvIpIDB19WVRI4lvOgzfiLSLlF+naJX4iPkzdvrMDVt0KG0s4WHJN
G9EtzawRsDgUaD2nv+WFFBLbXn5NiUhnOxUVH/DHLJzAJPAjlNKw4pby7i9hZdPLuTWz2/xOwzoR
QN4+MDvJT5F4M9+PZKjPlbAh+DLxt8lF5RZqN5NJNxY1HH0orP5oMnhhh5mMHxJIdbC3Q29xjfRB
lz1WI7So0gitij4eCTLIqIwta94FJY7k88p+pZHv/Bp4/uSE+shD5O5x9QICn/eTJmzQ+d2/mUM8
iHeGIoTbDGEm8wbb1xZJSIllQAtSkOkb48pXdUMjGp+BoHN3nzYpbS8lJ2yx1BvvTl1bEqf4gpRc
fbe/vPZNx91ZOhDw/lO9cJyTycLbbYuwkWRyWTU7j8fKXeZ+0y5ou7voVzLBAuWbPefEU+uEoYZe
nQsRE1xNDJNPtPWTxVxAcxNRDTBlrTzaWoQZZuMlSKljrX2LZDaYHsSyye6//kKuVAmtrlXdIpWh
Pw/meQGiSZwayGTBT/c6NeEVCzKDzPjefZYmvKSchB7+qTZ10l0vPEl4ReALFLeQdkJYy+R5P0fo
uJM4f+lvOLi0V4MU3GvBgkRBTEScU9DCXRfAfv+6ArWOHryVPgtybMUMQGwQEiv4igkMuPvLRHRB
kmzjQ3zexQKvFSEc4MxuE+yqKk8qvnaLvB3VFe5+NfnoLdMsmsRfvFOsTcz547heLc+O1RbEuRhe
8V7IDLlARldU5QOcowxMb8Jshqf44BbnZAq3jymHZr9bZS76CKk6ZXZNHI2jykAQrZiG49da9+KG
Y3qc265oPdx1Eh4TdHxsqvvwO6cey101nClgU6hesVTHXqkwbm+c8aR3+RRAqgKfLwgNViXPCQt0
tv46+5WW/aqA+Hyd/Ni8A5/oiI2MX8a+d0OQx3rCIhWEvFpRnVMHOr8wbS55C4lIwdiBqOegiUYa
7RDvJOlGf45dWEyhqIVD64qLsDobIgySjcZX8As05HapTe4s69Kv7igp4MbH0HrDSCFL9GN4Zuzl
WPTUwxwyL476mC3xjkZ6w+FYANhk2tUbEMqh1MS6tvroo4LVNaottw7s4EqH1gXyqdYqjTnP1V32
dosRKzboyb1W9soMOz3kZwqnWdEaMut+GVII+F/lG8Kn346MKFUwqRxQSiB7E61RKxOqvdDpZrWZ
chfw2nv4F7E61hGdH00UMUzFCQpkdUOwcKpyCMH2/Ry6cLwLygxU6/EkDlHJFq5zGJJGKv+9O6za
jp6SvFTi1UxYFNOSbhH4OVtqyLeyCns6+Ud+Gg3o3hqqbjIeICelinpZY7UYimfE3D3CHQq2pE92
rAVIo0iCRgwxZf/F9MCXYLomlvH6nCqDY03b1lIr9pYfD/VkWCcqg/Y+UfzY49ReN5WcY+zmlPM5
vaZXTJeMJn9iHfaxT2ylXz5xvPieprzL7RBO0SFSWQTBcQ16NK0J9Ayzx9xdzafV+ZgGhkYLUYeu
vXuRqy7hVhUpi0AMoS8k0/30eGts3lolnmBgSvN6MwzxyE71cKFdYY/oYxveO/Z4UND/F5dlCGNl
IbJUVT0tyWsFndxDmiRqoGzxmBeVCLuHYo7hdiah2gjzUKnJzjoanvYST8uYtcdnIFp+MomwrYWU
iRAlZAbqX3Xjc91OGZnPQ9bJTEiTzRvRLajiKhkfXST+AO0wec2UTrcKXgBSpMyigGvT3TJgPDto
KS7GCR+S7gWKo9iarmY3I/IY6Kfd8Z4PHm6G/hpmMX2I8zPgmzjxp2eoovMBSqk/10i6HXIlNw0c
b9XW2R9C+fqFztxuHhP7dhybsD8irFVCRl29OJF//AvKt8mNsaB60KbNrfA/qHZkSyMLEW3sYYuH
OT9TjaKD3FEDJ/xKdpPVYAtJxTYXjF1Wz2e5O9qZsj+tEPiZ8D7ZzDcVGLWSkUUUGRWOmxB14dHy
BDy1BUnf0CgSyz42ob4ghM5cG4KXvTeKQuJHIIYa57qcsgPQjGqFHLynLuh2dkaAtQzrv+piKzv6
OU4JaUceCVEMr/b1lzPRcSR79hOBbtvLHKwrCdeiaKVsIymRRAxDb/Dc6NeEQOZmU+rBflriFsRB
M71NZ74D/u2XS/idBKZ0L+RFIqPu0Olvo6+l+SyPIUED1qxf8LJ9YriC+ZC0TCws0UbSnThBCvuJ
riD/OFgl0iS1ey1l+0UUACmG13YeUqTb+/Cxj/ZUCpoLJOmsw6H2NJ0qnw8JZqZc5CR5N5cOsn7P
BqL9uNw2J2xwHPbMQlFZBDqP6OlQn9jCd896VqaoKQ7cZBf9BdA8VrPS0bVpvt8KfjKQdWTDHvVW
NT/5BzbbHXl5RpJZRJ3l7GRdf4YK5y+rU8JOt9TxKW9hzN1zHNOnUtANuNA6aGVHpsoZbpVSr44A
aHmnHKqwXnb1gLnc74NOAh2Z0vFFOGZSoX5Q/YY4Hz000unyjxzwdKxaCG4stU3uf+NzjIMccWnt
62WCVyPfkXQd2wlkesAg9kzrx3Wbd0To0UyS/r07HmVYdeCHF9mTheVoYpRly2+3awjcdztDcsKU
/uFC+21lt546I9LK2OZbmVytfBi1/OQFoHXDonvbPcBxJn5VyxL1OJb1q6x43EgvBs7ngBONb1V9
aUHOVzHuRbXSHNSMQ3WDF2Lj/lEYi/jl5/B8jcGtJ5Hhm22A4xGq/IrcBfJ7mA7ohLtgreL1nTa4
dH1qqfg+KKe2P3AEtcknNUvBTDWp0Bk2VV+Skzo6XQtw74PhnvqnSbv19zt7DqhHve8IViAHkYI9
a/wfnjJMuwKT6G1utGdr7Tu/o/8guLFY6hqZnYgv/PTcDMKnFECSdJ0dAyOPEeqD/tFhDwmqzj4g
RDd0eNJarvhO3b4IoeUYjWLbyMCG6ARhMnvnNehj1GH5lWKNxLHYyc3OXkDhk6MIhpBPI1/ucwsl
LMEBpZjXt9HnxtUpdqwqBoAqBhum+WLMbYsqeFXZavFfybOkVmAFFbiHZtPGTfq2Rzi6SMF1mhGz
31sbCEyQVLb1u+ms25KVqq80J41Rg6hdU8KfVc4WhegI7W6JQlhuAn4FQaDVqNqLNsEs8xPK3iqc
+6YJ61Ve/EuQE17+qWJl/QSIzTz26GG4+FM/z/hFgNe4f4J4fAcBxoGU1xBDbNxKCkemsnFZ2W9S
tGU2yyiPha2/7GEtj6nKJFjG+QkpXyic0WNK67Tg0asW6CzeZAG9wKpNE8BiN/zKUxL/N+uBM9Ox
fCVIa2JQKtg7l0fGB/m/cw==
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
