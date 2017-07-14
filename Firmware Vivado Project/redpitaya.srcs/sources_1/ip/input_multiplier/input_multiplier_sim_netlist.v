// Copyright 1986-2015 Xilinx, Inc. All Rights Reserved.
// --------------------------------------------------------------------------------
// Tool Version: Vivado v.2015.4 (win64) Build 1412921 Wed Nov 18 09:43:45 MST 2015
// Date        : Wed Jun 28 16:49:34 2017
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
k5Bm55k+enNk9fY7I7s3iKOrSEhQfcJ7xTd/Y7RhGQNgWAY0uVa9is5Fy184hPioC6P14h3XynHC
mJ/Kd26gPJYItjWl2n2y+mBrI8TUPK6+t4WPXgwZjhmimrTdV/XxqpBEQzAzmvfJa94jPDlYsHPA
S2RZeOdEjVYIOFWpR6CfaHBnzZ6Vtgr8N2R2Iou1DwsT7AyWGuWOq8qcwn2BkZwE5u2sSxaIIFjL
ZoWDqrUEvWUYSHQGeZoqmPl2x1byysqj7eNiIsRo0nEie5B5CIv5dc9UTTyAhf0GHAOhfkPzZFkm
IJmIcJZpNB0es9Zs/+mWOvgWmT/sXqVCT5fwlw==


`pragma protect key_keyowner = "Synplicity", key_keyname= "SYNP05_001", key_method = "rsa"
`pragma protect encoding = (enctype = "BASE64", line_length = 76, bytes = 256)
`pragma protect key_block
WhwWde1ZWMp6nXgCrgGQy278PpohCAd6QaYDPjaGv1KA6UAUT76GgN9Y4CLDysSjr6zCjH7SSGp2
RIvnjSmUr2h3JOakksEPeDp2pMkVwHLASaAyTPSJRHwicuIveQfwlymWKuPEQwRwpueMu3NO5Aq/
dDj/BW22gN8uf4BJH7rqXBnOad36Kai5i/2fcHcMoJgkrcmeANiZvA6eiKXIo/89ituCEtC+e/WC
pmmXkZZcggXLgvxlZ+s49v+Fqkamrn/LAnHZFmpjl407hTI2bHC2utSO/w9g8DmJsAfrpzPZd51E
Or6Wb2Krq6bnEpkeZ1D/+slU2gWJh8wXEhTs6Q==


`pragma protect data_method = "AES128-CBC"
`pragma protect encoding = (enctype = "BASE64", line_length = 76, bytes = 7248)
`pragma protect data_block
h7JEc4nxGofPFUS8DtasirW8xh8TCDItusCjIv7e+Q+Bmv6xaNCRgSV77Rm4cQL3EukKdahe4qR8
UDvmVcbrx5Oadw7UsTYR/LDu8jgmTy0FFMId4yq7LxtjWlpZazuHRjthCPm5LYhEEPB/iM+bayDY
rQ1vZEQgBJV+9CdgIGfDpH/1CUYk7Ia79+uK7KJjZvaGzc+3DVM8fw1771p+G0LF/uwfv37TZOPo
6G1jDGevvGlxVpavttLDYF3aTNuF2wDtK13+dPCrPL5s3GM4J9M9N5SGvlgCC2NNE32AcM3YswMj
htUvo4M5Okz2dxqEhnNp/cRndhigmWhdt7beeTFyy0l5rlwpAlM2WKjux8xS61gBN5HBPOCRgRY1
avDdvweZwGRKW7J0Z7Qc86ul0HRK7uDjQ+ykX+jlsQ3PComWgx2UP5GrarH9UZgMyKamMvzsVad8
L24x0NnCi1+the1QgbeMWkzg1pfpW9YgiqMlIC6Q8ID34fCtR0yFgmQOA+Cd1bWH+Gm7hpJErKTm
nr2u6xctI8172nEcWDuMpjLukBsFAdvpupfOMFmgnzma4rM+1NalM1i3omiI+IIyFYqii46tvvEn
/joZi6SCXR9o3R/CkjHKrXkII2sPmmp11iYlfw02tw0fBME1/t1qNCoMgB6F+l8ul7fAhxwwV1Ma
+2FUpc7bR4m6X1+DPdUm1LcvGK4LwzNhzwXtcrb7NuNFbiver1vW36R1hW+z6hx47+C8WtfSWQxz
OwJWxJEaYH+mhy2AZUIq1PxAttkDF4z8imXMp9efx7vr9v9MI4HZBgZ4GLBTRFOyzv3MQwcGfq4w
UvUepCmItL0jUveQfpFyf4kyZcQP+63/uszUzMCD7tmf5OpEe4OvEWU74qU2rWSBwvgk5LiJzKB7
kbdsJDUhq9hvjWEcURZXSuxu/avpTRMS9Z6zVALGRKEkgvOAz8L3KZtR1cgr6qqurjjDcZNLtER3
3KOENF1/H2+r0I1gfLa2JNgr95T4mW2x+/3X3sV6q0Gc2tXRRbhsefMuM8qyPHBIv8fwYXtIJWwH
xT3auv38zpqS4X+QQONSgJrzaA29JiisaPFsBCEh0LDDIKBkbzoEPJohPTdPmwrkSujZ3ql658Ou
CLOBQcjTF4cQYRRtrble/+bEoX04xK4bbu63T9vksRTZiytuTTTVUic9u0uHL9pnfpuVrORdTih0
1Hi9E330+EE7AvJF2dmGuYiymmqtKqz2U1QIoevaMqWQPU3KagbjJQfHhF2+vdKpfnwTdB/M4kvq
3Hw80kpdq0sLKaPljM9bK43113nC6VxNClRdykUJ1I8yyrxAynn+/t5VrBp8G1FuyE/vTQRc4EG0
oyIcK3LFGx+JI2yUAwcDWyani5yAzonfgzJIie+kp5rn+H5afSc0uOeedr44sWn8pBOpPl0M+66A
EIn45M09raJgDM6kIyYaqrmPz5lXbFOrZ1crRGcgaitCmIFJgnbxTqxWFiPxl1CvJE72QLPiBqKe
+DFdDVOo/waNGoSHixflTNlGN5k0CDy8ZZgR1xXz4yqLMGecuSpeAPrU2tHHdljlKYCDEDP94osG
eg+oRmJHnLDz8tz6Iz2yEo+4s0WKoqrV/ToIe+foactc5FO3qHMV+1AsIFxFxRdoHYUKPwPSgrVY
/zdUfrZHeEcoZpuR1vTFV6mmrpg2FpdDd203DZootXHg2qsJjKRwGbXVE8RoiW4hM+aRKMqi0pzN
130u+8xRkfD6iNDfQIX1shkELx363+JYrWvC/NySCBVUlhvZ6xUcgYHrYvkBdPTYIJ5ajSytqYsg
WcTO6HTrJ1DpOoIRzibhIHJ8dXcAXxpj43zKJXWmR9VzCpJjMzMIEWJa1EpxtropkapZnLdeVQZh
zw8N+f3v/PhH6I0HZfQokCeIe3T448298zgPFSI1NTkrUMNwo6YvuLssKbx8z3B0Ce9e9r3CezfV
Y7W2sr0CJK5f63Nd9/DTfUQ3S8Occ38Ep7fxLSbRufYuuXVU/ncaXgeU9oKByFyg0fpV23cHngQS
8NVjk5Eo/MN4vl+YCe7il0KX6/HwEyQD8Q1lo2uWA/v9U3/hdl2TkkiInw7sdoB/nC7yO0zweJed
FJuBd8JJswBZAyjr9/PMNx5Juz1vxQIxBWgXQnsfjbtLkxY6ehF0gtM3JnCl4jZI6SB6vtBQ1itK
aPoBCiZ2s21iTJNEHMK/xvj03qAbGLPZmf1WYEDHyGX97w+18rDYJX58b3KekQGhN+dcZNor3xgd
JBV8O8rd1iasE6nKU8TSMJWD3NKnKe+Q1tNOyEiCdZ0cee2A24bIUaH2Ff+MHT8LP2A0UT6KE2Pr
KvAeHRUDi5fffK9Wa1wMGqPdrUVF/4ILSALCpsJ+LMoQF2HxQcyCo1weD+GU2P7gvSpmBj34VHF7
8O6famKudCV7oJNuJnQvOnPCAQb8X9vkwd0ORyRiyyXDLcncHm55GIcEkYkkW+3MB/mThC2jEdtL
nH3Uw0ngIzTJO+7wuhLnW7xtgFqa+GZCGoD82FOX7dI55bFXeZxBf98o5T+D0h7jeQOAtVSOgRPP
r+bvmy0QEXrM2ni4srZdmy95k3Qmjf6YvKcthGXeidl/RCiXzQfJxVehNaWLEFx3jybGbR6W3y99
PMc9XKqdIuicd/tWoOIj2ZwKzfIgo2VueoiqvGnHKKZVwbRxwUXbAX9JebcBb4O8JGrsUx+n65+D
c2cfzZSXvzqyCGE5TyG9oBmA2kBS/52LBjiemu1do4Ub4iSAH2Hbel1L8RHoenIjKFKsBOvdWSy+
zYAb9I+wt2ooegJKwbTwYfy0jw2b702QmPkE8R8nwttnR0LE1/F+Z0msR9pP7BJZfvBBlJHfBKuJ
3Pqhm4PV6ZCkmBhR6JvhyHj9n4MK7IYjZv1qGP5aPTZw71dE6oN+p9INV54SBXiYL5CA7PzPNrKP
CkNOuv5sYtYGYBFNXWu9m3OATWn1ynr7Of89yaj4T+jw1+4FfBYVoO92x/h4phdYDAMOdfwKJ+g4
caw6NDTx2f7/+xANH9TQIYfeLnoFe7H8xq6EmVG3iiDHbzGJa/607celEJm3KCrzeqOcf1Ws0BJL
dcQWH1SJcgqScYMLgSwjD/eXDR1A14xhBx0LiymmbEFC1DTUi+5hlZ3MRF6FqSvnp0TRBTTDKy57
r67vMrFtD1NDoZbmw0nEeHfbw0G39S6zVryVQl6znCds9m+jjfWPFAzy3nCPFAXi+UsLU6i9wL0q
ntddQmKcRfIQ0gzmvaJDY5Afk+G8IkYm85KfosA+kQ7PDvSvCDLkc9EQ4ZtS8j2fJk2dmrO83v8+
91CyKSPGZB0dlhLIZhnHF7Ts4A8FjYSUlKFV0qlswvCJ6VpKhV5nyVDLBuA5UTswEw/6iTGv0fXD
aMc+rju/wOhU8dtgrCRagx2Rp0k+yErI6j5jtJFPZNfyldV5+U6HiqlLkuvJJkGmB7AT/Ze4tA3d
hPC/0aWHjzTq61EiSK9eae2d3CW5SkpG1Pc1F0ZO1RHnP4htKRhoR/5u44i/nGwAIAu/6v9GFhtn
v24pZroM4pUs1rfZjryBd4jm7gogLBrUUHV7gGiqM+H768JZPeMj7vYUrDxlLBoS/AZf4XCe7Juw
NB1S2YAGGZREqGdFu9BkaOab3djn+/Ge7FUIt2J40n3X1VrTC/JdlmWBlEZbSVJ2uijUqe19Ww0z
ZJL3ULPbt5yANGLB9z+V6LrWdVUDLLVlm7Q4V9sjAz9eU1FgXOp2ACBYn04E7USifcz8Yb5I4iyJ
EYWrfS758lfDIKlidaBPtvwsJV4Cr8ZJuDBBC0cCT9B5Kv02m0cl/+sLqRmbMKjj+37E/19/XTzE
abx9SkW3EJZk/01HqtqVTk8aJEA4R2hffI5RDmOp1G29Vk7AwLKEtxdims0GkQNXspTMIMtow0mE
xVmfqQlRvFVEgXzgN7crqbX5OoHuavtinuc8mVCrlmEk7VoPh+Sd7Tvn9Av9QyqG6nR2SwK8BiU4
ZM9zV0M4QzFtHpi0sUzrNSLbDoPO41+DdNg1oaIL6kmn7x7wfs89pN+JBQLTkKCTo/9FGTUvxM1u
g/TosHHDFr9IdYDSFtdIVJABMOkfQN9xWRpsPAKSVmBvnSrFCP9DbAURLEv7snIf8BWWzUaBkrEA
YX5k7uRgRvqQJrdXyWOa5Higo6xaIhfVZJwMHpiOZkhcMlghLTquWfrtyUgD5lU0bN/vJhj6QHq1
yZS7k/FZBgs/ksqaYVroiTpXHJdKAFjdLVAIOGD6mbnwvJFbrJlzJfceF9nb5b/uFc82Wyh3cyJP
TcxuB7hPFy3O8FoKX8fc0cblN79n1ukpOkFjFZXJWYHAS7U/ST9qbonB8Oa9ArsB9hLjAREDyGgR
0tS2mzEuQNE0gZCWTIYAdgs47Dq940YmjHA48pULBRR7qKNBrRJOn4nnG9x67GpoVi3h8/oc0621
BMIkkf1Vb+0Q5RhKBSoEWzQnic70EtA6U3vAvGiVfWXolHE7ilBW4Yt+ZJP0TMwbYcz4GDhQj5sE
z8dRBj5skuH9ovo7PoPz36OA5lDu0MbTEV21LCy1hZmVYCUBmWFwNQj/Ms5uHRsg6SvadcUofmy7
eeQwXTm8kdvqo0Py2fE28TK9mJP2PcTebgUU1mnICV2hdJnDHdKmuPINZwfKRIYL8naa3w2qBWmU
JLaR+H9UfZCR+4NNFjPwu264kyUCkxo5B+gfQXSOKobMKrRTUOuiT0v8CAdNEbIxVbOoQHi78b87
5RCK5wSeUHbkJ0PdYky1kA1shFGtxYAXR5KESdvt35eFyCeQQZCxOukCbgODtk6PFXF8AeC0Zm9G
xqSnvGeMi8TH3OCt29YXR9kE+xSVp65x7V6xhuZxoJrHU6J2NfsnA8Ly7MOEjPL3CmAkRSoQRpzB
itHGfeaZK68DtQ0aFOivUpAEgpwzA8cKf5BDEndjaS64FWyi+IrGjJ2nYEg+ntbK0LMIUsRRlscv
m5FPEWqVH4Li6yI3A6sUaDVVCqPJ22zMmab7OnQqF88uSBIq6/otseU++ntRShOAskc/WlO4iib9
vUBgdEtAlF+vu6gtCsO2nfg2+PIP3Q1IrTOpxsSmORLDocSvHHJoVyc/mNJOQsMAoS19Qy1yU0lw
5nXQVd9DroRtWPp+c42VD+QCs47tOnQc9Zwz64Q7Imb5bD8vxoGWL3FtmXURNkM4A9ju3MAESgIl
H2tSNtJuopxUcIDyRNX4GVgqCHgpfI7vdi3Hz/Zo46xXcTka39BElz7T/C12RaVHJwuR4ievnprd
Tm4+Qzwl4fqoSIqjxrUGvfBMrnwB89MEChHpBhh7tn1ZGsRMpW9Y1/QXxE5+vKKmFr5Qu6afn+rP
xT80807SreRREqsl8r53JyL8p56dSMKTvZzVio90z66xEIPaBOJhMcYgDULOYPR3w983LxzhG2pZ
kGOFhAZnhti8Nc81ctWXx8zrn0Fw5ygxRtIoGtVwxxRlLCDyemdpKsxerQtwCTWJqZPbUhFDbx/O
f9F/MEHJ3X6baxynMWctE3iawkvHWGXGHrcNg+VJPUe1UOWI2gMRFCZdiRWq7j/kksqnmK1sQZ6L
/7D6ZiK5N7WgvW7TQ5jo5/HfhEFBS9R2yGjSDO7TBYXY17N2frk1nVa9bFYDkijFyvp6bVT9sgJn
/UMLGaRu1/0zDdx9iuaIdrXUWtzL7VEqdljNyxJbBxExTtyvABmXpGkJuTRNL29xAPhlY0R2K7TB
0J3ijWLQWUZ3zwh6C52mEwP4GX04IJoYYOkLKn0/yiJKXQCHRVamdwuQ/NYjyKqPoHsKd8oM2rA3
YfMbzuPu5fBlvnxgNZ+eSNYfS8Q6JEC3sUOHQR8MDTlc7z34WzzUdv2oPGvwRwb/J1piOdZmRuBN
K3Qo+SYZ470JQ8skbQtk3R064iQErS795IaGd51D2FXkb8qXIIwSQ165JF9Oe2OjQHl0HiZdWWys
0A3gt5COWEovLi6VEuu1sjwush7XqgKNHf989ySQwuTjJWZ3orhmKl7lR94jraPhYyOr9mHGSGTR
0zW85R9D2w/cjMLw6xXf2ZmlzikWQrj8rmpLRaF3EWNkF9ZeT1b2C3Pr/oXJM/X/knF8wm4msIbD
jowzmGmUmR2wWjPM73ziN153bFGoFVTN6IWJcvMaNrCMEvA9quXJBwfH05woLIhZlrAs1GATP2Yi
+y3APRSBoz8kbnIUWCuY2+TwVN0YCM4QOPtIUnnBhBZkvTziXVl4MK8xcTg88tGPx8n07Fblzu+h
YpePJP0OGPLKu5n86HG/ms3HhelZlVE/Bip3siRoPq5oSzXfvGdzzmWJ4lkG5Jg5uQo7IdzfJlnS
y4VXKA1R9NXJcCOYXpkG7U/msqmw91H4zPXGDNDgnt3wLePVIaeffpEq1XGaR/K9UIc+EZCZowdF
/9kByrjVAVdd1piilShuDDp7g6JoLRou2ZDppo3NYgfAoWZigNZrUQuipCJsY0IYtLKQG46QLm71
gMJajl7zvx0SyKfOytNYLZadMyk+QjeJRBeUD19RqBNtYcQwlXS1CVtczXlQWY9D48Lyrv9MrCwI
2JR4PT+YQTD1U/WKv5Q9N5gUGTmSZS5pNeEBpgvwsZotetDN1cQz+fvixZVxIzSywfLIUaULPlk0
0bmHjQYp2isZAOTziPRhvUSerOm3tGkPUuQrGoQyjPsMEdPgHZUQPTlqRFGySFNAv8zge09W1EDv
sbkbHUmED/sR7X5gVo404vI+BvaCN011qiBGp2UYo/6pjwFkK9TZ2n1jkFZEjzX5/zRqzf/ZCreL
Axbs2VfeiesUnj5eSgwpmqRLjs7X3AmptcEaLSLCcfEVDAjHckUsG3QzP509EdNnxJZYgTeahceB
fmX+b0Ru+5RtYMTyk4AF81Xke7d3/7/hRgtxWS6OKPihpsZeOzF/axiawHNQ/mVbpMNg6vHb6CEk
jyDGU1hOt6ilF8R6OsFvmnC/vKnQVEnzBnAiK+3paiTGNg3CYUD9QecMvzJt09DSpJB8x7OQFQNf
2w4EkyTD4e45ETauUk9Ld1NjmdM/uxL7puc2cF7iUg0+JZ/z50cyYkba8ierqx2UWN/m6b66mFYf
km3D2MZ/P6+V/Zn24jgBqBUo2TmhpBSFijW0yTIK/2r75XrfZPrmjqBjzpK+SwClLfDinI+8WcMs
4w7UjMXhwws9l800hej2lDErme6P4tvJT518NjxO+nuVYyCm55dBke4sZd3SaEgB2QQHSU20/2i/
c+r+1oV8trjjZGiMX/bWiZEIH/9xradZW/CMpDF27vSdz+8hRbKS2kIBfxJafBGCBRde2DvgmvV4
i8ni4VL5kmlEn9yvG8XmY5eSQRarhjR1Zmoi+hwPi1Er5mD8Fo/OaO051HDvLy0YMv2MCL4MrKcT
RFZcsro/9/CAm9FLdM5sPOj6vmOl+KU3fdTXbQEakYUZAV6H/yaiK9xhflMtW0WZ+24xvgX6xO+Q
J425AKAWmPIHKK/Ow1Qrw1bpAhkW84pmdr9wUfb4VKLvrJJCmY0gseP2tYxNqDRISFN4cMe6AmSI
KxNX5vLUdiuBCe7hQ/pEGwaJrO4TlKfOfhHHgLJqeoc3ZCmtRre5F7GfBGa0ZF18k7LD9hkVcJUh
/snpxjm1Z9/7VLOfUh2u831F0BkUrqaGuBo9FV9m7KiJGC0KPWnCnUvDJBHDf3oYengNfaUl8Sld
hMSNiiFhPUrVReVLH3ogtF7tm0hGfZTGFc/x2jUDHDohrpBpGGa5ug30JY3bsWsV1kJuthHpVWxB
S2TpmdNtpaZOX5n0uCltDHdX0SNWDUjcdosCtnjf0N6mRLaGyEa1NrfnZ7sPgBqkuNWWCMjmiriy
PU3TvuPTrOSRAz0Sts7IMEtK9/n1NMBRhJqvxk29rS+NnOn5xgz2jH5eooAMD6lZtpI7/roQ+kIB
1prxyuPJi01dA46tYpvo55EQh8DVJROlGHi9tBDtPAUaxtNECyK7EVBt332Y9pLBbCtVVwzq2prL
KSptcL/OH6afh56uID+1a1Jo9o3gXxiiVWJZy9/yiV2fz7rrkN9m6VZ+gEqkGky2tSHuZ+H7Ohqu
rStONCV/N2BJ9L4zHrirQqYJMfyWAE94IYHespvYfGxa0VwdHwAZxAqNxPODkvVFT6lJhIiZrECe
I3XtkRxcSlgnz09H6egGsqL8MkUEttcu9krcTUuWlydv/u5iKzCelFZ8NL+cFvF8hhPTCUz0vf35
AWBGlW7OnMC0Zv8QZonjc/ynA2h54v8BLZdpM7fKdJ7NArEJlBkw8Q6fXFp3XrY4RK5bxGemfjDT
J4g7bx0zJBMh4SfgtDut2xO7UbSg++5rvoWIw4vYILmB1SYHeavyCHJDonhvt/SO6Nb2jtQTIxfD
ShOpWUJKVKzjdWa3iQc63nuC9MkFax/z2PXqMYe0HfLO3ELwd/lyElsMsy+EKS0Nb+gcvevILD0b
wWsV+cNA+Ac86KfhWB0jbJgs03ITUvWkFRcjR4jWYGAoAHZFk3Rt7M+gqe/Mk7K2VFHkbSbFS6/r
r3N3Sv7/qllpIySD7+7VD9cbpHoz/1Fr1+ZTbcTOtISvBGLOFdedo+I8YpkHEdqUsY3yaQZfJmkr
JM8skfLKyJ3mD4l49OPVTMK/QxX2oS1tgxeTCkdchIzmXEleZzvr6EGmnJDgdzOxs4Cdkfsj6/DU
cCFx5FJ+1TTa9Gj9W9/wCnf0AkgOP40c1u8imErSayv2vO/34pjbG/5Z4+MAbJtxTts9u7+yboXi
qGoopKxr3vfGxMT71G5HbfOH50nsk+bklvMih1Z/WShntO2CTodq7DgFM1BVPWJtHm5t0BzLoMPO
is8CRkHbqcnHIMt0em0b6TRThs7TOg7Q8wSRWcA1V0mDy2TswZmpExavHdGsZFMQTPJ7JPioUnJv
+r75QpcTq550kyOsm6mhrY3DXysw45LuCupo6RP6LSq+ViyEEK/2zdC23gKlROCRw5gjswFnzRha
/JfKjT11qJ4j30g6Hs/hdQcd1TebQuELFr6/TSDKkC6oGDadV4LlDcC5h9RYfwqnPeI3kWqIs9HE
M9a1U824v6kdv8tuRI8Y+V7nNjbURC+JDWN8/Vs31eybpvH4mfpgUHPCa9PB0Q1Tn3Cw/BmCzkLd
mKsHDfNio7u1eMqZCZJhhlXZRtyEDI2QvyFQSjw6dEcbbc27lkQ/7SjlbgZM6T/IU9RvTR2fkv1S
eXxMII6wIc+Bv9kN0y6iLAByX0EwDlnoRUSZIKqhm2TApEuF1LkmDl7zj7MZKDYw3wQxsArdEpdo
YgrWEanM/Q9P6RrIEI+Ge5eeDViFM7IrZbc3v8VLLEUqeqACIKqZXRNJNbBo1jX/yK4iLrzPqXLA
GbEYwuFQ9xKnc5Nn0Hod81MdNFvkxrfOjiONRCEpQ+APOHUG2ctBaOajrJ9DUGT/0YpvMJtT4DPc
h27iPv85MvQ4Ijmoh+4o9ih+aMTaR5+OqXYNRsS7TldwM3x+y5YBg6DbwHnOYabQjPSWntou6PpX
EimOV93HoWSHuFyphmse8lK7lKRQP4HWiCTpYn1yz3hlPDhwDSeWrw8ZNfKZ6QrYfXlk9CUyd3Cn
oxR1fiZeqO5r
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
