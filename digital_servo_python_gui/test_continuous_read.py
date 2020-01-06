import time
import numpy as np
from SuperLaserLand_JD_RP import SuperLaserLand_JD_RP

def save(data, ch_id, index):
    f = open('c:\\data\\test%d_%d.bin' % (ch_id, index), 'wb')
    f.write(data)
    f.close()

def setup_synth(sl):
    output_select = 1
    modulation_frequency_in_hz = 10
    output_amplitude = int(round(2**15 * 0.5))
    bSquareWave = False
    bEnableDither = True

    # This is only really to set the dither
    # we don't care about these values:
    input_select = 0
    number_of_frequencies = 8
    System_settling_time = 1e-3
    print("before syst ident")
    sl.setup_system_identification(input_select, output_select, modulation_frequency_in_hz, modulation_frequency_in_hz, number_of_frequencies, System_settling_time, output_amplitude)
    trigger_dither = bEnableDither
    stop_flag = 0
    sl.setVNA_mode_register(trigger_dither, stop_flag, bSquareWave)



sl = SuperLaserLand_JD_RP()
sl.dev.OpenTCPConnection("192.168.2.19")

setup_synth(sl)

# setup continuous read mode, and correct decimation settings for ~1 sec for each wraparound of the buffer
N = sl.dev.MAX_SAMPLES_READ_BUFFER # [samples]
T_wraparound = 1 # [sec]
N_ch = 2 # hard-coded to 2 in the firmware
# T_wraparound = N/(N_ch*fs/D) => D = T_wraparound*fs*N_ch/N
decimation_ratio = round(T_wraparound*sl.fs*N_ch/N)
sl.setup_write(input_select='ADC1decim',
               Num_samples=N,
               decimation_ratio=decimation_ratio,
               bContinuousWrite=True)

bStarted = False
for k in range(30):
    if k == 10:
        sl.trigger_write()
        print("Started")
        bStarted = True
    (logger_write_addr, logger_loop_counter) = sl.read_logger_state()
    print("t = %f sec: write_addr=%d, loop_counter=%d" % (time.perf_counter(), logger_write_addr, logger_loop_counter))
    if bStarted:
        t_start = time.perf_counter()
        (ch1, ch2) = sl.read_continuous_samples()
        print("comms: %f sec, len(ch1)=%d, len(ch2)=%d" % (time.perf_counter() - t_start, len(ch1), len(ch2)))
        save(np.ascontiguousarray(ch1), 1, k)
        save(np.ascontiguousarray(ch2), 2, k)
    time.sleep(0.1)

# stop continuous write and check that it properly stopped
sl.setup_write(input_select='ADC1decim',
               Num_samples=N,
               decimation_ratio=decimation_ratio,
               bContinuousWrite=False)
print("Stopped")

for k in range(3):
    (logger_write_addr, logger_loop_counter) = sl.read_logger_state()
    print("t = %f sec: write_addr=%d, loop_counter=%d" % (time.perf_counter(), logger_write_addr, logger_loop_counter))
    time.sleep(0.1)


sl.dev.CloseTCPConnection()

