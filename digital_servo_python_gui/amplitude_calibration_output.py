import socket
import time
import numpy as np
import sys

import SuperLaserLand_JD_RP

# connect to Siglent SSA3021X,
# measure the DDS's output amplitude vs frequency

def getline(s):
    result = s.recv(1)
    while result[-1] != 10:
        result += s.recv(1)
    return result.decode('ascii')

def send(s, text):
    s.sendall(text.encode('ascii'))

def getAmplitude(s):
    line = getline(s)
    line = line.strip()
    return float(line)

def main(freq=None):

    sl = SuperLaserLand_JD_RP.SuperLaserLand_JD_RP()
    sl.dev.OpenTCPConnection("192.168.2.41")
    sl.setDDSclockPLL(ref_clk_Hz=25e6)
    sl.set_dds_unlimited(1)



    s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    s.settimeout(1.0)
    s.connect(("192.168.2.17", 5025))

    # send(s, 'IDN?\n')
    # print(getline(s))

    print("fs = ", sl.fs_dds)

    if freq is None:
        freq_axis = np.linspace(1e6, 2e9, 1000)
    else:
        freq_axis = np.array([freq])
    # freq_axis = np.tile(freq_axis, 3)
    amplitude = 0*freq_axis
    for index, freq in enumerate(freq_axis):
        print("Setting freq = %f MHz" % (freq/1e6))
        send(s, ':FREQ:CENT %.3f MHz\n' % (freq/1e6))
        sl.set_dds_offset_freq(1, freq)

        send(s, ':INIT:IMM\n')
        # the instrument's sweep time needs to be smaller than this, otherwise we get all the same values
        # the instrument seems to have odd rules for picking the sweep time in "zero span" mode
        time.sleep(100e-3)
        send(s, ':CALC:MARK:Y?\n')
        try:
            amplitude[index] = getAmplitude(s)

            print("amplitude = %f dBm" % amplitude[index])
        except Exception as e:
            print(repr(e))

    print(amplitude)
    with open("dds_output_amplitude.bin", "wb") as f:
        f.write(amplitude.tobytes())

    with open("dds_output_freq.bin", "wb") as f:
        f.write(freq_axis.tobytes())

if __name__ == '__main__':
    if len(sys.argv) >= 2:
        freq = float(sys.argv[1])
        main(freq)
    else:
        main()