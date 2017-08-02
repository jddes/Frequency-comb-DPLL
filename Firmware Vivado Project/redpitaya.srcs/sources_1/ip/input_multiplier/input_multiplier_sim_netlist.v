// Copyright 1986-2015 Xilinx, Inc. All Rights Reserved.
// --------------------------------------------------------------------------------
// Tool Version: Vivado v.2015.4 (win64) Build 1412921 Wed Nov 18 09:43:45 MST 2015
// Date        : Tue Aug 01 23:36:58 2017
// Host        : jdbureau running 64-bit major release  (build 9200)
// Command     : write_verilog -force -mode funcsim {D:/Repo/Frequency-comb-DPLL/Firmware Vivado
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
bflEn4yycFQQGHpUmfy0yXoJzRY60B70YiWXhH3Nd/ZTK8SwzdnqFv+vEuh0SvzDelC/eHPUDumS
ubhl866z4jey6XfCZAKgaHg+IfEtL5dn6+k3vmwGieMiDBdqx6ntLMyVS+ZtVpcnyS+yt9ikZDNX
znx6bdcvbKvhsCFlOJiUBiqFQa2PME6r1ODFmwBqsPWva9ROiMCNBJyS2ebA8ZijAU/fUEkk6x7U
IQKGQ7OhZZ+xgKQCgGsvhWM8ZwNntYtECEMrYIfLZxhF0/M9PYa1RH93umyr/xqbZS71HMRTa13h
0nkkV26H1f95tUQRbYkvaMSE2KcpvxSEpqJ+vQ==


`pragma protect key_keyowner = "Synplicity", key_keyname= "SYNP05_001", key_method = "rsa"
`pragma protect encoding = (enctype = "BASE64", line_length = 76, bytes = 256)
`pragma protect key_block
uE/A4sMTYqUQhFIDp5FfIYO/0I9a9xwc5TctHxu7qrG8Owe8M7aFKEa35OvT/nMT0Eqokmp7I4Gh
IfU1sO/NcCs2JxdxAobAEX0IguTlGKeKJMd5qMXGYfirNPQsVSWIFucKSR+FmglGpruXStcHdALu
3jtFM9bUzxznVXUiLEthQ9O4/2GBVn6kUpog8r3ytLkEI9086MTw5VIU/KfxmC4HMMHkvNHguU/1
oZVFHpaFfC7cVI3NaKwZ2NHRm7IB2O9hzrWx+YolK+UIlbv9gFTHzxGJy0q/yznpXOTEeJvMp/8J
KUyW49/Y/A/evAxOHeXJ7gt0OV9HL+zfYZzXSw==


`pragma protect data_method = "AES128-CBC"
`pragma protect encoding = (enctype = "BASE64", line_length = 76, bytes = 7248)
`pragma protect data_block
L6XfLm6xSO8gV7WdxEr1o+02Doz1QuDbsbHRvh0MoAuHk+u9CwM9uNRUC7ThdSHXdFDsu1YVq0bV
rGg9q0Ds8ZhmOTVJXoMfOUurNoL4XMxfY7Z7HuUS1EnESeODBIhYQMpagRorD+gZzJaYcWxUkPAb
YBgZbXaXa+zAJdya/gAnFiKzXflrTj8feoTwCe7scdiWxz+RZwl6EUMYB+8DkUSJUjM9gJ0Yi97v
HnOaHjo1UkT2Eqq6aYvCb+JCvMWZf1E8Kw8NHolhs8F0Abj6Kd2gA+VQA2ycSEVVOQMuD417KglX
X7zFOJOd40RwaE6Qp9H6y+M7eARVgu7Z3nYUMbO+8980o81/1AlZw5yec9UoLHuyiLWrq5m8fDxo
YPJZ3IqgoauIgcDFM6ZhoY29koNRJ7Uu9hbhIH62AUTEPzpwcfBSx68EgDzZPbJLvHo+CR2Ke7/H
dy/8Ps2DtKwR0vXu8KZEwGWintsWuE/1ueYBBqHT25KxW7XGrEfcy+rv/ZzXRIoyPhjb208fVOW3
E0o5f+N11u7wQaoLVB9K44Kr+a1WxZmmGe8+eixXWmIYUUtkjda3BuxA4q6Ty4M4eT5Mj7OLEmJw
UtgkOvRqnCPJK+m1PCUyTcXiFr5uOmE2mtloYehcV6cPZY5ZMkWkCueZeLL8uAexq1g+L0jJxMEJ
mnnTMiakXu7xrMLfdDvC9Rx6GELuYuHg09mkubRCzHX9pdZAWois0wAztSklmfDI+sRAjNUqF5AR
8akanmPORHgr3bESpDg1SPYtXkt5BPZK0q7ElQ7J/cM2390S4x9CZXk6GJTi9irZGb6kFckZFzE4
iSJSNyFgpI3SlXzfVLnLORaDesYng+AYlqrXusGCdCUynzzzpcxLJE5rG+0CBsQfw2sNXuJt9nqO
iJ7m8Xcd1ZLvJ8dcZQf5wWI5hWIlhusRQKGQr0mFcqvqjOYde70NInkpMmBcHIGHe14KhtOLnbYw
PSJ237ImN2CJX3oX+z8TakG4DdsY3fYGl/PlM0UOhPzyN34HJ9BYeb3/K8yLb5TSpMsJ4+j/6SLX
j/TnvcDPRKFS6VDMDbF52+paPK3GRpkHZ0EswOLoWM8bwT7y2Gd8huQ1+EgmGl82zSa38h+MFBy7
y6LZb9YDCNTeg2TIGwejG2nFKT5ig+2HuVPLlibUjprI1oksou9AcMX+TSWcO3dKZC4Tad1tjAU5
0VyFkvoNn3jf8IKX3QP6nonHhsj7I91ND679ZEOCP9dfigL/Urx/l2yKsvUHFEUk0+LBS26LlRy6
mijQ1ISGj9zgsX4XffvvTOIuglrXOYC5dXCjY2xgxU5b1vSXFMoO2LabUdsBw8EYNyuxjAZbAn9q
YhZcSGnBMG8XMvEvEzUWTqoSKaYFVc55cQedAfi9nkVNG3ZkTgKoQLpjO9CHxewnGJv/uVjoUrBM
G7WvJ64mcGSApXbnCPLCi+2lEiLK2/pQ5DloSZgacuBfBfMcQRIyP3BJycHhHbLqhUwq7mh3tq1D
q4g3EBRDaryG//Q3CGCBLY0/paB9daBpmMHN1F2QrQi8ymwyHruZ7BD7OH7NTsxc0uTn9HtoutJT
bcuWrALP34X8pHRhvKX2VKHMIGsJj+kBhnx1iVkArkhr8mGt2kya9NNyaK83uNa3rrSofNSxtatt
XXEm8fyfLeJrYSPp1yfH/k2ySTKOkxveFMj/94E50+hw9Xgg9JQh6L5LpH1fgqj/rMBLnzK/FE/R
eMjkw592Mk7x76e5VDqOHsIWqfDqQUZVhkE3/FAnRRsmogsnhvA18KIVZkh0nsg4CVkqk6KeAq9B
bmUjl0Yj9X5H9eiCpB9/NrZt1m4wb6V0L9VnZ6Ahs4HLAtBkv3ryppHcklFd+coIQA0UH58vCXiL
n9uVJvirK/3s/gXl9Fyx50Cy1nJw1xLUztcVdUCpOSA21ljsibSSN0jOGKxqumD7G/liJdc9I3FS
XxuHGieKydOn290OvaVKndwq36MEoReiLP6tO3nxK+saclLNV/51mPZIdXHwi9IQCFw+uvaQQzIW
g0j/w2IcSe3QPRMRicvFBKepDT7ZLaUTgqE1kEwDJXaDBfjfMusRKNdcUr59iKCCdTLzEi8KcdBg
bXQ6IyvjV0axtARgjnM5meJfj0UeKarkE6NHlN0Ytix2NHpNiHg6L5Yzb0RqSyJPvrulA5X6rO3f
aIdYYRuwT4/ukIKxppIilV6ZKsIWXVoXHTOyYO906FZhpzGpjDFPERZ7tlS4WJ2vEYJB2MNQ/VYE
uYkZELIvzNcLnHsENt58ty9/vmvgcu3pecJc7jzcvrRGPdVVACionTpWG0OblXcMqeuOJUl3Y6bd
cbjQKMAA+OdCCZUfqH1G0t+u5Sj+jdlcFm/hYhzKdjCy3lXcep2vOmoV0G0aOKXzng0xDGwtHKDF
n0bBjHbCpBkPhHId9wPYGwQYZ5eHmeaYDJVxKjuhU/z24PTH9EEfzhFDMzlrombpJc5bclXAOz8a
Fc2Ul2Aw/VT9u3bqtcjoMQUIqwJ07aD7sVUFduS3Kjv9+Z9NOrJ6/+zs/GtVr4WcPcog3IkFaeic
BA3YfPS4RDOeAZp14n2hSB+LFtaMP+zonewJt2Uw41pZOSXAXBdo26klq2YEuJTRUvdufa62ZHlg
AwM3L9ByzMHHFl4HI866nVptnS72fUuJOgDMTS8Ie/AEkUdbaB38dPO2v8k3mXXNbGw+vtBhm/5n
mggPrzfmeGncu69E+921QuJkQez7rKBbPjt0AaHyaR/kH88Zt2heRgwPXXR14S5UZ4s7eq9/E+gw
xa4LVIoZ2lPXnNrLZ2+8gTQDlwYEabHl8AHWMeUwuGkB+L0jVR1Lv7r2l9mqLo7UMyaxsQdw60lg
cPxw833rwLTNSPhzfDTjINpCF/8VVpk0p3H+2eOaHxxQHiyma/jclnInIlA7HXev5Guv87ZCJYmN
soiOGw6KMxibC82cEqwyCpsgUOAkHCmfX3x5RSu5XJnfYQX83aXynO2ieIHllqdrNvzI7TCyRspY
dCeNnKcR3PzhmydLEM8I9v80l3+/fbWFGFsMewNfJ482qIERGUvmbXtwC5clngjA6Jfv5LZUMcLU
C1qtvmmelN4WTbVhj+bwAWNCARiB23AQoyMzH2HpZFOXFf+jw0Epz/tEPdrZMRv/kQUp5N1QIXuN
uDaM0eCUFo+Div+3A8BuJkzK5/JMVpLTJmEZgxX2tCkbQ9djJUlsdp7McsRir1ExsZkt+XpGdeP6
5cVQAb2cJtJBNz/zwRUG6yC3lz9qaFZNAvUAs7qkbZDBwjbb9nPpFmrRu1Mie8r2IdIF7qwrGJ7v
j/fipULe9PKG7o0UPiooCFXBkVVypjt1GpsxGCl9QbgjDgrN2pcZ+K/LlxHkiXWYN//DRZWHDKNz
AtVTmfpGGPN/qK3SyF7MY0ZWoNf00uzQsAkb6NWltuH8rgoGYdUH5gARd90yJlW+tcymhzw/H07C
0LQkA3u3mxVBhXhUPByE0GZNN0Lkvbvi3SdE61O0uP52/+yBMFF+NqsiwbAnFYm1YDAcNunf+TZ5
V9NgHrdzGMfy7zM8VDVw28BUkj4f0FD8wDm5iiezbqm8ktfngUTSCKq6/DMXiY/+3xxRQ9jWXdMH
Cy/XfbLFCu7vEiBm09AtTtlITXGSwplRtBIRYYGdkbQdW2vxIZevJQgVSm0LJT0zNbnER5jF4AuB
sW3NbowiI1YxxmvkMnTeQVUO8exaj1XhpDMpYOIx2oaxAU3qv+jaencYfTdiW9QBzM9cr9hlGpg9
SNUSr/vxLFiiuzhVRjTeaVW7GJNL1eEbuxewSIukGr74aQiTRwyJpRJiSjsUqnYUPwI5grQhv95c
JJujXys03DJepVpW/jJ6hh9fj5PustpRj7lVSnFH+YAYdspW9TZu0QOVLp4523BL03nMDYfktBoq
DamC/PYnbjAyoUJ8aETQLKdi8CAvyzdY5kjNDSn5FS60d4RQA0sfJkyjV/zBDFBPVDh4pkig2UmW
hbKmgBSALtAFv79bQVVQ1lvv3/Ain8lgsB40ePfNR8Xp68EpAoqIYKBFWvQmbQcMtmh72zVQbavj
1AKysCzmcVo9tGyEc86ZdmDw9W1tI6duT2Kz6Y8UWg3KlK77YT6tU5G+dpBwTcISd++czNjI/42E
w6F60WWWYRjd+H3AUHUPcID1fB8EvYgnWi1fzv2QPXLPzBxg1WUjYoi4dyXGzgXbVBK1mZgIl4iF
xCwh8dtlyO0Fsa7MRQTw7wK0wgwVC0OWK16QZSrxf9pWkFbhRRAmfXVi4NFQr8LB+eh6bE4VVHYE
Y3bFTInUOMcorkR1GtIUxzqOB/3MV+0ci+0dPmxFccQ0QZ8XYyD4BUtnczQ8p5bFC4KFUOgHG0g8
sFxnBAHOm4PbfVzf9bb26tq7yCqYa1kN6kDOR0hns7qEExw+fwU73mX9SnsJf8nw1jzKZ/f+qwB5
imz0hqBEYgTxBXoc1GAYpGQXMdYiFn3UJmGpRUPdAwJYBT8Ri1XDkBUZT/nLMBIwi4Q816hbQ3fF
xT7pr/bdtW373IoY9+CuxfTL6mmOW8XzFO6LLwzBGO5xLq8n2foGJ92EtYxqiUNKRBHszeFK+XZK
cRyDr7tUvVZOWBeR3GksOEWgkwGdeD6elpy4xzcNwzDlhvPPKxVVWWD6VZjuTVgiMLM/2Pb2+sga
ccOky7e2H3lU1xb94aAxS4P9NkPeNIvGF5pbmujoqeuerBlLhagywGeQUA6QKxcztOYKgg26WUIf
tJ2Lxszet7l1Kp0shY9oLYFwi2AwQOyxTB/xD37EmIOVNFndCxxytNikRM4F+hLOGspyPUtFiU7O
RKPE1rZifB81lSS72bqfdnX7zfv8kbkWmHkCqxJ25qSJLZWg8ZJ3lBW4fzyfT/ixqH+VJ8UYMDWJ
pklgh8RHDUJUfPu770cuDPzd7HjkIwtzM5q7mD8mm2/tsv1PHZiMaSoawIuRNYnM8q7oHSNHIzsx
7m7MdIlFrRKN1aw4ab2OWEP7PxU6fAYiFqSFNkVpq+QTRZ8eZPFH4ZJp+Ytq/3WoDLiEvJ3Qtph9
dLgnnhwKLFzTAFbnrIjRhdj/AN21Po2n2jF59YqZ9PrtHrtHDix7seHIpfLVBsEkz7Y4DdnEYjUO
UNKhj6nhX0VSFQSYY8B52T8WcRCjETNLUyy2668GCsYpw7UFZ8oP+v8K8WL6GSCuQvmXdTzuL03m
A709XUehWmwTh3JDIME8JqKu0VZAq/I0TcoIH3uh1KwC4/1k9Nyel7LhET5yuSTBnrS8dcv+RyXm
6TGiFPnZfgRtFPEYr5YFujCn70gYG5a809xLmMwJd+oHXMdeUYdgb9RMm2E2SwVvayZQtBzXgajZ
iVF+TILGtJu0jT5FK8TMQNzshch8uu4tdudll8CiKHy4XE+Tykcg1nKtiqAJhdkglVe37YXRaCnU
1PJ3LFjHp1P8+Cehjc/BYkf2uRapaI4JAiZYzDrrYBIxDixPGWqXHVJHwxd++b08Br2qAhMiQdm7
xZ0D3lCYZkubM27QCk1kFG1K8ROgSKvDEUU5ymV2TgP7e7sknys52pC6JPnftp4TkEr8288cCGSt
wg3wzq80buTE6fEU+2z4OfLIW8Ccdqf1/P0pfpwaXQEspG1evoauBapsrpIg7CxzXD1krELWIjfZ
Q6KZMczQVnWQ8NBLI7oi4V6OPk5kT/w9AMD6nOTQNEXawxfUWvTXJc1ya5iLiOC9QT01ZoylzokM
pSWRqpD63/KPXr169ZCp1foSNMdSA3o1DebOBKnNhiGSWAdUlH5FRomFsl4hfMVoURWtWu5iKQpc
Nvaoh+WgwAZBQyKu+Y3dBvLgvCDibsFPKPhVcSz/lRrzlrNyYvnms7zAavBoWtYSM57zhQGjh0L8
0QSD6C1M0gJx5VX4fZLipnDWiStGfF0AkEPdBf6EGLLE+wNZDSozlEgaJ9T14clDbQl0kyuTduVe
LTEBxUI5/O+DVaSCkihYrVc0pqNmC2zJDcavtwnMmFUgQ0uAFlrXOPvp/Op9xGfZilEqJ8SG8yHw
ObtXKKn4R8hrrKk+zsF27FUjzXUCsm0BEK3sj6TzoU0F+K2NPL9MTVgdzP6gtKQq2FFa22u4yLqn
FQU4a4sMHTsJbiPrrfVrJrEXILu8aGJw8pkBv52xJDal8aCfpQRHGwsGbrv7nOa5RZgXaFrAntGL
JzY8L0NbcHc+0UF//Iswoe6ue3/8bPsCPLLW3aMO+X5qG71SA9i4+Uqd299Zi1xcWDCpr+l5U03a
0fIQ6aneEpeqCdyZ7F9C2yF0kgej+nv0cR1AAb/iLji+ngUMxzIEQZO7J412wCe8gGTcrWyG4cqW
oIJWDXGVIN/qBLGfHhSRrJA0qUAu/Oxoh1MlXclmviW6fxgyB3EHYRPP5UUN78OgrRtSP9CfjpXR
BZdqQj98leMez+RmgtTz+P2YzRD/Qnm2wRhxWlbHTD/rnhDrLhq/tWlFAKEyKjX0Qxg35xUR/f3Z
iwYRuS5XBPyUEW8AJ288Fuh48p9dbCbOLuSqXziy6/LZG7qd9jm4PAw8qww1UK0J9oMjFij1u7ds
MnoLf2vjAqoM0sZRiCQSkub/v9TGvYnhYIndEJgFrScuYQnanSHhYooMCasM6K+bY8dt0QJygoOS
gIxssJamiZWnZH7MVxsoiquvZgb5DpNQnj1rVibQ3F5O5oJRTei4lUN9+J0y+Rs8IS+8KuKI8fau
VItg8D1rnuKY8UT8IsndKLqze5BA68Uqs4FlDek/xyBkO29G27j8O3qNCoo9o0E4RxgunW2uULmS
FxQPiwwSQOzSMDn7lkbtpdDXbmvgV6zmG05Jpkha2w1FqzyByFxOp4foRSxJE29dQP2/WnsXRjj2
GO1WFHALjX56eoqnc8g5asTi1JYiQ+25vzY2sXymsIdZk2RHzt18SSfFKoCrJ88/5ai9ThdRh4DG
0G7VFbtPgCwmdz8c3k0lFilX/drMqPgrJcAoYqzdtH9idJPf74sEoVF+ER/wJc7cpeMInwSTvY1x
MIYe/1VLjNtdx7rHmaYw9Hkd7STUsYfA5ImlVN3r8bG2XOlFayB+BUXhAACaUJgS//2G7O62QlnV
jyhXw+3EQXHMlZPlIHaMSuQoXaQw9nrchfZO7uqurjIfjqhZjmS48VMS2Vd6NADxK7Lwnojak+10
OED2pZXF2uqfdsGUEUtXpi3Qhu1eQSvW9ja3ONdPMgNeg3cbgtlA8DjPp1ntVgMmQawUqnclxTXu
Fuf8Y8gnUCGwaPslMnAbTMgx+30Q6+VIu/MrXB9AZmAaaiOMBInakyEBkpqAKc17qDwLBGKY0rJm
t5cypUJaAqJ8V1KWEgYACq+Hc/L7R0F/H9HOZVB+2/MJE4wRoAk+LMByekUCs+IBXATb9lQ8/WID
OhIUUYIsEI+XZf9hTM9J1DZG13TQkutwv2KcvkXD9hzTVkhx9d43JXCrRQQnb0KzIGNCzSY2qxiv
H4LMRt7Cvi892/BaUTzzxINjxkxOuqfkayYXWnfM8cXbLJvZRA9d1lKL6pE6nh6nakU924D67v6Q
6CQomabsrk6i+M+MMBSk0o1LgfZkbPp9li+XDLMxr4Et49VSiaXHHyRHjzixo9pp7bxDRFkCUt4Q
n/efp9Pxwei4lI0gm15Ez7i9PK77koWdt4rlaTWzIZkkPot0VRCZNX42pVnnc2GEu3I2taRRM/d2
pVrENQonYi6Zuq1Wxh/CyAOuQbX8C/8D0bqK9xIfa9K6U6IBaDJlrsK24wPEnCcBeO0rBzNVplJE
arjo4pM1g3BAfnWfAfm5KRFAsYqEamzCMjmbDxH+PbrXd4cVAwnF5jTd/fd6PMgXH3K4Ctb1n1fq
i6ZrMeIabKYTylnl9mVY6lc3a/jSrBvp6d+m5meYQdzKIxzQLrzzp7jaAIJnw9/L6FxyAIMynCxo
Z2jPgiIh0dJbtCQ16SybBq0qbAVKBlOgroy+uhgxNLa0ZRDxhSCt3GxURk1bXRIcgF6jMDRoGqJd
1cBIPkU9DXmnlB1vigu/5VduHXm8fczBtnuJRDjV2zoJvENkpL45F9tcEU31zE0PCtpKRWsCtsw8
0+32J1fKIig9FvvTm2DdZXX93tXoVLMiFh+KP0JX8mO5KJHHAsnaQvjjcQbz9CuAChzXtczggd1V
q7BIr6lXAvGsOEzs65uCyvb2z9RHuHRPy1mpAnDghwKujvLJVo536y7zr9zgMF0O7TcEFtrwNwYy
ofOGm/EbBuobKso6lRnwn1ZaLsTQJon2f41yQAWiVdvdA4wpl54OEwSVJVzz0WmYnEWilcz90Lg3
Nb8GM72N3GNmq9/cx99ABCQHn9OZGn2EJ7ZhGHFEIvAHZapFbU0S8M3AU1naQCYp4W1nRUVcv5WC
BWut6ZC2Yrz46woQP/vlJtpyfOJpAUwf/E/Ypf+Fj/JYZybhUuCUzTPmW6cPJcFmM83djIVw2WDK
7wWGgtTdlOLtQgr0PqEg/x3eSLUSVi4TMy1cylenrs1/CWOeDLzlQGK6/AGwNnGs27bB/p1cxAvO
56DaLyamlmXnDZ7SEzHHKvrfSjBUT3g0zU46tSUl9gEYZ81FPAtrwpGMVCkP296iOH7X7RA3fkXh
TJ2EOD8uSyiNwhz2CRynf67AdBchQv2yxPSNF5/kbhTNtmPLNPocgJKfPX30Ao1Rg3YCtKS+lIiy
Y7PLj54Wyds/qEeaq63bFxG72niu1mua8H6Ok0lZks+wmg6UJqhBOXh0JxUfI+IfICG+3/5vSFoe
CGc0VVsx+kOT5CufBOz7yTa9fagbA0Jnb0OgkU9bRw6SMCDGa/9FyeWy/si1QIXgfwTi93zKX++v
mWbeAkX0eixEi7YJzsZ5ugwtYzAgGKchbzBDzkDjREZ7sEDu73C+7vg5Ibg1VteMpSE0/yLAXjQX
lIavXc6yiB4IiapP5EYrzmkRY2nymzWeL1wCFqw73at7IqiGLyc3XzqnNbMUubaL1XxGyXhr/EbU
/yhYH2lbl64Ka6WX5owmcJ08l92bzz6ClRtx+O6dmkIWCTNrM5oGz7qciDAR0fHGWb10O0/gwtr3
lvklfrE4jWleDFHG7IrQzR8/V1EyjvrmD/sH35D0jxSsEMKpyw66Rh0UMdeRtywmWwuMAg6N7Kau
XqNKSbkC54sthVA6ZWTn1tx3oJqW3h8Qu/pP1txWsnrlaA3U7lyRqS7eTep8va1Vh88p0pIU9/JD
nSGDFTTlOqtR7nshOTI4bLubjYugROpUdErPbpPNWHiMGvKD9BBVgQP86kjp6cGLoOYtGnAQPxtI
E6tgJC5FxmColW4r/GG4/7KpysCHsN9G2Tiz4IBZDp1XjUpa1VT16oxwtNT4Hk70UR16jDQuGHRT
fgOEB2CBJ8QliLBgxc6w9E/UcXVQt1pLEWMl+pFAu3NNXzTgpjsPD1H2Fo93qOrxNaDEyZrvRd2U
eBk8RKPv35UVw4cEOxUKe3Y5bjNSVGDrdz9/w7L2F9K6MiAovSMHaujXE58UvXCTgO+TjSahe5cz
WjpqGaLhrBk7KMgd0uQtg8ZKKZ8y3425k1xRy1BCsAoO2XJQGHBD6YDnNsKyU5fjA1Nu03wIFuAB
yb9lR599yYHf
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
