from PyDAQmx import *
import numpy as np
import time

# Configuration values:
#Total_acquisition_time_in_seconds = 3*24*60*60
Total_acquisition_time_in_seconds = 1*60*60
Total_acquisition_time_in_seconds = 1
#Total_acquisition_time_in_seconds = 120
bSaveInMemory = False
bSaveToDisk = True
strOutputDirectory = 'C:\SuperLaserLandLogs\data_logging_NI_DAQ\\'   # must exist, must end with a backward slash
strDevice = 'Dev1'
strChannels = ['ai0', 'ai1', 'ai2', 'ai3', 'ai5', 'ai6']

strInputNames = ['Blue CEO', 'Blue oscillator', 'Orange CEO', 'Orange oscillator', 'IGM blue monitor', 'IGM orange monitor']
voltage_to_power_conversion_factors = [7.5e3, -10e3, 7.5e3, -10e3, 10e3, 10e3]

###############################################################################
# Stuff pre-computed from the parameters, or configuration values that shouldn't change
fs = 8e3
N_points_per_block = 8e3
N_blocks = int(np.ceil(Total_acquisition_time_in_seconds/(N_points_per_block/fs)))
buffer_size = 1000e3
N_channels = len(strChannels)

###############################################################################
# Declaration of variable passed by reference
taskHandle = TaskHandle()
read = int32()
data_small = np.zeros((N_channels, N_points_per_block), dtype=np.float64)
data_all = np.zeros((N_channels,0), dtype=np.float64)

try:
    ###############################################################################
    # DAQmx Configure Code
    DAQmxCreateTask("",byref(taskHandle))

    # Create all the input channels    
    # Values possible for input type (4th parameter):
    # DAQmx_Val_RSE
    # DAQmx_Val_NRSE
    # DAQmx_Val_Diff
    # DAQmx_Val_PseudoDiff
    for strCurrentChannel in strChannels:
        DAQmxCreateAIVoltageChan(taskHandle, strDevice + '/' + strCurrentChannel ,"", DAQmx_Val_RSE, -10.0, 10.0, DAQmx_Val_Volts, None)
        
    DAQmxCfgSampClkTiming(taskHandle, "", fs, DAQmx_Val_Rising, DAQmx_Val_ContSamps, int(buffer_size))
    
    ###############################################################################
    # Open output files:
    if bSaveToDisk:
        strOfTime = time.strftime("%m_%d_%Y_%H_%M_%S_")
        f = dict()
        for strCurrentChannel in strChannels:
            f[strCurrentChannel] = open(strOutputDirectory + strOfTime + strCurrentChannel + '.bin', 'wb')

    ###############################################################################
    # DAQmx Start Code
    DAQmxStartTask(taskHandle)
    start_time_all = time.clock()

    ###############################################################################
    # DAQmx Read Code
    for k in range(N_blocks):
        start_time = time.clock()
        DAQmxReadAnalogF64(taskHandle, int(N_points_per_block), 10.0, DAQmx_Val_GroupByChannel, data_small, int(data_small.size), byref(read), None)
        

#        data_small = data_small.reshape((N_channels, N_points_per_block))
        if bSaveInMemory:
            data_all = np.concatenate((data_all, data_small), axis=1)
        if bSaveToDisk:
#            print('Saving')
            k_chan = 0
            for strCurrentChannel in strChannels:
                f[strCurrentChannel].write(data_small[k_chan, :])
                k_chan = k_chan + 1
        # 
                
                
        ## Display information about the input voltages:
        strPowers = ''
        for k2 in range(len(strChannels)):
            strPowers += '%s: %.4 uW' % (strInputNames[k2], 1e6*np.mean(data_small[k_chan, :])/voltage_to_power_conversion_factors)
                
        print("%.1f seconds: Acquired %d points. %s" % ((time.clock()-start_time_all), read.value, strPowers))                
                
        stop_time = time.clock()
#        print('Elapsed time = %f sec' % (stop_time-start_time))

    
    
except DAQError as err:
    ###############################################################################
    # Error handling
    print("DAQmx Error: %s" % err)
    for strCurrentChannel in strChannels:
        f[strCurrentChannel].close()
    raise
    
finally:
    ###############################################################################
    # Cleanup
    if taskHandle:
        # DAQmx Stop Code
        print('Stopping task')
        DAQmxStopTask(taskHandle)
        DAQmxClearTask(taskHandle)
    for strCurrentChannel in strChannels:
        f[strCurrentChannel].close()

###############################################################################
# Display if we have all the data in memory
if bSaveInMemory:
    figure
    for k in range(data_all.shape[0]):
        plot(data_all[k, :])
    title('All data')
    