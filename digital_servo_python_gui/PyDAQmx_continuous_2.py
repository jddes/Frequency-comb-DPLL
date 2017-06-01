from PyDAQmx import *
from PyDAQmx import Task
from PyDAQmx import DAQmxConstants
from numpy import zeros

import time
"""This example is a PyDAQmx version of the ContAcq_IntClk.c example
It illustrates the use of callback functions

This example demonstrates how to acquire a continuous amount of
data using the DAQ device's internal clock. It incrementally stores the data
in a Python list.
"""


#DAQmxResetDevice('Dev3')

class CallbackTask(Task):
    def __init__(self, strDevice='Dev1', strChannelsList=['ai0'], everyNSamplesCallback=None):
        Task.__init__(self)
        
        self.bDifferential = False
        self.strDevice = strDevice
        self.strChannelsList = strChannelsList
        self.N_channels = len(strChannelsList)
        self.everyNSamplesCallback = everyNSamplesCallback
        self.fs = int(4e3)
        self.N_per_chunk = int(self.fs)
        self.buffer_size = self.N_per_chunk*10
        self.data = np.zeros((self.N_channels, self.N_per_chunk), dtype=np.float64)
        self.data_all = np.zeros((self.N_channels,0), dtype=np.float64)
        self.time_start = time.clock()
        
        self.initNIDAQ()
        
    def initNIDAQ(self):
        # Reset device to make sure that we start in a clean state.
        DAQmxResetDevice(self.strDevice)

        # Create every channel
        for strCurrentChannel in self.strChannelsList:
            print(self.strDevice + '/' + strCurrentChannel)
            if self.bDifferential:
                self.CreateAIVoltageChan(self.strDevice + '/' + strCurrentChannel,"", DAQmxConstants.DAQmx_Val_Diff, -10.0,10.0, DAQmxConstants.DAQmx_Val_Volts,None)
            else:
                self.CreateAIVoltageChan(self.strDevice + '/' + strCurrentChannel,"", DAQmxConstants.DAQmx_Val_RSE, -10.0,10.0, DAQmxConstants.DAQmx_Val_Volts,None)
            
        # Setup clocking scheme (internal clock)
        self.CfgSampClkTiming("", self.fs, DAQmxConstants.DAQmx_Val_Rising, DAQmxConstants.DAQmx_Val_ContSamps, self.buffer_size)
        # Adjust a few settings.
        # This one is to ignore any buffer overrun event (because otherwise it completely stops the recording, and carries over the next time we want to use the dac)
        self.SetReadOverWrite(DAQmxConstants.DAQmx_Val_OverwriteUnreadSamps)
        # Register callback functions
        self.AutoRegisterEveryNSamplesEvent(DAQmxConstants.DAQmx_Val_Acquired_Into_Buffer, self.N_per_chunk,0)
        self.AutoRegisterDoneEvent(0)
        
        
    def EveryNCallback(self):
        read = int32()
        timeout = 10.
#        print(int(self.data.size))
        self.ReadAnalogF64(int(self.N_per_chunk), timeout, DAQmxConstants.DAQmx_Val_GroupByChannel, self.data, int(self.data.size), byref(read), None)
#        self.data_all.extend(self.data.tolist())
        self.data_all = np.concatenate((self.data_all, self.data), axis=1)
        
        # Call the user callback function:
        if self.everyNSamplesCallback is not None:
            self.everyNSamplesCallback()
        
        print(time.clock() - self.time_start)
        return 0 # The function should return an integer
        
    def DoneCallback(self, status):
        print("Status: %s" % status)
        errBuff = create_string_buffer(2048)
#        DAQmxGetExtendedErrorInfo(errBuff,2048)
        print(DAQmxGetErrorString(status, errBuff, 2048))
        return 0 # The function should return an integer


task=CallbackTask(strDevice='Dev4', strChannelsList = ['ai0', 'ai1', 'ai2', 'ai3', 'ai4', 'ai5', 'ai6', 'ai7'])
#task=CallbackTask(strDevice='Dev4', strChannelsList = ['ai0'])
task.StartTask()

raw_input('Acquiring samples continuously. Press Enter to interrupt\n')

task.StopTask()
task.ClearTask()

print('Task complete')

# Display the data:
figure();
#subplot(2, 1, 1)
plot(task.data_all.transpose())
#plot(task.data_all.transpose())
#subplot(2, 1, 2)
#plot(np.linspace(0, task.fs, len(task.data_all)), 20*np.log10(np.abs(np.fft.fft(task.data_all))))
