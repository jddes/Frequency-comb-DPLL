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

kddc = 44948035343483

t = time.perf_counter()
for k in range(int(10e3)):
    y = (k*(511*2**48-5*kddc*640))//(640*2**48)
t2 = time.perf_counter()

print(t2-t)


Ndecim = 6
Ncycles = 208333
Nbits = 14
f_LO3_over_f_ref_num = -(511*2**48-5*kddc*640)
f_LO3_over_f_ref_denom = 640*2**48
f_LO3_over_fs_num = f_LO3_over_f_ref_num * Ndecim*Ncycles**2 * 2**Nbits
f_LO3_over_fs_denom = f_LO3_over_f_ref_denom * 5

k = len(phi)
print((f_LO3_over_fs_num*k)//f_LO3_over_fs_denom)
t = time.perf_counter()
phi_ramp = np.zeros(len(phi), dtype=np.int64)
for k in range(len(phi_ramp)):
    phi_ramp[k] = (f_LO3_over_fs_num*k)//f_LO3_over_fs_denom
t2 = time.perf_counter()
print(t2-t)

with open("I:\\Data\\Phase meter data\\40 MHz 9 hours\\out_phi1_ramp.bin", "wb") as f:
    f.write(phi_ramp.tobytes())
    