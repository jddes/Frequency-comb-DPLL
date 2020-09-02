# This file contains function to find the M and N registers of an
# integer-N solution to setting the Zynq MMCM that drives the ADC clock
import numpy as np

def get_integer_N_solution(f_ref, f_target_adc):
    # objective is to find closest solution with ADC clock below or equal to the nominal 125 MS/s
    # f_adc = f_ref * M/N
    # subject to the constraints for the divider values and the VCO limits
    (f_out, M_ar, N_ar) = get_f_out_possibilities(f_ref, f_target_adc)
    (M, N) = select_closest_M_N(f_out, M_ar, N_ar, f_target_adc)

    f_adc = f_ref * float(M)/N
    f_vco = f_ref * float(M)

    # print("get_integer_N_solution(): f_ref=%f MHz, M=%d, N=%d, f_vco=%f MHz, f_adc=%f MHz" % (f_ref/1e6, M, N, f_vco/1e6, f_adc/1e6))
    return (M, N)

def get_f_out_possibilities(f_ref, f_target_adc):
    # partly following equations 3-6 to 3-9 from UG472
    vco_min = 600e6  # these two values are from DS182
    vco_max = 1200e6 # these two values are from DS182
    M_min = np.ceil(vco_min/f_ref)
    M_max = np.floor(vco_max/f_ref)
    M_ar = np.arange(M_min, M_max+1)
    N_ar = np.arange(1, 128+1)
    M_ar = np.repeat(M_ar, len(N_ar))
    N_ar = np.tile(N_ar, len(M_ar)//len(N_ar))
    f_out = f_ref*np.divide(M_ar, N_ar)
    (f_out, M_ar, N_ar) = eliminate_out_range(f_out, M_ar, N_ar, f_target_adc)
    return (f_out, M_ar, N_ar)
    
def eliminate_out_range(f_out, M_ar, N_ar, f_target_adc):
    ind_invalid = np.nonzero(f_out > f_target_adc)
    M_ar  = np.delete(M_ar,  ind_invalid)
    N_ar  = np.delete(N_ar,  ind_invalid)
    f_out = np.delete(f_out, ind_invalid)
    return (f_out, M_ar, N_ar)

def select_closest_M_N(f_out, M_ar, N_ar, f_target_adc):
    best_index = np.argmin(np.abs(f_out-f_target_adc))
    M = int(M_ar[best_index])
    N = int(N_ar[best_index])
    return (M, N)
