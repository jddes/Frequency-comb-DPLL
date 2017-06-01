# -*- coding: utf-8 -*-
"""
Created on Mon Feb 24 11:03:14 2014

@author: lcs
"""
from __future__ import unicode_literals
import PyDAQmx
import numpy

class Instrument():
    def __init__(self):
        self.amplitude = 25.0
    
    def getData(self, channel):
        #channel is string of form devicename/analog input channel number i.e. "Dev1/ai0"
        analog_input = PyDAQmx.Task()
        read = PyDAQmx.int32()
        new_val=numpy.zeros((1024,),dtype=numpy.float64)
        #create a voltage channelt that is in referenced single-ended mode with a minimum value of -10 V and a max of 10 V
        analog_input.CreateAIVoltageChan(channel,"",PyDAQmx.DAQmx_Val_RSE,-10.0,10.0,PyDAQmx.DAQmx_Val_Volts,None)
        analog_input.StartTask()
        #read single value from channel that was created
        analog_input.ReadAnalogF64(1024,10.0,PyDAQmx.DAQmx_Val_GroupByChannel,new_val,len(new_val),PyDAQmx.byref(read),None)
        analog_input.StopTask()
        temp = self.volt_to_temp(numpy.mean(new_val)) #this assumes a 10k thermistor
        return temp
        
    def getRawData(self, channel, N_points=1024):
        #channel is string of form devicename/analog input channel number i.e. "Dev1/ai0"
        analog_input = PyDAQmx.Task()
        read = PyDAQmx.int32()
        new_val=numpy.zeros((N_points,),dtype=numpy.float64)
        #create a voltage channelt that is in referenced single-ended mode with a minimum value of -10 V and a max of 10 V
        analog_input.CreateAIVoltageChan(channel,"",PyDAQmx.DAQmx_Val_RSE,-10.0,10.0,PyDAQmx.DAQmx_Val_Volts,None)
        analog_input.StartTask()
        #read single value from channel that was created
        analog_input.ReadAnalogF64(N_points,10.0,PyDAQmx.DAQmx_Val_GroupByChannel,new_val,len(new_val),PyDAQmx.byref(read),None)
        analog_input.StopTask()
        temp = numpy.mean(new_val)
        return temp
    
    def setAmplitude(self, amplitude, channel):
        #channel is string of form devicename/analog output channel number i.e. "Dev1/ao0"
        print("temperature setpoint set to %f"%amplitude)
        self.amplitude = amplitude
        analog_output = PyDAQmx.Task()
        write = PyDAQmx.int32()
        if amplitude == 0.0: #this sets the output voltage from the DAQ to 0
            input_val = 0.0        
        #set limits on range of temperature setpoints so that temp is not accidentally set too high or too low
        elif amplitude > 70.0:
            print("entered temperature out of range, setting temperature to 25 C")
            input_val = 1.0
        elif amplitude < 20:
            print("entered temperature out of range, setting temperature to 25 C")
            input_val = 1.0
        else:
            input_val = self.temp_to_volt(amplitude) #this assumes a 10k thermistor
        input_val=numpy.array((input_val),dtype=numpy.float64)
        print('Output voltage: %f Volts' % input_val)
        analog_output.CreateAOVoltageChan(channel,"",0.0,5.0,PyDAQmx.DAQmx_Val_Volts,None) #create analog output channel
        analog_output.StartTask() #start task
        analog_output.WriteAnalogF64(1,True,10,PyDAQmx.DAQmx_Val_GroupByChannel,input_val,PyDAQmx.byref(write),None) #write output
        analog_output.StopTask() #stopTask       
    
    def volt_to_temp(self,volt):
        if volt == 0.0:
            temp = numpy.NaN
            #print "voltage = 0"
        elif volt < 0:
            temp = numpy.NaN
            #print volt
        else:
            #convert voltage to temperature using Steinhart-Hart equation
            #constants for Steinhart & Hart Equation for 10k thermistors        
            A = 0.001125308852122
            B = 0.000234711863267
            C = 0.000000085663516
            # Convert Measured Voltage into resistance of 10 k thermistor
            Ibias = 100e-6 #bias current value is set by bias resistor soldered to HTC 1500 (100uA = 12.kohm resistor)
            R = 1.0*volt/Ibias
            temp = 1/(A+B*numpy.log(R)+C*(numpy.log(R))**3) - 273.15 #Steinhart&Hart eqn
        return temp

    def temp_to_volt(self,temp):
        #convert temperature to voltage using Steinhart-Hart equation
        #constants for Steinhart & Hart Equation for 10k thermistors
        A = 0.001125308852122
        B = 0.000234711863267
        C = 0.000000085663516
        Ibias = 100e-6 #bias current value is set by bias resistor soldered to HTC 1500 (100uA = 12.kohm resistor)
        y = (A-1/(temp+273.15))/(2*C)        
        x = numpy.sqrt((B/(3*C))**3+y**2)        
        R = numpy.exp(numpy.power(x-y,1/3.0)-numpy.power(x+y,1/3.0))
        volt = Ibias*R
        #print('%f'%volt)
        return volt
        
    def digital_out(self,sig,dev_name,port,line,val_array = numpy.array([0,0,0,0,0,0,0,0])):
        # sig = 1 sets output of port,line to high, sig=0 sets output of port,line to low
        # inputs port and line are integers
        # labelling on USB600X is P0.0 = port 0, line 0
        device_name = dev_name+"/port"+str(port)+"/line"+str(line) #concatenate string for device name
        digital_output=PyDAQmx.Task() #initialize task
        write = PyDAQmx.int32()
        digital_output.CreateDOChan(device_name,"",PyDAQmx.DAQmx_Val_ChanPerLine) #create task for specific channel
        #set output of specific digital output to either high or low
        if sig == 1:
            #print("high")
            val_array[7-line]=1
            val_T = numpy.packbits(val_array)
            digital_output.WriteDigitalU8(1,True,10.0,PyDAQmx.DAQmx_Val_GroupByChannel,val_T,PyDAQmx.byref(write),None)
        elif sig == 0:
            #print("low")
            val_array[7-line]=0
            val_F = numpy.packbits(val_array)
            digital_output.WriteDigitalU8(1,True,10.0,PyDAQmx.DAQmx_Val_GroupByChannel,val_F,PyDAQmx.byref(write),None)
        else:
            pass
