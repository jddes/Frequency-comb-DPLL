# -*- coding: utf-8 -*-
"""
Created on Fri Dec 13 16:24:57 2013

@author: jnd
"""
from __future__ import print_function

# This class implements a thin wrapper around the ElementTree/Element classes, which does XML parsing/writing.
# This allows us change the implementation if we want, without having to rewrite the UI code.
# from xml.etree.ElementTree import ElementTree as ET, Element
import xml.etree.ElementTree as ET


class SLLSystemParameters():
    
    values_dict = {}
    
    def __init__(self):

        self.populateDefaults()

        return
        
    def populateDefaults(self):
        # Create the tree structure:
        self.root = ET.Element('SuperLaserLandPLL_settings')
        self.tree = ET.ElementTree(self.root)
        
        # Default values for all the parameters:
        self.root.append(ET.Element('Reference_frequency', DDC0='31.25e6', DDC1='31.25e6'))
        self.root.append(ET.Element('VCO gain', DAC0='2e8', DAC1='0.5e6', DAC2='9e6'))
        self.root.append(ET.Element('Output_limits_low', DAC0='-1.0', DAC1='-0', DAC2='0'))
        self.root.append(ET.Element('Output_limits_high', DAC0='1.0', DAC1='1', DAC2='55'))
        self.root.append(ET.Element('Input_Output_gain', ADC0='1', ADC1='1', DAC0='1', DAC1='1'))
        self.root.append(ET.Element('Output_offset_in_volts', DAC0='0.0274', DAC1='0', DAC2='27'))
        self.root.append(ET.Element('PLL0_settings', kp='10', fi='45e3', fii='3.4e3', fd='1', fdf='1', chkKd='False', chkKp='False', chkLock='False', chkKpCrossing='False'))
        self.root.append(ET.Element('PLL1_settings', kp='-5.6', fi='141e3', fii='3.24e3', fd='1', fdf='1', chkKd='False', chkKp='True', chkLock='False', chkKpCrossing='True'))
#        self.root.append(ET.Element('PLL2_settings', kp='-120', fi='1e-2', fii='0', fd='1', fdf='1', chkKd='False', chkKp='False', chkLock='False', chkKpCrossing='False'))
        self.root.append(ET.Element('PLL2_settings', LoopFilter='0', flip_acquisition='True', flip_lock='True', AcqGain='-21', LockGain='-23')) # <!--LoopFilter = 0: off | 1: slow piezo only | 2: fast piezo only | 3:both piezo (equivalent to lock) -->
        self.root.append(ET.Element('PWM0_settings', standard='3.3', levels='256', default='0.0', minval='0.0', maxval='3.3'))
        
        self.root.append(ET.Element('Main_window_settings', refresh_delay='500', N_samples_adc='1.75e3', N_samples_ddc='1e6', Integration_limit='5e6'))
        self.root.append(ET.Element('Triangular_averaging', DAC1='1', DAC0='1'))

        self.root.append(ET.Element('Auto_unlock', chkAutoUnlock='False', threshold='0.05'))
        self.root.append(ET.Element('Temperature_control', chkControl='True', threshold_step='0.35', threshold_disable='0.05', step_size='0.05', step_delay='60', bIncrementalOnly="False"))

        self.root.append(ET.Element('Dither_frequency', DAC1='5.1e3', DAC0='1e3'))
        self.root.append(ET.Element('Dither_integration_time', DAC1='0.1', DAC0='0.1'))
        self.root.append(ET.Element('Dither_amplitude', DAC1='1e.3', DAC0='1e-3'))
        self.root.append(ET.Element('Dither_mode', DAC1='2', DAC0='2'))
        
        self.root.append(ET.Element('VCO_settings', VCO_offset='0.00', VCO_amplitude='0.5', VCO_connection='0'))
        self.root.append(ET.Element('RP_settings', Fan_state='0', PLL2_connection='0', Clock_select=0))
        self.root.append(ET.Element('Filter_select', DAC1='0', DAC0='0'))
        self.root.append(ET.Element('Angle_select', DAC1='0', DAC0='0'))

        



        
    def loadFromFile(self, strFilename):
        self.tree = ET.parse(strFilename)
        self.root = self.tree.getroot()

        # we used to do error checking at this level, but now it is implemented one layer higher in the hierarchy (currently in XEM_GUI3.py)
        # try:
            # self.tree = ET.parse(strFilename)
            # self.root = self.tree.getroot()
        # except IOError:
        #     print("IOError when trying to parse configuration file %s. using default values" % (strFilename))
        #     self.populateDefaults()
        # return
    
    def saveToFile(self, strFilename):
        self.tree.write(strFilename)
        return        

    def getValue(self, strKey, strParameter):
        return self.tree.find(strKey).attrib[strParameter]
        
    def setValue(self, strKey, strParameter, strValue):
        self.tree.find(strKey).attrib[strParameter] = strValue
        
    def sendToFPGA(self, sl, bSendToFPGA = True):
        # Set the programmable gain amplifiers values:
        # allowed values: 1, 2, 4, 8
        # ADC0_gain = int(self.getValue('Input_Output_gain', 'ADC0'))
        # ADC1_gain = int(self.getValue('Input_Output_gain', 'ADC1'))
        # DAC0_gain = int(self.getValue('Input_Output_gain', 'DAC0'))
        # DAC1_gain = int(self.getValue('Input_Output_gain', 'DAC1'))
        
       
        # Set the DAC output limits:
        limit_low = float(self.getValue('Output_limits_low', 'DAC0'))    # the limit is in volts
        limit_high = float(self.getValue('Output_limits_high', 'DAC0'))    # the limit is in volts
        sl.set_dac_limits(0, sl.convertDACVoltsToCounts(0, limit_low), sl.convertDACVoltsToCounts(0, limit_high))
        limit_low = float(self.getValue('Output_limits_low', 'DAC1'))    # the limit is in volts
        limit_high = float(self.getValue('Output_limits_high', 'DAC1'))    # the limit is in volts
        sl.set_dac_limits(1, sl.convertDACVoltsToCounts(1, limit_low), sl.convertDACVoltsToCounts(1, limit_high))
        # print('low = %d, high = %d' % (sl.convertDACVoltsToCounts(1, limit_low), sl.convertDACVoltsToCounts(1, limit_high)))
        limit_low = float(self.getValue('Output_limits_low', 'DAC2'))    # the limit is in volts
        limit_high = float(self.getValue('Output_limits_high', 'DAC2'))    # the limit is in volts
        sl.set_dac_limits(2, sl.convertDACVoltsToCounts(2, limit_low), sl.convertDACVoltsToCounts(2, limit_high))
        
        ##
        ## HB, 4/27/2015, Added PWM support on DOUT0
        ##
        PWM0_standard = float(self.getValue('PWM0_settings', 'standard'))
        PWM0_levels   = int(self.getValue('PWM0_settings', 'levels'))
        PWM0_default  = float(self.getValue('PWM0_settings', 'default'))
        # Convert to counts
        value_in_counts = sl.convertPWMVoltsToCounts(PWM0_standard, PWM0_levels, PWM0_default)
        # Send to FPGA
        sl.set_pwm_settings(PWM0_levels, value_in_counts, bSendToFPGA)
        
        
def main():
    # Create a system parameters object, just for testing:
    sp = SLLSystemParameters()
    sp.saveToFile('test.xml')
    
    rep = sp.tree.find('Reference_frequency')
    print(rep)
    print(rep.attrib['DDC0'])
    
    print(sp.getValue('Reference_frequency', 'DDC0'))
    sp.setValue('Reference_frequency', 'DDC0', '5.1e6')
    print(sp.getValue('Reference_frequency', 'DDC0'))

#    for el in list(sp.root.iter('Default output offset')):
#        print(el)
#        print(el.attrib['DAC0'])
        
    return
    
if __name__ == '__main__':
    main()     