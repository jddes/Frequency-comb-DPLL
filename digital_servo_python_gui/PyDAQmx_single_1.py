from PyDAQmx import *
import numpy as np
import time



class NIDAQ_USB:
    
    def __init__(self):
        return
        
    def stop(self):
        ###############################################################################
        # Cleanup
        if self.taskHandle:
            # DAQmx Stop Code
            print('Stopping task')
            DAQmxStopTask(self.taskHandle)
            DAQmxClearTask(self.taskHandle)
            
    def __del__(self):
        print('destructor')
        self.stop()
            
    def initialize(self, strDevice='Dev1', strChannels='ai0', Total_acquisition_time_in_seconds=1, fs=8e3):
        self.N_channels = len(strChannels)
        self.N_points = np.round(Total_acquisition_time_in_seconds*fs)
        
        ###############################################################################
        # Declaration of variable passed by reference
        self.taskHandle = TaskHandle()
        self.read = int32()
        ###############################################################################
        # Allocate memory for output:
        self.data_all = np.zeros((self.N_channels, self.N_points), dtype=np.float64)
#        buffer_size = self.data_all.size
        print(self.data_all.size)
        try:
            ###############################################################################
            # DAQmx Configure Code
            DAQmxCreateTask("",byref(self.taskHandle))
        
            # Create all the input channels    
            # Values possible for input type (4th parameter):
            # DAQmx_Val_RSE
            # DAQmx_Val_NRSE
            # DAQmx_Val_Diff
            # DAQmx_Val_PseudoDiff
            for strCurrentChannel in strChannels:
                DAQmxCreateAIVoltageChan(self.taskHandle, strDevice + '/' + strCurrentChannel ,"", DAQmx_Val_RSE, -10.0, 10.0, DAQmx_Val_Volts, None)
                
            DAQmxCfgSampClkTiming(self.taskHandle, "", fs, DAQmx_Val_Rising, DAQmx_Val_FiniteSamps, int(self.data_all.size))
            
        except DAQError as err:
            ###############################################################################
            # Error handling
            print("DAQmx Error: %s" % err)
            raise
            
        
    def triggerSingleAcquisition(self):

        ###############################################################################
        # DAQmx Start Code
        DAQmxStartTask(self.taskHandle)
#        start_time_all = time.clock()
        
    def readData(self):
        ###############################################################################
        # DAQmx Read Code
        DAQmxReadAnalogF64(self.taskHandle, int(self.N_points), 10.0, DAQmx_Val_GroupByChannel, self.data_all, int(self.data_all.size), byref(self.read), None)
        return self.data_all
#        
#        
#            
#    

#
################################################################################
## Class test/usage example code:
#
#
## Configuration values:
#
#Total_acquisition_time_in_seconds = 1
#strDevice = 'Dev1'
##strChannels = ['ai0', 'ai1', 'ai2', 'ai3', 'ai6', 'ai5']
#strChannels = ['ai0', 'ai3']
#fs = 24e3
#
#nidaq = NIDAQ_USB()
#nidaq.initialize(strDevice, strChannels, Total_acquisition_time_in_seconds, fs)
#nidaq.triggerSingleAcquisition()
#data_all = nidaq.readData()
##nidaq.stop()
#
#figure
#for k in range(data_all.shape[0]):
#    plot(data_all[k, :])
#title('All data')
#
