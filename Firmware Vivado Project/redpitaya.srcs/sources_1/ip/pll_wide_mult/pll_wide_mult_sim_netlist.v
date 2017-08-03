// Copyright 1986-2015 Xilinx, Inc. All Rights Reserved.
// --------------------------------------------------------------------------------
// Tool Version: Vivado v.2015.4 (win64) Build 1412921 Wed Nov 18 09:43:45 MST 2015
// Date        : Tue Jul 04 16:06:11 2017
// Host        : DESKTOP-OULANE9 running 64-bit major release  (build 9200)
// Command     : write_verilog -force -mode funcsim
//               {D:/Users/Alex/Documents/GitHub/Frequency-comb-DPLL_v2/Frequency-comb-DPLL-DPLL-python3/Firmware Vivado
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
Y43nRoH9y9pidjzkxOMesW5CZ8OvBHSLne+m0Q+XAnUzjzJPuLKW60AeS72OUtX4VkOWFfuMRiTp
x3c+xqjDtqxc4IOqPIap4IV6zWuHYZzljpzCugQAHrmGVuYEqT0svKeFRsUAphR025qSzVxJUTxY
J1JBMmrOxrcP+9dKAg1lgcRS1HGyLQRZ06rEMZLaIj5xfz/zdvByf1Y291GO76c+YS2BzAJ1r1Td
IyE3ezd2yZkZRuebqnpBpS/yu/ah3iGra75HseSEwzdRvRQ4bBtQb/tFAem3x3U0LAzn6FdPLTk/
0+DsnnaVV6p0i7spLWvNdUK7QE83Fxw+QLGjDA==


`pragma protect key_keyowner = "Synplicity", key_keyname= "SYNP05_001", key_method = "rsa"
`pragma protect encoding = (enctype = "BASE64", line_length = 76, bytes = 256)
`pragma protect key_block
eSbyqbIb6xeDUhH0xkWDLfhysXJZvpIXR3K9ss+O0YHDv/l8av0EBb573vpVp5ZpCRJsHbpCbiUl
VWWN7CZM72RJVOB2L32GgzCDee4lYVxiW2WVrbAuIPcpOacg2cnIf16NbFquqDp5xNShjkGOiPJg
Z2vyEXx9zLiyfUAnspuNuMYBhlawDdcK+0y9amyQwCLKMdTmZ/p0RCaIC9PGQadcyl8T4t0+f/Mj
6pKLs7ODkGZNEidtg+vM4zM09Pb+SQNV92X8ORfmkRhzz6dsAol2C+MzKGy/J9eXncItklaJSjz+
Dvpm7OMOuKvGKW5xGAAuicZM4rhvoH0HogihHQ==


`pragma protect data_method = "AES128-CBC"
`pragma protect encoding = (enctype = "BASE64", line_length = 76, bytes = 22816)
`pragma protect data_block
EGT7y7Az2APPzNh7FzPoFO90BfMNgTEFkRiLKKpXLywav6+76uWHXA/mfQBydzHB0UH/KUqvJL56
5E82aqud42W26S7tDU/7tsRab6ADyFmTW4Q15NzAzRaMknrHlJH4y7sO9yVZ3tdl2hTQVQ4GeWiq
nbV1OodbuByKndScVzAkRG9KZDka7LX7aFg2XMB9O/w23OdS/02yAjqe4I0o39jwVZ9zE30N7PFK
KDiUR2qyy59X8WZDSimW2MyQeANBGnj6aM9KI0EiyXXNk5ho7EohAz/SzTuYz8iMdZvS1YdMGpJa
eL0Wi3360gmRozZedDR3xvBMSlGylo7o7ktH/3HWhpj3ICiG67sbPZpzB7NYsMF4bvbqsNKbDxkb
mXlmmljuD8TPeLiNaij7Bj+84CwqVIOYX/2PEB/62gsjBSK6tqva8J12YI75yFUjhGojupl7pXlp
yMguKhDpmy1i1mpHl+uml4FnF0auPxc8cCAtdAxZq36+qSA66ZHUKzYgE+R4W+bMTEMirS1yVTWT
lRA9x6w+x8FHugBaQdVFF1OCm0ufA2Klru5m/uV6+uj4H4izrmyh7VCakuv2MHmPR09aDnzQBKrO
bHu2S+KTJd1KrEEAefOckgb56WQMr8A7TDHKvInNv1QF4y34WSroR+aczxdJ18gXZ2H0Yz6HtT9J
23SIRpw7XLSHdpQTknachiK3xAKAx5pw+lRCdloWFf2D7S4cHeW39MjCVB/y/RJ4tsr3vUybiHrY
93WFQlEDH5mSgkD2vdIrKqNzItZc7z2Rfjx9/UHNTlmj0VtI+QeVTxGCnTickVQ2EHfy4wakm831
R1mciQFY2HGRhCxSJQXstOzG9TNZXgjZ5cuksHmyy+b62c3qQiY8kKiCwD/4FpHM8H26jpucwWq4
h7SK6kGx31gg5VWPL/AT0e9CQc6LIZjaYPN9WwjXrkg7TAFSVwsBJ/O4BQrc4Zp/3viE1Y2xqdfU
BumudKeafVDToki6iUcRugbUiOSgpVMZ3X3Hr71v7ZuWW8BJFs1eTJRrfEldeiWOIkbqQbPSlFHG
mx7TXnSvFbU0oBuM25+Hc54tr4flGm8aE0/rOepsWi50dOXAAJ0HEnThf+EGIOgc6JiacBCeWfpR
cl6meRllcBkdevib8rD7uKfBJ4NBdLzXTESxk9tT5YvEMpmGO16CVwyqOb/oERM+wvli4uC/YTjk
fjUL9WnBAyBbU0gXT36QjNzxnd1DrsQVljxfE0ZHup7qqyspWS6pwKNIMX2je2pCWlRpWcK2wBmQ
BibMO1C0xl8U8pqtZb6Lz2IgCcgO32ZqrgPdtt5RsutLyfCgtidkNEEYCFlhQowLJDP5eRRGb9Mr
AfZd8/Ty/fIOdxP4UeKu5bAOoanJN8p9gKCaODT+T2hR6IhSA4kQQl31lhuvoABDZUGjEnTbYgD7
Rp+11TyptkpHIIEB5xTePgO0K+WWi9+sAcAT9u3tWXcBL6tpDZlSjVAVzSo6IfuAzD8TBZbR1xcx
KcaUbaiQ4t8h0QhT4EPbrbpB1FnB+LPQDTvpJyUHq2X+XCWl6lQU4y/FpObiKdm9q3bPiuwHghHs
P+Sz1yvjiURYI2ksRaTxVAeW8UvVZ7Q6ITuOdh/n0jt0FT+ZfLj4+IJLIRhcTALSyHTboEBgrfbK
yWjOncXe8kwrWzMf5dpGXY+XGKWbEZk1si/vz9N1Tpln/pG6e8HxwxECvw3i00rp9xAjg82+kh+B
yrZABZPEjTMK2081+JJuhct2YxVcu+Uf0BshLj1W9bHNlmtosbnI7+QP0LL6Ict656qJLsVBNGNB
RWE2f9cBscny9QvPMVEOkzSVjoh6XYeOenm0hhNFRXKO/CbsHryYJwB53JMs46K61p7xU2sOuVpC
4xuF7Fm7GMt3CLCEfliS+TU5hGh+a6y0aptD5NZMFv3i3qGnIES/EtkKs4Mti4NABeClwMZC7d94
17kaLDXNXX5uLa0OPlH1QWwE9m6YTzBw2FyZJtZBOpR2Iy7H3nkya2PMDvdZagAyi3o9vgOhVkzV
YwCIboR2rQlu+TXdKjQZYqzzIb8GIndU36aE0sWHHgy/RvDkhk7nYNnjxdnTRdIJCLwLQR00BUak
Rl0jZUVuHYxOw84FHlT/3xU7dptbcPhRsjRCZ8fBbqRsht8H887zZ+cqyEOeiMlhczyI40wbXsYX
mOPoEJyIV7Or8EnUmFncI1FzaltzSyK9IfLvasFjI41wt/RmJ2YutzymFYUDD2GLsBand7tB98NI
b5bSHqZ1aHHTLd24AtrIF3DP21CrgnK75DYt0p/twFI/6zuRppwfjE8OKV1QV7vOVJZ9/X7St5iv
AXNykMGt7ps1D8WxLrX2HFJjiCucMaEVgvQgFwCDbErpi4jEGSIbb4QlFnNPrKZrFuFbN6ebonqT
3loQPGGm5/GI0F0z9YpKxoLFplKnze991XP0ubBnUJv2ikvup9LTVCMx3v7sesB8tg4bAzEw8x33
nw8XT6fowNABHI2Oqo32OWgv3QxBIInq1DV9u6O7kKtl5fIegBBFBen3AcVZh/rA7C6V72xmj3WA
YG+DqtYNbqLDxPd7CnG7dyKEgQAUAf8EidPnD2fqp3hPJ7necejIOihksGUZ8GoSLKKH041kjlzw
UDEfRvHqTPF8NRu8mZJn9jMymh4Bloxj8BR/SMwhl7GnxVSQfUNN4YJPaTLl0ec4bNtOCDJRdauX
bqMSeV3/ZprphDds7dlu5SW3Fzi+WFhJwwbZeZ2zNCnU15wUsPjyDkQ10ddPAG9wNb+XXCxY4ly3
X0ot6e8GpJh6ZweuEQcfEVk7NNDfIOPPL7D3HgFpJMifXyqi3VistMyK0c0CWDUBbGUrEM4xzHaA
MYTDlJmfTmgcYdL/4wehEQbboxmwrm+iI2qCZYyBGYdANSpcsbbTwgPGj6EicKdYtc0zWO4d5rzL
pGxLCnNPTZePk2+eYLkSa5h+CzzYbX6mkhPGPBOrXLrPrXAUgA8yMAfavwDXL82SKlrDxL3NR9i8
FbCAoYHHGWScGauMaAkI3mlqmPxE+/puitLFaS34WOx64IFfEkKV2nY1DwP9Sn1jKcY4J45OtL2n
L0qO1vTU8c/epWfcfFyAzoSoJ8D04K5+f5XYs9XyOEpsyY4t+/gg+hXYI7+oq6dxZnVVWk02yFWZ
p65sMZRHLG16MgfeBW0GFUrAPBkywOJabmRdI+resEGlW1b8zzK+JtFymeGXnn4Xm3RcLc4RZf7o
UrR/4UzHvfsg6PwV9uRX12wtKe30GzPA4D4T6wVbBuVchjCyesVy9TYK5Cj96l+P4Rdrq5G2dVlC
odvB4i1LQ0nrmpSjoBDzI2u4oyChWobd4pEz8X65zKjbUDldxfZPV60fCQ84hMlu6qBntxZNUb6I
Z0ighjHBOnJ1LsvYnL63NG2qKV8uUCsFC2EUHHUiCUYD6bQErOSU/1Z9H3+SWMGMCepiedrV0Oxc
2pjZuo7dAMwzZ6TBq5H76RGX9Ajw8DUTmj6jI9IPcuVyJ6E8jlJCAqwsTBDQ1AeyOeBnOrcbyqxI
iuvSWXsk4yeN4lfwW1eHQoHAiDImRsN2Oqk1tp3uyP3SjDoEMjzMdpg3L3eEicSjIS7dZaukTtdP
+FplKXrsPeGXxqPMbM0rZgvuA8xKqmboNh5Wsasq4wHtzF1SOvXW0bGLPJUUhBGN+MzpqQ63xeRY
L2tlFn5wq8dfBwiS/2HuaN70RsKPoaZS/G76tpTvG/zzwj6gJiVIY6flgovnVlMCKVZIOOclQAVn
Q/moy5MniqaPP5ae132LvzvFIerVVUBkz81W7Zcn1nkGukeVOVHtUNVs62WGMrdzl4wtLZw8/OcQ
O6iqEqS7gHRXPBrj+dgqrF7mMKUSnrqrkSDdXKCZcRhT7dFnOb4FRYnuTTYNAO4i9TNxrS+LyHUm
+t35ovwOIUlLgoWa+l1zaiEvZ2dVpcXZC9+4sbeHu7hYwUnbxZNlZ5E4xp10epKB9AQdgo5DBFI8
b2Soj0vZqytwX0jBruKy7yyjovvGuJhELYfk+MqBPMOJBCaa6zwLft9KikqgUlKwie+MYJlTR/UG
8q9BHHquCkPLWo5LllX+2GXrjBkiDhzZRfBLLMTJYk5/F+3ihHPtDk3o3Hi3kVjfrRZkca0pIqFe
hFF/RjL3UfRg16EqSFE2sM5M0cpWlgHuKyj9eDzl4GwBkDBFUxQa7ighWIwcwPnwR81tPN3xclne
R1g8Yk7ELAg4ZLFIJbJRNi5P3iYOisgyv5yDKK9RoNqYLKqwaUW4uaGOpjQgoFwDyOSm7u19Ck7/
gs73SW5Wz4QbHINwzQ20Bh5yYMfqmh7kVoRWKyE/OCL24S2/cNuCncWh+l0ox3wbnTUTgeQ/kBHJ
jqpYoZfokVp412mD0NFBAO62TFv3WAg2wmEkBUPymmENAhcmripjAF+RSokVakyLwLLf6I7afDUJ
UwOhchvyzUnm6T8rOkGKIkN9GKL8nYQt8J+6II/Tjrk1szyhgZJY3DYNYWjLC34F3HQCt/t03lTA
TEEzADdlf1nLDsmjFqVuhq9FAvOvC9ECkKsk3xc7b31sUxgMpEhiPN7AfDFWBu7D05oh7bbXbEV1
L3xWRuAto5Ilj+9Dc3wVV6wyfNJCnSS/Nd0PoJXVB1WkMX4UMUjunEs8FuQlpOdAdWJFp9L3c/Rb
GGSXt3uc18Us5ByarvHK21nujRczjfiHrFBwNOkCNAR82vKBwrl96doXA46tWDXcjBd24ffSY2zP
L70cWNogzqu65mKje262N1zYxwvHxAnTtLSraf+XLg8wLUW2R2JE8EWuj9MunKZGNePuQq+PeMZO
+bZfih47DsYSfkBEWzyg6H65t1r6MYaMb+GH1S9DLC8hnmXu6oWJL1/OwPft3EG0jVCtFn6VNu0y
nIw4DiJriLkP9KOIQHm6C7Geonb5Y6UWrNxtwh46cKezuOdi0mkh8T32JpNHLnkRcjYNj3ciJqkW
v6KXrVmTa+A5jLzdBCbA2jXriyqFa46SldVEQqHvQRynoy64yMGy1fN6pM5FevqP+T/tpBCWmvSw
8yRSARaKaatuXUMjnVaYxDVHXq1vbOGy/x8pP5qIjD+rO4JA+g/VD1cyKS861VUM6dO8PKKyiLeK
sc7koMDj4q3ObNVUnO66L+bzJJs10IlROCv5QGxVzr91kWVAZvcODLUEN54torIM+twvrZL9deUw
TaG7Wd8Z3R+98qbmMBBEn8phgqxI/3wvPQmF9qTYxDxRmPvqF3BDyv0f0AOYc3k7S+nrKSv/0c3L
eY5Oyb/xpFAzsmcGS0VquGxTMZ6UUSQNflOoKy644TJ6528wGSX80N5BLMfFSe9lMd6OJO0WQK5y
hszkpB6HsYLENWY680b4owYiqQVk6b/ToRMWvtyKMzHfaxmKqbdjRUpLcn3l7QLR2I19JFeaTfSM
fu3GxviIvynXVBRlR+AXo2F/wbu/kK8k3BAzo2/4ZL569gmDlzSb0FeKI3AVL2mHNzrPnytHQawi
cM8OuD6TJLeTeWhxgwN+CrevFSDj5QN4u9v/mPj4ZqO7vId9W+tC2ZN/bwpMCmkobzGMufLWfGQ9
IdCLhxYDwB3xfKz51jEQEwuFSh3PLIA5ZX3qvPmslGKW712TGU8FYsC+09CyJehoFAgk+9iyrcix
uZItfCyhz4mXm6lqZPUz7V0tmKg7r/6Iv1bqTVZIjnPsJOYxVqkn2bFWK5Kannkyc9wtYUjQIYWw
rA4ICNmQ4jImLhhoawvxiP/EANarrgUjKkRfxwnuiHY6CrqwVFufkqMApjRaFN/N0foYlYDeAov1
fWOdkI9/nIXpSxJRFA2H3MQtNZBfJwizYaeSJ1jwiB67FpufO1Mn4kZKGRFzMd9G+lMZG5nVBiaD
7g5fiHrkh9dXIc8hX4Y2oJlV3GRqLFSNqfOfON3WtxXQRIeNF6jJqfrOk0SC0SM7j0NU2SITeEvl
DoF+SylJx7bhLhJi1l8H52La6K7j2b8ehPxN7FFHehtsLEtHS/BxDRn2VemjE3gttyGJym5hlEzq
3R10F/8Z3YCfwbIaUBWQR5CJx7uVd3HdJpQaR2F8H3evF8T12vC7vpy+3f0Ek7IhuowqM6vu/V1l
0XhlYX6/owIqXHpaO0djOpKY6hG4xZDZ9i3nmGo3A7iw7lufupSxgDwyhA+dxVJC0FQ2TWOB1MG3
ko0gzWZROGXMuB+L3Jwe+txaBQo0AdPshzHbZ8Ef1sxYdpU4YvH4w6AG1eVoRLMVHK2zmTtkYRjH
zBzgXblHHKV+LDoun2p8yKdGsflJw8RdrqXi02xC0os4FjGwBG/rlut7FHmalQ6Dyon+cQ7AODzn
R9AudrDsUrfskITi+kdEtIWa5rDMDXAHYMSZi4owyYtUoBKIOAFpSz8qSdSAB66VcWh7tbzFQz+b
zOF/bP3paqvzp1SmcvWb+cPZGkAcozTPvk5FjyNE9yCub/braW5tAacgAToTCCpRWL2S7BUOTyj6
nGGaYR3CHT6Ql5JARLxoL/mvUsXVNQ+dpRwwoZS12DgrYBQdFEQTs51WSItKUjRHi9aui25ukdpx
AQWSJSMPqDLjd+qq1NhUWjx577uC2kjW2QlVRro+avKJz/l7QIcXmlBxxSZOAPVCewmo/V28oc+Q
mfdifUMb8Up8qZJMIphDPz6+lQb3N9krvLr81UBRHCu8722X1G2YlG1O2muMaKq55AisWBtdBDav
6a6kSOtfJr24aD/JINq22EcPbCpQdFJtfhHBzfh49iZ4RfzHZtRwZ+sTEiNL9B+5yJ4PhFwe1I67
ydWPJaHXq5CIP8FOdng6Su0fAb4ix5fopkFjEb/inLNz1LWHg+YJkbL3Fo99rH3pfGEP43VeQoFe
T6PDqzEGpTBZPbjlX1+cW5+UGF2ShDOhivx3kmc0YUeqBdLsK6/u27lapWXa1KpaisRL55gMYgR/
Qu5CZ0nTsUC5MhrKsd3MQLXfjogVSCswd9wzYXylWYyupxZTgT5J7hoVW7sQ5uxM7cTNSTl+Ohvl
d7QLdlZZfjezxdr/wPRN2MIGCwwo9BobBHTzMYzgRupiLu2zt+R94WOOpfZ+9ex27wGKgN8xhuMk
++1k05TAvw1SYZQ8RWUEpfbIwim4f/WZv+bHH4iduNh+htYVR95v5/YRSZFI7tkBH9GgIOuOF5Tg
cri2g/NVIlE1uzgfbiQFKH7vLOkB2gBC9weWdsUvF9jbs4UAMjwFkzkn0pz94mb90AlvQ1MWv58D
4msQRTpOm/qEksy+YxmKFNbBSFWQROfTg3tVb+bb/cEjmshwoqqNBBuzFNgCyRHXET9liZKpPvrW
/jRE0DhkUixzmF4L1ysOvvhmEfLofDYxQAok6g9x8BPd2+AlBQtAAXUWUDUpWA6DvWBPcOLOtkKr
XAz5y4cOZXyLbz6Zno6+tal1FX7oFa9Y4Fyq+2qTUbxv5dLT5q7ExzD68FJWfBBgnvsE+3swjXS1
Xigymj3iG6mtCAM3f7S6PhmLBpi/e1AKKdrrboQkRN08ubJ7cpxzbMlri7G/20qaPc+k3oxcD4Up
CSgWybZggDDK7HJquM5phRFpa6CV2qNDMquO++4n0KLi0enYyHrsMWZbDPPiF5lH1jAXjxmD8WxD
+5fzTdOQW/SGbUBZ1hAudf2JWb9SLAsPvOTArAI2o7zoqC37yz+M6+9MhWmYYqaP9BP3R6kcjepe
5VjWzqWjf/iruUbJtHSly2WEsB+aEmIVQFSxZqFXD4p4cUrsnIJ+kwndjBRSthrrMB+5NjZOFzKf
8Sb+Ol2NxUs9/fcoUKuG6WFSnD1fYqABCj+L+6oVexblXe5n8oLkBIFgMpH1YvIWn/nVpPf8OYTg
mKWFgCFS3neFQ/zSp6mX4ywZTVd2alzWcToa533ev7I9UnS+bOiUg3gs0CDu1zO4sqZgmOQ5SCGl
Av9jN3+g6bnso79UZYcSTUZVKuGHku8bx4KCg4MmW0fWttlM4vfx2zp8b5XJ2S6/+gMG2UH7s+dZ
9V5wsZ0PmABBz+yoc1JS003HbsHbQ6cEcx/vey7T0SbbwQj1fycM3w06FHSYUp0CUtddJwboYBwK
VVP2zKvc7iB7N2fHS60SWf9hU3m60+h8O31Qz0SQPH2Mk7plpstRRFgeLHPoJcLwNuYdxmHYbc3v
7gzIfNUTF3lLOGB231U14lvURSkBAojZSZf8qNmXMN6uvaRY8t/C7ZXbf3d2VAbbQwvB2nbMAoj4
VULv1B+e2WYQmUjWSqBgk8kUUaGEfhyiGJS519BuwEInOhbNq/fwEfRzNLoiR9l8A5/dM1wmklv4
A+pr5eoo3rdTTgrRO726sYSXAViujd63kbKVjjBFKMR1eujK7pj3R/aTT3U6dvuvI3KgMmMuM2Wh
i5tVVbtRcCPqgv79vlZ3Wh8s2oFqUFoVRLJ2wDX5izZkd25Pi6tm1JOAravfX2/PmsiBGoqA+VH0
P/3jDs8Zv7CexFOLNFOY6Py6Ph6zGzw8r6FNf8XD0yq9aDxJdNtpsIPF1M7TK2BhM/cJ08lF9lAR
S8ABgaeLIc/8TXKYOeUnhR3PTf8rWXXgoWIJ+eCcLaTpoQI72x8aaukADJ/RHW/YpPk8EgZriQoR
v3JMo4L51ynah8S5sFJjuC3yM5r0I+Mj43MjRowbgdyjXeVtjYmb1Jc0AzVHdz1LEMaJoCo3VFJk
/jLmu2ZVG82pirT3OOG7cGoZsyOXvIhwVSVSJHOB8a3+xABbby8k0Iw8+pa6cZTBKEzvvp0uJ6oC
RrHZBBJ5Gah2rrFnvoNuDluKhafYjSRs60jqnHLAcIPjyw8qCpIi0Itj9EFwjm0WDRobXJUCTePF
5se5a8x+fbkpIRfUD9ego30Ie3nQQk3JtxULetSILPbhgZpTV8MUpqqh4Kx2edF+X2ViJKPSXk2o
l0n4tcKKJxoJejD5YQ/7rOHnGJDS4yAI0qHIjXUIjshmS9GQqQFiVGzrrmhsppwipYUHhDE0yU95
kc8cCsELMdue54SfVymaJSDPDBpyDE7yh5xIScGVz+tvm4hnbW7yx2SBAv2lx4AqEGRNRM92ndDc
9t+VWqqdv2lgXR2eHnXw6KCSUJKhczIzwkjIIWUJgsz9efmZvyxO8B/Kv3DSa5yhgP4s1k6Ghjen
JsA4EmfE8dlv33f1SRCCx49eAHO1+HBGT3XQ3GBMJj24jFMnGiXA17Ax9uN7AS9OXE5UefB9skU3
Aq4uQrS5whdtvziHYNiqHOqPM4fUMWa/49lENW/nDfEK4/iYm1kCnD4wcfcLshYb+lslzGQTs2RG
Kea/zW0/GIWYAIuAlE3a0zre3BuwN7z3IEsj26+EOFqVX/p1rhO7DK25ODLqKBB1s5EZJM/YnYir
K+Kq75dZRYv1nvxtWSvhdjBrIK6FOw0JbsY8smv/j8mle9EB+MsThr8A3ysGSh12FHEazdRkuDta
KuIRosj9sfVtb+z+q0tdpHFm3OUatbGlJQIBuOUKt7Ba8/lZE0mZr1tVexH8zLvg/+GRh5Gi0C2b
JJBN+IiiFrEpRSGeVCAv1GjKVvSeHOvGHaybadIj6wvK8CVSoiHgN53Lvr1FDAJJ2qjbTrP7WdyT
pPBIY0OPkVMeAu+Uu0aETrbe9PAufRl9T9R645GpOxQZ52x0JjLYjO8Mr26ADcIkDnOnrFOtreuc
7kIp0oG0dj/FoMftrabSkMYFZwfNP3P0HMl+m+fNfGcaDZB45w7q959CKOhCu4fAKx1ygalIiPtq
iFI5khUapWi9dOEX1uoA736sd5uS20dUI6otnN+1bqcRpFdgndSzw/vC0dYbX7j+YYnzisDPUalN
TD4ZqhtyoID5z1HkzEstIjTqIQS06UWMZqfHhpQLbTlivWe7oJobgElNKSs8YRZJj6TLGd/L/hVA
HcZWMJXVvIlQNuHzfrKaYF/54GxqVlMb845gGDFBsuF0VtlxTLer7iMKet+nPKydKRoeXRnn2WaZ
C+6vRwGzbuGsQXE6PVxzecRgT0ZWzKLK/F5QKSDmtmm7KgxuTqSxYC1QFik2I4TD4WJ94wWGA2LE
EVEFpAwLU20bhxla88zQTGgidBisGKFWGr2ik4sshGVito8zBv2WtppQ9JWXURNLkcaJG4Lgti3s
tT17F5HsYmPrfZ1e86gj7n+3PLjiOT8RVkFWXi5S77HhxauLgXbGausN/4bUPcKgxvFqu6hxjina
G83WtF1tdI2kzM7+9LIsSGv2IUbrxNX8dazx5pUWYPF+gjMhZtMRnXdBwGhhRnpdTriH4pcb2vql
Pl96dYaO0/6MF+FD1BXE22ZCAec1M0RzlLDSxGzFc4mx/Rdv30Tr6oHqoqFzsOzl1MclxLiLufNR
2XFIWcHbMtD07wxk0HvkqprZuqQEphvfpcjhS2QOS8ZgodIxuiGd1V23ODs+azqojT4cDJZjv1Id
4uiaYFy+OkKHTE7HHUoQ6mWAYZQYlitcZoYtxGE3WnJk6G1ddRB6XHXgeQuQYx52UUIJlOzFaGcK
NUg9/bRtiBZ8/bZMC0Ez8g8onpdDMqWlaxLXUOOps10n+ZhRSIbjyasH1FcivHyVWIVfGAClc5l6
rqyc31rFyh3aZCq5SbWl0fTni+xZJZ3EgsxfmaIGXx3vqEkNCAWaBQ0CVJVA1hMC93gjzX6u0z/W
g3lpttAvxByUPhkICMZkpOdY3cEYk+v03jdc0oQpM88qIcOP6grKRQ/lam7bfMwBIAcwquU6qi7F
NbuWCPF9cQzvi7Gwpf56UO5deZ+OgNlFzhlMe44WUX3LtCRESesYwaqXBefrcBQVCcweL8Oh6KRy
JVnheN8xDYIy2p1h/KDlz2EN4Ce0hoCd1t81AMkwCOlrL30e80Yn6hc85p/R/0tTsWEuSSjmOL+u
Rlg8u9Kgngxqa8k2wQUqu7DX1s18YekXEB/l1W+X8jcOM95BYmV1HNdWZKkYRwiuHoFRpAAvsJFf
LCljBHJ7289qX/PiVyTxP6yVE+9B0onq0c0spX9UQ2JoZEIOJ5fFhb2cot/tdQ9SicdZzTVPxKS5
Ui8GAWnbJj2yYx8SL9kEcNYSueHtLP18avk8tYDqJ9Aj7d4nMVR9cVb97xhV7Vql3zbvRMe6JPfg
xpbvm/ZTHSt6anUQ+HVaKSSqFt1JpI5feFi9fEA4/VFZBR2sLZK34zo15uByKvpK01HiBjzFW68w
2lAYzFAu3l1RPGlDLYbzTUPlUMMvSpS0fxpWITTNpc0yd2I0qeM4UA++zZR6a22CEquHskrPcuo6
qXwgXHDUNJ8/pTRei9hmyIp3A3ySXY08PCb7eDMam7rRB8wjvdh4MNAu4098O5kfH8nz+/Tl1SCB
oh3/75IZraQkLv2OUsVM3rEGVi49I93YhPku1Y15x/W9g2gdNZ3VdyEurnbvDgEACTJhnqRxOhyS
4so6Z9bxhOsuuLPIr5xMmz7N9GFOlIofIEimI8eDkkDrgzjTcjAUrPqXB/Gh2a2kEFXJQJZ0Fm0H
s5V3BGUPD6/XYWlB+xxYqqzgtSnKcTf3Uv5obLkFFtvQpDT9w/IVQ+tZltF1QGz86V3z3lUIEyBE
5gkg9EGk9g2q4HUTV0D309ucFSP+b6VCi3vXKbuaJZ1xs0G5NM55jFu/0MZjhilSgBXsRc1RObi/
E8H+01kFddu8uMPNi5/PalMpB+vRWo/tescDsxzARs2PAJWblOjy8+A0188FRYnFidjBSZ/z0GBL
99L6poPe1flHKOXJNTVd//ThUAgWnzUOIn0CNybsg1G7xBFi1+miwY/FsxYLc7uJV3A0DBO18duO
kJJwCi+ewL1neFIDJ/A9B3R4NqVn+dLCpawI2rQSEWpwzGNtf2bwHs2tMVmth1LZPJYG2QijX+hQ
8OsNCfntZRs1ro3ohhkuGrhPAULVwtiStePVYitthmI8dfAvX7K+o3/xhJHxD55Xt8nVfgWJ9K6R
Ve9V6Dwg3o8E10O4pHsoYdZWKa25L7b91M95yokq53qkMLoTOst2fY4HkmWVFbNi51q4KSjFlldJ
UHmFSsDwUutmbWo5q9cx+GuPsfsPORI5nHBPBgii+iZ9IQ95xpu1FnbhCqPZg/lEFF8xc3TtX5qm
gMznh4MQcLjUjed0AOJUo9Tbl3Oe9TBJq6ihZbVbpOXqfc7zdh9Aw10Ov4EY3jlOgrrqdKbbvIn/
kx/KTW8gnACh+zAOlPY88R7azP8qq1x3uXt0UuuCh3f6XN1kerKri6YP8hQDAfUZKHnlfBtVr+0q
edl9A9m6h/voRygcATxn9NjZjr2rJ046PSoNgTrp5Fmnfi4PQxdiyuAIszi8RW85f0ZWjA1AmbY3
4TjtuyA1uznsY0FwU4OKAisQlBXHcNhth1dpuoRbQPZCqKLErjcDmPsb7gGlJhr1/yS9n+cYWrrN
s0EAk0TArszs/X+ZlNxVlBgSg4cJlRUPaOV2Kb0R6zU+wec64hho3DVFvubPW2cJKFINjvXJGHWp
uMMBAOAmbVbmxp/JO41iRF2CKvdWB5YGKrAQBuQw7Nl/1X1Zjtwm4XPkcAtv3NfWk7NMY6q/XOKz
e1gEUks6ON4fYUXUCWtqC6o4+KlVpHUkYb24P/H4SxwvOHvhprxCBxbirVBm6m+wSzY/P110jwdz
pGdkQtOCIrDotfA02HGNcNEulBn2HVPRBS9bXFqH16gpjDhNn+lqNmAMxZR7YQqsUfuCkTb6A5lg
lLT2UuuLYfXcLQLgL+fhcysnpMVYuZvoV8wwWIP8O90dQJIPduBEzjersZ0Gt0Cx7XEFu/z4Qbn8
4DUS3m/hiJUADR8K9J/qVgNaftVDAUCiU7n3yNV0+dW6P3Xe4k1fHDW9Ytox09tHpG8xWhd6uvJX
Q6Z4ef/Ck7iilmI6lxGCFZEkSmhFR1/aCS3hL2VrII6Ac2oi/Y219LWvAhIHs96PvxsK0lai28ds
3XcaTsCeb5qVhPWEqCMkstlBEhdSwV/r3Jbo61kb1d4gZZVAaCfWSoXdwbfBslmbCj2r7fy0ezW7
Vn51cruIQpD+8NRbKdYQHIaHhEEvt+5OwNMmB5Kn8LouiEM+VnbIs9NURxO3CSIYc9C7GsIiupGg
n398Gy/qOjxVoeceseJdTl+xZO1NWe6mJ09APi6sos4EhJkhv8Y6+8MYmYKLNAt3QKTyHwp0cx/Q
jcCY1Cr0SKnoIOnXWM+jzgcmNyo0XolJU/ZsgT8mXaH98dk2NwCJ+R+c8IhkWnsorTO9U6wTHkV8
eX0QctUNVDR3TWL/+pdieMaPLU812GKNJvl5jqh67/pdNt71E6TnIJTa/bH3FhNTJmTRHtJIsFN+
fCHa0JXhPHI01HOTr0PMLcHcfPoMX4ql1xtVxCeaJSvq6ed358O2SJK+W08yqYz5+HUqUR2fDHEr
EBiICUtPlIJ9A2pdTbUjti3jOBIm7ZPeh9GVvAELX4m3jj8XZZonUTat0WJayJoC4E21uNDjDNpY
LGKpzP56NS+tLfa9U3+qwUh+ZuxBwSSlLu6RoBxUjUO15RkGcsinKh03kzZxduSMIf/TQzBMX7jx
+Ufsm48LUKpYJ2I70z1zoadLTAPWsQ7EsYfiYJtrZvtql1AGd1ew7Vz1YcdaTbNGCGk3kmeR9faA
V9yT2hpU7gHL7MhsqJRtPFU4Vyfdqf7J0wzjecTOE7DZXy6RRCfrV5yb44CY7JqS2LLEuPJKmkc/
ObG40c/yS3sdf/7syqrmlJNx8LNZ+8I/TU0Q2eerrgfTkHzGJXbLC8HNgMchedipaPZeZ3hcuJKV
TpLxNlaX5/b1kfy22BtZXazwSHOVzGROpzijzo2BhetF87IGJnoMDw9n2d0NEbGGERyXzdaWqTZN
XNZcm2rOFj8OyXJJe3dh//kwibLQUaYy4xXvMDAOcKqSaAnscKdiOqF8mogCev44PoZJBAxlWlim
oiC0+Ff67HeH0DNFHQrC4VdKMqR0KsZ7yT7Uv2C1l9MXzP4DwN7B7goDlWfp7zkKqGhHrf6joz2j
dTaeVckN0f88DJnwuiq41BHnKLPbuAO6cLGFdrdMivn6huoNFhSeztmnIMatffX7y10PTfQSQzVJ
TKmMWTdDMx3Ntxdx1FE8AORxgk6JWiH9X16zWxfC1e8Bq9Mx/nyywCcz4i96cHpOUrG4qsytQdhf
qkQZCDa5wree5WPHmClESVqvtl/UjF/iRWx9yBu+1Tx6mvDhTOCubCzHa9mgwHE+tkoUm4A94/xe
U2Y8QSD7YiIXUPSPVjmfguqfaOxf8SqMZUqn2Gtf/zVTgce8Ixc/DLrCKiF3j0VuRb+13ux2HsY+
xLRc5NbEm3vcbYagt+eJee4GP/A2Xco3SaiIGOY+F0k7W8qHC7Z9mAfhSWXc6lhYlXYxMvc0bFGd
UJ8WJYG0iwYTCHVVtPad/iUbiZtMT5Kdxl+jSMnPDJYzKL+h20XrY1jRjhgLZenszb/6qO18Yy91
xLSHRc1r504OLz1+aITRQMUvD2m+LYM9tOU4ocGIwqwBTRrTg3tGasTt0Uo96I43/k467ptkkeAP
dh/VRXFcvJLCidINHn81mjlXdc9UumkjsoGJk5d+2h2G7hvfs0ywfekdc1tCea9qcBZE8VZjfnBR
+Dl5PTYgwxgmBGKn0Ot9MGKP5Xmb4LMhzjXPh+2q/+3DgFuIL2G6ngQzb63vewJYe70SeYrXuP/d
Ivd8GfQHWats2xd7Bj2ou5eK5FRyRQv2UxtlkLR7505SRMf6ChM8ut6dq+gPGVYMwI7j5JK3duVL
xdseGF8sWGIsPjK1SZhapfTvFng4MvMkm2diEkmAHzhqdKXLxlHOqG8s5f3a41Oai6OTmlhKiZ+X
1c/8EcqwO1nvIbrgz+NGHDRRPCWbQS1VeDSPkwA3C1tQUlFhoBZ4RM1rwmqsH0ezunmQC+Icb5Dl
reMOB2h9l9BdzMMsnOPcgmADYweddFsk0utaO3NmsqogMD8k1b8Nj1cjLb02g85ydjNJpn7//QkM
/nyGjWvO2hE5NqYlK3+7xY2tAZ2t8bc0nXRRcJB58eVG8hymW1fOp7vPEl988k+CyLGKDK40TRql
RM2l+SN+aKzCeYyBZftk1cI75ikxOcwoJ982MsmaF/MqKZWukK4YtjdsVHGktY001uv/K/4o6ouY
3hJdkstkEF0Kt9pQnRTxyErA2H1SldYeirpYlKrh1fEESY17OWOhGCxQRFV640uWGOFugOogVv4u
4ZG4F9kANX9t/32iFJqXw9kKaViQPBctukYeExe/MECCnjeVsGZbGXZbrcrAcfAauKmP6ahHaOxF
pZ4igRZmVyA0onvSm3+A5nvoWy2+axplaj/UN3Tza830+aslRitvhEkyQ+CbfCPts1Mr82MKGtaD
aWdbfTn87ymfJt0aeudDsDCD7um9hbtxS8DFC8LKfNFuqewVH5fFAyramo3GHPbyhYl7ERlrAKvo
81gdgNHQ8U7GDjWanmFm6RJ/x6/SnTeS3y7tmE4chwbrBsa661Oq4bAvLLh+MlCkJ4XW86tRMBHT
kW+jdmkjxTSZw890NyhfGLZpESjCfQnADis+ZVnayVuuAtnh0znrSB9R0rezTNKngiSooGGK5v8l
BusWy3JnrSzxt6/yXKtw7E74O6kuqrT5udJlxRTeIJsKWlU12SI0Ve7wSe/kPWDAYzbX53Bj/hY7
kWtXbrD/ikF7ZtYMCJK4ia1o7jsZok1vb2Ah3xc1GdSC3pNLEtpaStSBPVnpZrCZCiEUzlJLl0zu
BlKJm6j5P0XFx1/uGBXS2+IrN8bxcnzQipMfPyN5BQ8eCjvvCkPxk6kXvCpJ8kbolcfmYipT1v7T
WcFb0IHSqiB5v3vFdcA+hWwgvA11Y7q/qw3OEOXA3htZU3UYr9NJWj2sUL1gaWgW09snlip+w9Is
7J/rHoIRlpfxjld8ReOXBRdw9472P+Sa9e1tc07bbpLCiP27JaYa94DgzjewxK5l8HFWCZ8gLTrY
Bmen2hHTTPLGOGAtblj8xjfubH5KdMZWQylHNlTr43T0vWnelseGVle7z4s1t2kDwICsweRplKqg
IqJ7cFyGDEn+Feq3b+mZ9U3vPewtm2ActCVfkB3GFNyevVhw4o+1Kli1KOXtKo7KHFXczGQegCzP
tqriM6j9zcpHYDQXGuZsOs7OJeFJ57F90HK+jl9voT2iEcZwplKhYahbIhS+yZQHQcX0MwX/O9TY
YfvnWGep2aRyTFO+kcQ8d64MBkmfW16mdWBXTbGWHEU4m4ENOiJzXxP2tadqR3Q9wGdAb4JEWafn
tV9qpTB4kjUk3aBH7loFIWynJni/d9QVxdy0n5AEzg7+f5SwJ1ZiwkiQ/eXDHwcR+KrzlBFeF+Fq
cZ4m1fxxH2MqX1i6BoqcXIF3PDBHVxRFYnu++iK2h4sj3uGHyeUDkwzrpYslan+5HKr17WfJAwLc
mz54WopKxBDbQMp8KV7m1B1SQBvLf3ZmKxyaNfb1nkLtJnYYdl8vMnfBg2RPT9yy0xyfKdWLVQC2
TPbp/BMdDJ03H55scKPLx0dTXt+O8JD6jP4gRI9dxy1LSTRdRhNzsKpXZ/UuUu5taRdAXEPmqWn1
FR8lOUB0v5f1/63yJZkFbu2ToaAy71OGTE1Z2GBrKjMt+w0AvQ++/mmNwdISGJUPKmcpY9JUOPzo
s2RTBOz9YAenuar7VmzAkCzGuP0Uq+bX1NAneTOrdFjhTshTSqPmRHjzCvaBn44M+gXAGLcmo2aS
1vMEs18tr4HRpVU3feZ+Wg0rmkgGWuTDqxDo2/5bRpS+HELau67sIqfqoXZLXtFr51IlRLVjFFiF
7eQWdplaMwrkqrpMHrQkQ4Jp7sdtaDGwuOxXVYlvyFOCjKJ4kgofUdjKHSlK8czzwjsQMCicRRQo
olSz3O8GUuAY5TxInqPkY8nKccUH6tvd1Ljn1b6zc5IxjtPpRm4mRAOIXv1WkmfbdAOTYEbEp/1o
Dxw8an+6SdnmZegW8U+jBx4wQQYf3scrxVJJaio1y+VL0QzBV/qBn/V7qBXGQLGwtfdMBpxj2AvE
njuScWiNf6b4EARI6DkEy2e4+h7wdCFVqz1D5fFjtA0kowf+HT8uar6/rsTXqrtGV0GD7PKp/6P/
+fQgPDATNUgOi6uqKauYxFlr9LC/jlmRZvXKDC1aK6RRIfejwlXjm/T8wRC1j8UzGE2m/RQxUQHN
N4/yMr/QD8KY5TAIPWJS+3PYZ9zlAtjBJ0tcvHMgQvIae+6ZV2qPHJEuOWjBQPe8U0hz1wDXssLk
1IV89iMXXvVYEYlf9RFabma7SYSPEwq2wLdY4p5kjof3wxCsMpOEF3Cd6f3ap4BI3lB4HS1bFRBH
eUPgKQp6j+Mb5A4VjCpoOz7KH0fHOWZ6/WXU6ROLLOjxXeR++sRLwdzeYEgEKXLrqrVrHcUNg207
nLpH1Q5HGAbd9Qmsc9Z1b252WvWpOz4TIu65VgHnBFloElu+2O9EGd6p0n23zxeUwYGvZevJyaL9
FJyRZeNOgi6xUeRdwLZIXZyLo8Xd3kYK8K3cN9udbr/+AgM2yELZa7WL+Eg65D4QBHATXdxQdZVm
KyHLcDqbbIrPhuJeV6zPMeNUGJp1Xi2o7wNP/snus+drGv+cYejiU7CkSlJV8q8CL7EP/Das8WxT
6uKCe4FKiOMidMrO7yq0glSSvtejgcFaI4kX8N7xBsqNVXNkTvM0tpjsdqz4cv7FwbGtxGkGpOFT
eqA+MARxMj+VL/RqFcndRi+cdwNYV5LcifSXaffw0199sIvdXQSWz+MkWQsxuScn73gHblGogSHV
GEUoigToLgcO/Z7wAlUfQ24ftAYjQ04oZLY4d9Wfgv+yNYz+Syc85d3HN9xjw6T42jSVs1wgsBtz
yEEuvdgaIs89AJNbq0KcagFCNYp8GCog/H00S7oCyyVwzFkhOH8jda+/sPjXCgd614OOgK9/n+dg
YHklKFE0c1fXH2tvvuEbc2MFpxdbU1kaLjqOIj9qjHIjjzdfnMJLYxNBTjyVO892DXGZgIW3EMIU
JN7aiEns4veXta78e79w5uWWObR1AcuAAuH5aQjCJBJpVxFv0XP7PTYH2tXJfqTphylOn5JTQ0PX
jls6av44gBdqcJCI71zbtoY3zTJpu5e+/VMjTJA6N+JwlGcbGo5o0AF9R8a94TFkSEvS7tiCcnzT
rXheGpvmTHD5aSbTxrZVRXHeCgdfLjaCzhm4dMU9MB4QXvn3AH8XS47+UvX4CMafbjWpJi/beWY6
QzqqcV0Kq391lW8IGK33daGco2/gNgylo2cVF5/Df9b8Vnnq/IZJqLXmuevnPbh4A0IlSLWsly8K
1qULxhPM3GqgmPwQzSIfVXuZqKrOIy0ChKJH4lbGJv8wDPrZOkp359M4ku5x+kmZLaxLEoRV46nq
8SLCg2Lf0MwMz8HNQcOGJi08aNJ8ylOoj3Z+m6DgDJD5thTb/q08lU2/iQo96kIzC4fY9qdIb97Q
Abfr4Yg3/Xg6Xsm1sfHBLFYAcXXO+OZ7Wcwf7Fb9QD0y2W7z7kQQtoZ+9g7IT7Dnn1pSAUkpkaWp
mRapBq54h7ANPLyBy1O9ca0DYRDEvoXHfTvoqu3SMuXtSTgOLrBy467Fj7PuaXsU2p/hGvAB9bTr
4ZT9vQsf1tFobWtISEdoAxQUdCJIu3XH/+NByEP0ohtJpmobalKRbiDBD2xI1OGd+r6shHRJZR3a
suCqoigB2njviv4zCrUJvVrXGftcCTO+vPM6HRGoRXC86stH5mgR+KzryZ3YPJMsWFiajn7g8OS0
nm6vkCnGSFZnPM8VvnGFFMZ7D7EvYZSGZfn5zKUUp3kkoRudmyoSTZpL7p3kMoJ/pI2bXPeMBbqQ
46Q75XnrBaPtasZgpJtdsSs/4k8wA7GMIW/VuvTvmjlfFz/NKsF3A22ijVLft6rWQN2F5takQqQL
sPPV8n+RsDz6EACwbFkmsL4ArDc2gqpFOkl27CdqBX60k4+V4fr44/dwjTeCd3lMJXF6gSyqCgLK
37yzhNDoEoiM8UcmWSiQX6XdwXJ0HlDcA7qabqxriu8vm/lcth83+QqmaXeQ9CA1AxQslbLPvI4w
2Wq+ZTpaTo5gS3NirmWbq+1izpMfs6b1FPxdi4OVueZOfVKNTEs+Mcbl0+/E06vSlvveP4dA3bon
Qd3ihoQpiBX5gxAdDth03WMqL98ly8n10HYt1tWceB39Vk56WqCgo2WxnlpID6vClD9/HWiKJUZb
rVCtvt/cn4VpJODZVdGA0BGwv3l0l4284qTtXEU36i19pXwHEGUR6rR3pJAUd2fL5IMne10VDtAx
lzVTx9hJpoVTYg1rlwKji4bDzeFiA2Pcj90/HT8WMoHNiFzqYQ2W+TRobYv+w5+zQt9XUD4M6yTB
Fu5wkptDMj3whuhv29npP81F/ijUAi2vUj3Twon8RhjS3oWsO76bOyqC/VIinc/j8p79W2uhUDbB
3r0DAboDaRGl2Bnii9GvjYoLCXIEEE5miSCPR1JpjP46tqsCD1J9z9E1Uogn3ZjuFMxaf81E9GxK
Kp8kJM2A9thFv1+FppsR4dxgMP6jlI6auf+SUiQgyLYPrKmGW0cG/gzvUB3eiB4QHTeCztLfsWVv
fpoQaT38LbgVnsCnYceo3wf3lnkKDaMGm8dG14rTvdg2OvNjNlcH4YX7WU5aQleopnPDn/8sd684
bPF5J3FJCuQsK3/Nv5MbotNgO4jnj83rkD9og9+RqOhp3cgnANvWJC48jpF6H1Z51POxrX4C3OLv
Rl0A1PiJGi+PkUfZE83N753Mox67cKZBrzqW+tOkaR5JPNhv8PRU0uTttgdSe+89XvluxZns5Vxm
ZINJrdk2Q41yF+6vAly/FFY17f9JmyBybaRg470pSacems9ZBh2pwQc1j6gaIIAymTDD7jtkXF0p
PK8rbgK07dHmdsLhMosxYp8bTJKkkkOo8p7BA8ZZ37Ut2QyBMu33AM7AMs9p9vpS/5qUW/jo/4nG
DlbnErNhP1YX7zgeMpkHLcHTi1Mg7KBxFpd0oQYCCYkZ4GG8Ojczcxmyr3ix7xeov42B7O8HqVnM
mEi4tLBwPO055+CtVjjc9cM+GABKegg14fNjPlpIkUxI/0+9//D/lGoZlOvZtbze0+Lt/gbdgW1L
zLFPPiZzJJWhi5E3RRQYguT0QKi0irPsVpLpIrNSyBs20qeoZ2pPd8XHvp844hPaeLAcw61p/qje
M6VtGiFlHf5x2QDbxzzD/aE/ANl4g/KCbt5Dq9kb3ntSEGtcd54WMAKEMhED1XSF4QrAYAkPzsP+
UzBFr/2MKKolo7S9PrwEAjFX0/DTKadyQ+fL3TbNgWxkyGZRkVLoF+HyLpOipwrCdNyyZZWASJf1
wBlIc6GfnGNozCYVsJtt7+nz06PbXUCwqITnyH8fj8FYx1Rh8+Z36xdYiojaw4R2D2TQAsQg3ZHz
wgSDP7/GeU8Vk4s02iw14bZbianooU1nhrauFml17N9aLDV1vCClUT5za3K3P6Dv1UES8AmAi38T
2gWTvEBGDJuJ9fG90g+J+hhvSyg2U1XQzig2wcuqcVIEzTQ4XF54Gk5w/44hUyevyZdjQnEDmLfw
7X2O49l8v+Q1sWgdyQ8q1UiLPGLqXbbBdr2Zh/ICEVdRo15e9b94XxC3bH+3EJqlhG6BGEmbpnHz
XkiunP1ScyvZ58bxVUYOzM7rjd/dJ84wfqkGFnKDxohwRsC/Oa/HCXncWl0oca1pET2HSeaPIcjT
QH0EzFa5kH0rKaazV78aO6h6gKmy0ZP1no1eHqKG4oDfzcF62rfTPmVv00VO7aTEyy0hzk17V6Fy
dFA7vKENvJaGrUz9EZFCU8iLhYTur/U5cWhN5HULtvLhbV/STFsP2c9yIV3La1nr546QbtrHvRAy
0OKoMi1/dt3Cir93B5EEFfrYrRTY0uxPVfitDC96WHpCwcD69cn9mKGEaSJjRmOFiG9XAiOVozi1
VZfo3nZPY0x6J2or79GcFIh6JR5EjrmcEsI0zvp54YkkEEtOPU1TRa3PUU6fBFqLEG7XkMMxEjI6
XteBR9cDyhm7cUskSl5UDZkw+70U5fYJHHKOkeavCcl4kVLYsZH9ze+n2+FzQD4K4D/T+e5+DWZS
QIFSoKRWie2Q3xO0wGXErjWs2j3IHLMtR0+/C2GRHllagDtPn8ZdJhyhBJqxszEwBABopl1JKBTu
EvIICmf/UHwPFuy2ux9I1MP1FLJuxutu3HSeGw4k7eK0S808YEUzSTuPPrzFtqc0OmZsbS6/TjYa
/ErKD5chlyQ1rgjjr3r+giwg7HN9dZ7WyhEDAZWV2Vvdp5zu8i2i8EIDmyLDvfOgabRaqWr9qasC
8lRLuJlcKmLqqQ7LZGpRCqO2UfEJxOh/D7p7ZkP2L18UMNOb+tMluaCsbZifWddmhgcWdJVbNVcu
JhlWAeF4RGcfd6gO6PbUkaF+BarDv+lrTZVKVrw/GVkFN3XlZr9LNAzFNASlcuTuGcsE8NG5kYXU
W6EEpIs5ei7mDcVFy1d/vVZ9u5JGh1pU2wW8i2AJcDgNSxbhxlvHN9+IiWPfz/HJjmgm25XH2J69
9vDOgL2qmXggyUxWs7riFfRHBMvPczq3Kyhvm11G/UwgYeUzZrTUsBi0Nx/dXYZSalnaM4XRY4zi
M/xwcbP4ZbVaQRkALHlUyqf9qi3QfqS854gCzwildbKey2a4OlSBuhgQx2tfD6yL2fdO3LjE2W9S
q8mYuAvFLH8J3EuvUsOP/4axTSydmn4IkLSCdt9I24zqXcFy8IRbVU1JgVNTtFLO8bEeEHyVwtP9
iLYRIrHiwcL+YEgFGwsyoTK0hfkkSQjs2RuOeZDo6l/iQeXphLo6IMH9mtcT1g6iQZIKBxQVlfTA
rtuYVpZ+EMxKCIVH1D+a6KNSTG3is6kCtF7OtWTogvLhkLTS+0RfwIWEwVaCJZHCz5ivTy+lhFlD
8DD+ucdNLcwRQDgM2ZQegshjJceCOw/Wf7sx4XqAbSZ65NgHDf2DrC6MEbj9rCwUyfz7o5nRpxge
cyXBHHPF9+UOx3cciXYMEknUicFs01gF4AIosqh/MnB/kA8dC1hkcZDl6DYdWP/RHIcgy6acnvSb
AzmzC0lW1JA+36T42zt5PtjjfIAG6o8vHg2CLuIvpag+/1JBuXMcEarH9vk4tj4KRexKPWToTUgC
KGNl6vOKP8Yf3jfCXQpNbVqMXAFFB8x8GX5ih74SbyaYs8bh666ZxDD2/S2U6Bt7udytYddsVMxO
69FDgj69uIppqZqg5NcV66eLnr9eOrhJbhrqh67qXmuyBYs51ardL7X6A8f5khwIcEEcwySehrZe
5dZ8S/FT/U3GpOiNUFea3fJyMQVFrfxFxJUyqnlKLlqmbmnMyqM1qLgyPDqs2jMvkq8Dd4ptYnjo
Ypl702FmoGnGcHtmw/E+LbxmBs/8DuE3fg2CVtVZGGEy5stks8rdk/tfVflnNipjh+r7fnaG1iAW
YJrOY95/pKQDf/knx0B8nGkPQbolL5mC9yFx1p+H/bA7DLkJSkp+nT8hAbaYbr968DH2Bcg2hVA4
s9Jlxjvgkp7/6zy9Hf4a+NS4SXDTv0hyH6L09VUROvrcPA/JLQ0LVvyGyZwaRJq+uJ9YaOYpvgCr
ynORlc0WKDAGYIWr5S94BoRS3Gnv4vSMKdgJ4Jrxuy7xBs7Curzdd77vwNMzs+HnyJndp18IIl3Z
zTuiXZ7UiQOjrr2ObMFUFoXvWb6P81K+sId3dw3NlSfmgOr5uPAss7gcFyjbbo11l5WUExGtgAgr
6+yogeVJT+iqDf27cUh+rFb334rzxNnNyK2rDXaaa8IQRRIxIzY7wDJjG1YEQULaoeUjBG/x11Wp
dkfBFFpE7AAjose68uwCHEbtprPj5zET1HjhbvkUEiLH/FdBScY0LbQkvlxQEQJLY7inFJIdcr79
EmzGq5rirsYZg3Q6H4IV1Yhql2a5lKvikuFnPSYU09z9Gpf8as5N1dkIPj+SUC3IXmlj+Oefds/u
U0p3Hpx+oUMnMY0bswFc4wdmPG/n9jBSHxGWRubLokohW7h/VqGj8q3R5pNQZ11w3WPUNhAJVNe/
Hkvmybg/28P3Dbm3odlcJschfisiXofd5QGyWF9T1sLVkCdpfdcjx81inRej13Myvwz+zD8U925u
H+8nhUc8PfdJ8BcVBw2C823drxlPgVrm3svLXLSYQv+MzsPYsa3BZj57JI/2e6ccpgydbLk+ngEJ
68aELtVTlJhFtrgacNOqPQTETKTqQoKN2EC2XyWPO+dFYyFOwb20uAg2xeGDSjLyVe+m0tnskbWk
29bXUmjC9Ma6Hz3upKyn5HnNt3vn54UE/evq53aFBSGI9+a/iJkYupehL63QN6/7rq3SoxC9RvXS
2iyL+ABbHWMoTdVYRbWZ3Jxn4dyR0qGHO86kHmWhS/NI5rWHFpL8ePgEiyA4rh/xbe8clUZT72fY
ZOXDpY9pUEnTRwJeTZYWPvqiQbyPlSVLxHmFxkl0ntABF/hMNMzZI95ihf6AsAInctaznZ6jbO8a
svsBz3R35MFou3OD7bdY3LNPSOHG1sqLIChjsmeS84tcD0vYFQdrQMWZgxgkSXy1KaCiZ6mgzmPw
X1xPsNhR/4FueWsb+BB4kLTQOu9Lg98RfFqP82m4Y92sMqRwXX/+s3nfThw4w647HbE6iqTV1XSJ
Gqpr93tZHlKwnuoQl2pdxak7+AoJymjCGn51bOCKMHtR0DZwWbvzLaLdqSeoAT5mFDHj4oFvBXP9
VjtCNK268TcXCYs0worMmVAGO++w440D4/PlIOwKmlYMR0SsBaMiS/Yiv2NlT+GGFK744aIj6Bmz
4kr9HB/xWFq6iK59XVVSmEey3qe9JD9UxpWYn8jWlpK/BeKJtHpFq0wKNfMMQ1zanAUyflTKGiYB
0IvX//OyXIhoNqUEV4lgHC2IryvCRBtgmi+18xkt1nShnPmu7SZsKjPovKpfbpdbfwL177IpXsE7
l8gCr2ZeFwrnkv0M9oFdZvZFgFEHGsjlxz2DhnmjLoNBrxmoXypJgUL8wT0+BvzFytyhk6vpUNyC
WtW/qTdjvraICfWuHleIKdzA/BFTI4D3TfhBrbWlzosr68NgmEZQphJK+sMA/HoAJLtJfYcAQMUG
MMfhEARRmazIdNOPXPZKjS/y42F4KxWru2Ttf0Bi0UlMZUogA+PHryUigw72IESCwCIF5boinqlz
DH6uIiouPbjtXl8TJ0imO9Nt2PeULpicRRkGlPKW8DoAT8ekKtnhYZVnFExbyUmaF8P7eY8kcLY+
2jurZ3mPRAxq8u+m+YUh9GSSzdR7mRVlu0q34KguAcs7fofYn8clukBnrJ6J8tMwpz8WxrhbhCBs
3RN4Nkinzuzhd7X4dV9rEiX/WzS3LTAKmowM5bbFYonhzq6pYx7lZqS04yshqDZryg0H1nPQTNmU
AW/sjD8zZRf9dETbMYdW6hbLefbDG9zuiF+8oHsZEdlFphC4MnMGy5J/npHVbSNHyGWTqmmUgEOe
c0Y5StzGg+yo6KLGC64zAnA99mhEdbiIX7ob5jBbMpd/yvGZB8ncv+Lmud2dRZ+8WZ7z7NmuX5Pj
seJdQIATSdgGkCGDbuMrdllvj+TarDBPqqzKIQaizuS690gywpk9Hz1Sew0D1RtpXw5vlepBy9BJ
EjNEKEbCxFdRRqYgKsW2kLo0vHXWGaLHwu4Tpy60YzhVrfiLeKeIz53MY4DY4b8G3CtACj1OmP+o
mgO9NJFQe5iVOus0PKuxvkU9lCB2sMeP7wOjmiErsoMNh7iXtJHmqlusVRJrQH5hMpDbnZAkRrG2
ukgo8IIqEKaO0GmmvRKt4Fas3DAUspwBumz4wgyoG7EWEHaHkVLpHnvzaaIDblwS+Ap4zUrT8Brg
zzdQLh4FNbKwYxdxEDDryf5UrsmyHEuWY7qnAOOIJEDNEecd8k9Ph6ujGz6xZXC8P8k8Mtuzscow
gtuHvH28UrEuUWS47F8wdK+DuttW7dv8sK3Jb2UtY8kePzaad1L17lZjJBJl9Sg+GESNi7M+x/WD
vYJ3Az861Rl8JF8MLOMTN7w9Z8xGZzMVLgXUPUMoOm3waU5JtJSk7zhuovgzaKS7B7zcxpvLIAYu
FKLEn+yEymtp8cMfh0nMeKBB2nCvuDKpZvtgJ3c7r108HyNezdeiX/cF5Ki+JSkqSQZpIU01B8Pz
djy2V2ioTxVehmll80/kn+QzhI51aMsggyj9BU6aqhD15Rfe5pbLw7fx1uNXoJWiod2TmO6/4Qze
Hun5befU2ggHnCWIknYhZqHkL4w8qL2zoFihJBJFVj05KWM/TYlfXgM6/wEFWAzh/QdSCTA+SSeY
HRlrcpCEf7flaZyGPK0aO6lQFN/DiGTOJUW4eMGJGdIFRe+er4ANHlhkHY35IA77gS/uWC/IL/Vh
j9Y4ANXNWGiFNRZZENu4GUNpKD7a/ztEu66C87yc7If5NT7M0s6gA2QAh7Hy2u0z2VzAQ0IO86QL
Xaub0nOhIi1rJ0j7ujlwVYQAn/v4jk2JYo1qzhg8l5HhazEg6PGhllPail6HN6kyP5H4vm6JKUwS
eXdcjUIUe8F4dzTDdwv5GKOwouRYIraDWvqI0/qdME+roNCcKymHy45tFEnQZchNWhAja4KDnrhS
6NowbWmRRhfajq6EJIAOkls+bjXNw7fdyB25G7urNf1VPZmsvWhltMV2oXv2c+1yGRsSMOOH7J3p
de2EKVqRJlgJRLeaBZ0FVQK7qFTKm6fBaCbTBM8tTiwQ7TBrEzl1RjklcTqagopxB6/5+U91DxPL
MXoJQYHlcGbvcumg+m+P4U+CZvfQMjISBxTFcCRRxmaF35uhjCwoGC8NdXU73g43TrxqY3E89VG9
UxbYDHEg0AXfFjiwxo0arWTnfT6bqegz4QWBT4b8eLHm4jvqwA4VcrP1hqhpD2/eXujOfn6PA7rt
IW+r8OnVeipTIH1obUP3eBP+7o2G7VBBD6u+dH7NoaDOhc+pUYLBwviRD1/w6eQwyb5YyhAKEQHU
P9MYaYBsrtgq7nrFBJS9wZhV/ovuNwCyl2U87LBvwMjZ5G5SwzpZzfNau7kgzwDE5voQDz7bZwQw
5UDa6JGQkqLkRw16aLfscnmKiqw1KQWRzfhGvUWA7JdUV9KfMa0iM+VHXlAlghCHZDnQHkFiSzkd
+YO9ybDm3dSlryOyIhfFZfW10+aMsnRhFKu5GQvdLtPOLY3sFlWA0V4YqRHFVZrdanvWYpw+x/At
JGuqYYBhF7PeEKNjqADeAM8K7bXWDJJGzJg8jKoubkRjhgYCx9CpFubN9FYh7lsBWQQjF0hf34yg
AEWe3gEMx0G45FhsZZfeuiRjygRI//p2SCe5gSQX+i7Xdi37ONVfrTM0/vKwDhWhbO21x6OcqRND
cPwcGvRIgeCj4vcmQDCN/hgbUY8iWa/tihMWF2MYCoYkWwkB4Rng3O5aSQb7U8Qz/pU7QmADaQTi
koXr5pFRnq+UTEj6DYpMbpKZRCMhlhxSuKxKEwK6RTdn7bGzbkEljmKWy/YfzooHPP7L1XRBvlbL
PrYmnLlaMiCzO1uFF65YvCI1wThvENidPYlnzJYBal8wHAtta52KgLBIItzXvKspUdVdTbi/5ZiL
P3pbLB/7dXo7FxCMmG1BMpOyKZYnNZ3hCyRt0py38K0o/PXFC3mdtacU5pEjPkuT2ELPR+jd1xcE
SSJ6MDJb2YWDeqj2hYgOHAwHNn8uCQlbeFTBFUE8DlAByBqm5r/fuCv0lOxgaunV8XnTvXd0rovA
rhSagZI4hxTo+s7cRzGWCP7Fg20je6WIvr01UBkEkhcF0JFSS2LGBfPWtrEImkqvg2+Jcihc+5tc
4saPVXCC4sA/NVxCZ9XWXcGPjeDFpqppxLa9cKfGN/ZRTDsBgehvDxvTwOX3iRLnXsDxV9zeXNau
P3+Xe5kVqAA25MTuOOFikxnJ3H8u9uU3lOAvi8UxmclErwoT/zn+005gk15DdPk47jHZt3eC+kDV
2jGXna2rmrQJresme/TCs9sMxtmgaebToHedmS6kacHqO+241lqBNWWPdqpPrSUSdijOcnFUY165
AcAWLQ023mp8Q7R3/IfwM7jr3V2B7/7Lu6iywnILgac9vcYILyiCwUz+Fk4wkVJkQclIZdWM6Jue
Bww48xrogk0UoGWo+5jZjlniBRZ7675PaJ3H9lB1dKRV+SNTCzQzxVn3NbppEdZEu1hzrBMH58G8
OAYVLsNIjAijCmweiBROiXIClzQ/Y5As3lYi5oSnKsLX/BMXEN3wgscZe5X4dWWN8ygBlcVpnCH7
JNZGMxp3/g39bJkSmNw//RiK59mwddNAhsp3DLGpbRsHT2mWOoFLkevaUUcrtZNXurmcyqGAVHGr
N7qWOOB8yRZ5bRjcJ7WL4vP2oH8SmRBXpnRbp9BqGLDWqYeCOZeZEhblr3ib8M2AzVApGwqYPE9V
FtBFFBYcAmNru04UsKRogW4MTTvhNx21XbVCWbkvBvfQflRzVbqGHMD4BbBa7jjDzlqETwYFD5tw
EuwyEqKxzEOZGAj2UckOuesCyg0IvttIo62e6EnGGD+U1QpstwYnEqcWNe4aep2zdnhDnl/cQk3B
3u5+bkM4OhC0N9vufB0fezcbEguGcGxZWh/16QVmuWSCakVhNTdOKewVfDM0uK5crsUfX/ZdJQfl
NyZpDClsSKwl3sT0SXhoDebbOr8SaUlOUgKOHjtAXbh55BO5Ccr8a4tf4JBGF4pa4XuSuGD6E6BP
1qxr5sV/VxFOqpAF7wfJZNIXPUQUgL8gQoaRmHZyD1aTGzf6SfAoGeSKrWHURzyC8N9cc+KznJd/
1H0QG1O2fSC3iSWeSi7wyXzMLFYgJH6Nv0jh4+1fjQCWrqOmqDUXTcaRSYUPAt3dqFVnGEoAUdne
mlPDh/vp+RI1c86ZFZq+2sTC54rF+NM5HrrMxW+2gJEH4/CgzYE8I4Qw21Hw5uqTCCss6wwhc24m
smlMjM3XYh9jFc4EIsy9pi0sETDbhOLMmN9oqFxvrRJXhqRfhuzg/miG92Jxk7mezlXect0UGhiw
klpsJ/lXblUGCoXgDaFjgXTrDTx0E/06p7ActE4rbI/udUdPnH2OuXM+RKUolxcVzFbCEBP+HNp6
o98qsMyPbh6MSEINlVjVev+B2efIh3wpnHMBUF/IuDCJtnBOmZlIC3zOOXFLoHxHd8v/K2C7TxNo
/gJP5ld0rxu9ArfSuxXuWTEdGF3Cg+o2doZQkqFukpdzhcplVBa537dBI0rc3gZ2VtRsn+xo11J7
ijb3+afYVEXq63Gwu19V3v/XSbS8j2HFKR5Y5FPS0l0tk4M+zwq91+h/6M925elUZBaV2AdYMasn
PvG3hShoYzyZz8HHxBRdeYLt7hUfJ/ROiiGEU5yMJsvXUcNAeSLtOUddeEughSMwJZcT2ZAtZ/KU
NHT5VpkDZqH8Kr1l4dTYUDcWtN264iJ0U2s4ouFojgNQv+uGElWRXvS5xudpbTP1zy8S4Led+SIy
2OfNb1sxyTgfEVFHVmjAC5HgR78+7pgMdn68VNwPLXDlxLXiOQdx6PYS25wGrVTXApSAkce6ndDP
zX2mFZDpVip+k5pZY7U9+e9lS3SSndH55t0Kdk0hdF7lHl97siR04nvbWFZKsy/OnFCgQlKEsljr
fYB7OdycGfL3ET5TVu6/CLTHHRdlXItz5xKXAha8I1dDpmH9dDraFncXrk9h77SOBjV9TUSaIYrV
octaZaAQtZdUYqChklc9MjkXvFA74QuaInST83Vv7+fQyEiwRJkFIDl/rcsHBtSVznc4s0fJ1AP9
Z3gisirvqd1s3FAw79BXCQJDuLy53lI7iN2227VG+N2z1Hu7e6axN0jDvSKJsYPZRCxhv9z0Egma
JOHQbcNv9WuD6Y/0hi2+oED2M0pxxKd+8yCHHeyhtHYrmF3R01iL91djVKjZTKs+3icUtbpZdDIq
LqLKdaQiTg5cDt/h8uotTkj8bypX5oqGJcgG0BfZrm03Vj+Z7PADDfZlauBUTZre5gOzg/eFL0fB
vaba8cALzk3o+fMiETIAGdvL47B7PN882ASgcsZeC/jH3OR/xaMcdslE6pb9jKmpaPqxdTaHMJEa
FcCNAEq5Ynu67nc4a/+ZSfb3CKYKeA2vsm/jdn/Vh57+T6JRmnz7TVMZ+1WgelfBsff7uS3edCHY
kIJNUGTyjuccJ1rq9wJXy4ZALev0Oeam4NV2iVPwIcdUT/v6+ePHXk6vdFYQ5pF+L9QQpXMjlTGW
nnHLh/+TFLVgPQvu8BJWzK4cY2bxP4p2CIn3A3ksaYrPty82Zw/a5VlztMxtO/8locSmOr3ig+Fo
ev5jDWltQcshbw2z2L54Wm/4qr5gLxKNbhbUSX6zqzCK6OY/8x1/AAyktdOklGjUVKPuDbfP1fPS
sQRkcKRFCOaPwz9pZklDyzgMCCei+Ns7Jw1skHXWfkbyoj5XpavaXsdbpukcDePW112XczV1AMIV
VweNchQUZYXDncXyL8fLFt494/Tv9kjV/hDt6DvzsxMCHSsrjWGYYx9hWG5XXfe3zhLwUXnkZMPi
yrTjMvIN5PBu2mBYT45tGzbzimmlFPwQfZ4nGau9WHFQYEM0S05bGmlGn5yTXNFFDEMYcbeKLQ2w
wwHXswzfjMBn8xka/WyB+zGrD07VCmyx9xvHdQjungIkk8cW7UXZzI1iK+JE005c/0WJ35+zQ5wM
aBKlDJPONSVTWgSH2vhuq6gDbvYCNSuNkHWdPPpKcjS4Y+JyY36RprciiE8qMJiuM5sMWjfnm0iR
02YM8nTf3r1Az0JdO0tNTtOKnI68WvkafQhLWy0gg5oWsqtJc24W48div5hpqtW13tPsk+vJhyZr
tXLK+p4VtoHRlVhvN7uzqWa7nIuwyms7YwuhBPL9gjlZBYxrvBveRNDfzLx/UzDHoLwZHiDOkO6P
xHvtn7W0Gfol73eERQ7NEh7x7xRvB8rLHh5OBb+yHibYgYxQr1m9G8U044G+Xmms2MuAhLMUTuax
1c4hWZFzs3XIfxha9nKnE37SYBeBpEKfC4TWbZ4fhcjGx3CLhB+RyWh0ZF/V7wD9dpe9oP/B5ec0
0WbRlIxozOZYgGDnCim+S4Feahwcydw008rWFBccekeGs8qibijUmmvRe3z2jh4XJOLK/ZrPyP3w
/q7n9uRmYCPaWpT99kd8EuCDNi3HDH8nD0hc8PRPg/NGBcL79q2+xkPhmNczaC9sf/NFGZCBZUXP
m7yMLUByB5xgMU7Wn1NyEA==
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
