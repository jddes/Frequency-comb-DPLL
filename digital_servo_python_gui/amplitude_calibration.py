import socket
import time
import numpy as np

# connect to Siglent SSA3021X,
# measure the tracking generator's amplitude vs frequency
# with a coax doing the loopback between the TG Source and RF input ports,
# then the user moves the coax from the spectrum analyzer's RF input to the frequency counter's input
# and we redou the sweep, measuring the amplitude through the ADC data

def getline(s):
    result = s.recv(1)
    while result[-1] != 10:
        result += s.recv(1)
    return result.decode('ascii')

def send(s, text):
    s.sendall(text.encode('ascii'))

s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
s.settimeout(1.0)
s.connect(("192.168.2.17", 5025))

# send(s, 'IDN?\n')
# print(getline(s))



freq_axis = np.linspace(40e6, 2e9, 1000)
# freq_axis = np.tile(freq_axis, 3)
amplitude = 0*freq_axis
for index, freq in enumerate(freq_axis):
    print("Setting freq = %f MHz" % (freq/1e6))
    send(s, ':FREQ:CENT %.3f MHz\n' % (freq/1e6))
    time.sleep(100e-3)
    send(s, ':INIT:IMM\n')
    send(s, ':CALC:MARK:Y?\n')
    try:
        line = getline(s)
        line = line.strip()
        amplitude[index] = float(line)
        print("amplitude = %f dBm" % amplitude[index])
    except Exception as e:
        print(repr(e))

print(amplitude)
with open("input_amplitude.bin", "wb") as f:
    f.write(amplitude.tobytes())

with open("input_freq.bin", "wb") as f:
    f.write(freq_axis.tobytes())