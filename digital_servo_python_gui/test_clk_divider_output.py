# -*- coding: utf-8 -*-
"""
Created on Tue Feb 25 17:06:58 2014

@author: jnd
"""

"""
XEM6010 Phase-lock box main GUI script,
by JD Deschenes, October 2013

"""
import sys
from PyQt4 import QtGui, Qt, QtCore
import numpy as np

from SuperLaserLand_JD2 import SuperLaserLand_JD2
from XEM_GUI_MainWindow import XEM_GUI_MainWindow
from FreqErrorWindow import FreqErrorWindow
from FreqErrorWindowWithTempControl import FreqErrorWindowWithTempControl
#from DisplayPhaseResponseWindow import DisplayPhaseResponseWindow
from DisplayVNAWindow import DisplayVNAWindow
from initialConfiguration import initialConfiguration
from SLLSystemParameters import SLLSystemParameters
from SLLConfigurationWindow import SLLConfigurationWindow

from DisplayTransferFunctionWindow import DisplayTransferFunctionWindow
from DisplayDitherSettingsWindow import DisplayDitherSettingsWindow

import time

#import gc

import allowSetForegroundWindow # This is a workaround to make our window show on top on Windows 7:
#import os   # used by allowSetForegroundWindow()


def main():
    
    # Create the object that handles the communication with the FPGA board:
    sl = SuperLaserLand_JD2()
    
    # Specify the mapping between the serial numbers and their colors:
    serial_to_color_mapping = {}
    serial_to_color_mapping['000000054R'] = '#1CC981'
    serial_to_color_mapping['124300046V'] = '#8C2633'
    serial_to_color_mapping['124300046U'] = 'blue'
    serial_to_color_mapping['12320003SX'] = 'orange'
    serial_to_color_mapping['000000054E'] = '#E37405'   # orange high-bandwidth (dark orange)
    serial_to_color_mapping['000000054J'] = '#70E7FF'  # blue high-bandwidth (light blue)
    
    # Specify the mapping between the serial numbers and their names:
    serial_to_name_mapping = {}
    serial_to_name_mapping['000000054R'] = 'Box on desk1 (green)'
    serial_to_name_mapping['124300046V'] = 'Box on desk2 (red)'
    serial_to_name_mapping['124300046U'] = '2nd gen PM comb (blue)'
    serial_to_name_mapping['12320003SX'] = '2nd gen PM comb (orange)'
    serial_to_name_mapping['000000054E'] = 'Wideband orange'   # orange
    serial_to_name_mapping['000000054J'] = 'Wideband blue'   # orange
    
    # Specify the mapping between the serial numbers and the ports that they have to connect to for the temperature control
    # Currentl 50001 is orange, 50002 is blue (hard-coded port numbers in the temperature control script)
    port_number_mapping = {}
    port_number_mapping['124300046U'] = 50002   # blue
    port_number_mapping['12320003SX'] = 50001   # orange
    port_number_mapping['000000054E'] = 50001   # orange (wideband)
    port_number_mapping['000000054J'] = 50002   # blue (wideband)
    
    
    
    ###########################################################################
    # Start the User Interface
    allowSetForegroundWindow.allowSetForegroundWindow()
    
    # Start Qt:
    app = QtGui.QApplication(sys.argv)
    
    strList = sl.getDeviceList()
    initial_config = initialConfiguration(strList, serial_to_name_mapping, serial_to_color_mapping, 'superlaserland_highbw.bit')
    
    
    # this will remove minimized status 
    # and restore window with keeping maximized/normal state
    allowSetForegroundWindow.allowSetForegroundWindow()
#    initial_config.setWindowState(initial_config.windowState() & ~QtCore.Qt.WindowMinimized | QtCore.Qt.WindowActive)
    # this will activate the window
#    initial_config.activateWindow()
#    initial_config.show()
    initial_config.raise_()
    initial_config.show()
    # Run the event loop for this window
    app.exec_()
#    print('After app.exec_()()')


    if initial_config.bOk == False:
        # User clicked cancel. simply close the program:
        return
    print(initial_config.strFirmware)
    
    
    
    # Open the selected FPGA:
    error_code = sl.openDevice(initial_config.bSendFirmware, initial_config.strSelectedSerial, initial_config.strFirmware)
#    error_code = sl.openDevice(initial_config.bSendFirmware, initial_config.strSelectedSerial)
    if error_code != 0:
        print(initial_config.strFirmware)
        print(sl.convertErrorCodeToString(error_code))
        rep = QtGui.QMessageBox.warning(None, 'Error', sl.convertErrorCodeToString(error_code), QtGui.QMessageBox.Ok)
        return
    
    ###########################################################################
    # Select clock source
    # clock_source = 0: Internal clock at 100 MHz
    # clock_source = 1: External clock at 200 MHz on DIN[0]/CLKIN, divided by 2 internally for a system clock still at 100 MHz
    if initial_config.bExternalClock == True:
        clock_source = 1
    else:
        clock_source = 0    
    sl.selectClockSource(clock_source)
    
    
    ###########################################################################
    # Create the object which handles the configuration parameters (DAC offsets, DAC gains, beat frequency modulation range, etc):
    sp = SLLSystemParameters()
    # Send the values to the FPGA only if we have just re-programmed it. Otherwise we use whatever value is already in so we don't disturb the operation
    if initial_config.bSendFirmware:
        sp.sendToFPGA(sl)
    
    config_window = SLLConfigurationWindow()
    config_window.loadParameters(sp)
    config_window.hide()
    
    
    sl.set_clk_divider_settings(bOn=1, bPulses=1, modulus=50)
#    sl.send_bus_cmd_32bits(sl.BUS_ADDR_clk_divider_modulus, 0x3FFFFFFF)
    
    # Enter main event loop
#    app.exec_()
#    del xem_gui_mainwindow
#    del sl
    

if __name__ == '__main__':
    main()     
    
    