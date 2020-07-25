import numpy as np
import time

t = time.perf_counter()
with open("I:\\Data\\Phase meter data\\40 MHz 9 hours\\out_phi1.bin", "rb") as f:
    phi = np.frombuffer(f.read(), dtype=np.int64)
with open("I:\\Data\\Phase meter data\\40 MHz 9 hours\\out_timestamp.bin", "rb") as f:
    ts = np.frombuffer(f.read(), dtype=np.int64)
print(time.perf_counter()-t)

dt = ts[1]-ts[0]
# dsamples_

print(phi[:10])
print(ts[:10] - ts[0])
print(dt)





def generate_3rd_lo(Npts, f_LO3_over_f_ref_num, f_LO3_over_f_ref_denom, strFolder):
    Ndecim = 6
    Ncycles = 208333
    Nbits = 14
    f_LO3_over_fs_num = f_LO3_over_f_ref_num * Ndecim*Ncycles**2 * 2**Nbits
    f_LO3_over_fs_denom = f_LO3_over_f_ref_denom * 5

    k = Npts
    print((f_LO3_over_fs_num*k)//f_LO3_over_fs_denom)
    t = time.perf_counter()
    phi_ramp = np.zeros(Npts, dtype=np.int64)
    for k in range(len(phi_ramp)):
        phi_ramp[k] = (f_LO3_over_fs_num*k)//f_LO3_over_fs_denom
    t2 = time.perf_counter()
    print(t2-t)

    with open(strFolder+"out_phi1_ramp.bin", "wb") as f:
        f.write(phi_ramp.tobytes())



# 40 MHz input
Npts = 3242891 # number of points to generate
kddc = 44948035343483
f_LO3_over_f_ref_num = -(511*2**48-5*kddc*640)
f_LO3_over_f_ref_denom = 640*2**48
strFolder = 'I:\\Data\\Phase meter data\\40 MHz 9 hours\\'
generate_3rd_lo(Npts, f_LO3_over_f_ref_num, f_LO3_over_f_ref_denom, strFolder)

# 1.1 GHz input
Npts = 3596950 # number of points to generate
kddc = 42221246506598
f_LO3_over_f_ref_num = -(3*2**48-5*kddc*4)
f_LO3_over_f_ref_denom = 4*2**48
strFolder = 'I:\\Data\\Phase meter data\\1100 MHz 10 hours\\'

generate_3rd_lo(Npts, f_LO3_over_f_ref_num, f_LO3_over_f_ref_denom, strFolder)