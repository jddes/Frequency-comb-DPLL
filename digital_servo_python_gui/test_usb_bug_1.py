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

last_dac_offset = 0

def displayDAC(sl):
    
    # Set a certain offset on the dac output:
    global last_dac_offset
    last_dac_offset = last_dac_offset + 1
    sl.set_dac_offset(0, last_dac_offset)
    
#    for k in range(10):
#        Num_bytes_read = 640*2*10000
#        raw_bytes = sl.read_raw_bytes_from_pipe(sl.PIPE_ADDRESS_DDR2_LOGGER, Num_bytes_read)
#        (output0_has_data, output1_has_data, PipeA1FifoEmpty) = sl.readStatusFlags()
#        print('(%d, %d, %d)' % (output0_has_data, output1_has_data, PipeA1FifoEmpty))
    
    
    # For now: we grab the smallest chunk of points from the output (so as to not use too much time to refresh)
    # and display the current average:
    N_points = 64   # I think that this is the smallest chunk we can read at a time with the current design of the DDR2 controller
    sl.setup_DAC0_write(N_points)
    sl.trigger_write()
    sl.wait_for_write()
#    samples_out = sl.read_raw_bytes_from_DDR2()
    (samples_out, ref_exp0) = sl.read_adc_samples_from_DDR2()
    average_code = np.mean(samples_out)
    print('average code = %f, average_voltage = %f V' % (average_code, sl.convertADCCountsToVolts(0, average_code)))
    print(samples_out)
    
    # Force loss of sync by reading some extra bytes:
    if last_dac_offset == 3:
        sl.ddr_bytes_skip = 6
    
#    # Force loss of sync of the pipe by writing some extra bytes and then not reading them:
#    N_points = 64   # I think that this is the smallest chunk we can read at a time with the current design of the DDR2 controller
#    sl.setup_DAC0_write(N_points)
#    sl.trigger_write()
#    sl.wait_for_write()
    
#    # Force loss of sync of the pipe by reading some extra bytes:
#    bytes_read_extra = 11
#    buffer_full_block = "\xAA"*bytes_read_extra
#    read_bytes = sl.dev.ReadFromPipeOut(sl.PIPE_ADDRESS_DDR2_LOGGER, buffer_full_block)
#    print('Asked for %dd bytes, got %d.' % (bytes_read_extra, read_bytes))
    
    
    # For now: we grab the smallest chunk of points from the output (so as to not use too much time to refresh)
    # and display the current average:
    N_points = 64   # I think that this is the smallest chunk we can read at a time with the current design of the DDR2 controller
    sl.setup_ADC0_write(N_points)
    sl.trigger_write()
    sl.wait_for_write()
#    samples_out = sl.read_raw_bytes_from_DDR2()
    (samples_out, ref_exp0) = sl.read_adc_samples_from_DDR2()
    average_code = np.mean(samples_out)
#    print('average code = %f, average_voltage = %f V' % (average_code, sl.convertADCCountsToVolts(0, average_code)))
#    print(samples_out)
    
    # Force loss of sync by reading some extra bytes:
    if last_dac_offset == 3:
        sl.ddr_bytes_skip = 2
    
    # For now: we grab the smallest chunk of points from the output (so as to not use too much time to refresh)
    # and display the current average:
    N_points = 64   # I think that this is the smallest chunk we can read at a time with the current design of the DDR2 controller
    sl.setup_ADC0_write(N_points)
    sl.trigger_write()
    sl.wait_for_write()
#    samples_out = sl.read_raw_bytes_from_DDR2()
    (samples_out, ref_exp0) = sl.read_adc_samples_from_DDR2()
#    average_code = np.mean(samples_out)
#    print('average code = %f, average_voltage = %f V' % (average_code, sl.convertADCCountsToVolts(0, average_code)))
#    print(samples_out)

def main():
    
    # Create the object that handles the communication with the FPGA board:
    sl = SuperLaserLand_JD2()
    
    # Specify the mapping between the serial numbers and their colors:
    serial_to_color_mapping = {}
    serial_to_color_mapping['000000054R'] = '#1CC981'
    serial_to_color_mapping['124300046V'] = '#8C2633'
    serial_to_color_mapping['124300046U'] = 'blue'
    serial_to_color_mapping['12320003SX'] = 'orange'
    
    # Specify the mapping between the serial numbers and their names:
    serial_to_name_mapping = {}
    serial_to_name_mapping['000000054R'] = 'Box on desk1 (green)'
    serial_to_name_mapping['124300046V'] = 'Box on desk2 (red)'
    serial_to_name_mapping['124300046U'] = '2nd gen PM comb (blue)'
    serial_to_name_mapping['12320003SX'] = '2nd gen PM comb (orange)'
    
    
    ###########################################################################
    # Start the User Interface
    allowSetForegroundWindow.allowSetForegroundWindow()
    
    # Start Qt:
    app = QtGui.QApplication(sys.argv)
    
    strList = sl.getDeviceList()
    initial_config = initialConfiguration(strList, serial_to_name_mapping, serial_to_color_mapping, 'superlaserland.bit')
    
    
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
    
    displayDAC(sl)
    displayDAC(sl)
    displayDAC(sl)
    displayDAC(sl)
    time.sleep(5)
    displayDAC(sl)
    displayDAC(sl)
    displayDAC(sl)
    
    print('%x' % sl.PIPE_ADDRESS_DDR2_LOGGER)
    
    # Enter main event loop
#    app.exec_()
#    del xem_gui_mainwindow
#    del sl
    

if __name__ == '__main__':
    main()     
    
    