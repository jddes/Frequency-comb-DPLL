# -*- coding: utf-8 -*-
"""
Phase-lock box main GUI script,
by JD Deschenes, October 2013
---
-- Ported to Red Pitaya platform - JDD 2017

"""
from __future__ import print_function
import sys
from PyQt5 import QtGui, Qt, QtCore, QtWidgets
import numpy as np


from SuperLaserLand_JD_RP import SuperLaserLand_JD_RP
from XEM_GUI_MainWindow import XEM_GUI_MainWindow
#from FreqErrorWindow import FreqErrorWindow
from FreqErrorWindowWithTempControlV2 import FreqErrorWindowWithTempControlV2
#from DisplayPhaseResponseWindow import DisplayPhaseResponseWindow
from initialConfiguration_RP import initialConfiguration
from SLLSystemParameters import SLLSystemParameters
from SLLConfigurationWindow import SLLConfigurationWindow

from DisplayDitherSettingsWindow import DisplayDitherSettingsWindow

from DisplayDividerAndResidualsStreamingSettingsWindow import DisplayDividerAndResidualsStreamingSettingsWindow

from ConfigurationRPSettingsUI import ConfigRPSettingsUI

import time





def main():
    
    # Create the object that handles the communication with the FPGA board:
    sl = SuperLaserLand_JD_RP()

    
    # Specify the mapping between the MAC addresses (which are used as a form of serial numbers) and the box data
    devices_data = {}
    devices_data['002632f016dc'] = {'color': '#1CC981',
                        'name': 'Red Pitaya 0',
                        'shorthand': 'RP 0',
                        'config file': 'system_parameters_RP_1.xml',
                        #'port': 60002
                        }
                        
    devices_data['002632f03cc2'] = {'color': '#1CC981',
                        'name': 'RP Comb 1',
                        'shorthand': 'RPC 1',
                        'config file': 'system_parameters_RP_C1.xml',
                        #'port': 60002
                        }

    devices_data['002632f03d5b'] = {'color': '#1CC981',
                        'name': 'RP Comb 2',
                        'shorthand': 'RPC 2',
                        'config file': 'system_parameters_RP_C2.xml',
                        #'port': 60002
                        }
    
#    serial_to_color_mapping = {}
#    serial_to_color_mapping['000000054R'] = '#1CC981'
#    serial_to_color_mapping['000000054S'] = '#811CC9'
#    # serial_to_color_mapping['124300046U'] = 'blue'
#    serial_to_color_mapping['12320003SX'] = 'orange'
#    serial_to_color_mapping['000000054E'] = '#E37405'   # orange high-bandwidth (dark orange)
#    serial_to_color_mapping['000000054J'] = '#70E7FF'  # blue high-bandwidth (light blue)
#    serial_to_color_mapping['124300046R'] = '#B572E8'  # purple high-bandwidth (purple)
#    serial_to_color_mapping['124300046V'] = '#FF0000'
#    serial_to_color_mapping['124300046S'] = '#0033CC'
    
    
    
    
    
    # this opens the connection to the fpga (hard-coded IP address for now)
#    strList = sl.getDeviceList()
    
    
    ###########################################################################
    # Update the FPGA bitfile and the Zynq monitor-tcp C program
    

    # send new bitfile version
    try:
#        sl.dev.write_file_on_remote(strFilenameLocal=r'D:\Projects\RedPitaya\fpga\project\redpitaya.runs\impl_1\red_pitaya_top.bit', strFilenameRemote='/opt/red_pitaya_top.bit')
#        sl.dev.write_file_on_remote(strFilenameLocal=r'D:\Projets_Xilinx\RedPitaya\fpga\project\redpitaya.runs\impl_1\red_pitaya_top.bit', strFilenameRemote='/opt/red_pitaya_top.bit')
        pass
    except:
        print("warning, could not update fpga bitfile")
        pass
    # program FPGA with new bitfile:
#    sl.dev.send_shell_command('cat /opt/red_pitaya_top.bit > /dev/xdevcfg')

#    time.sleep(3)
    
    
#    
#    # send new monitor-tcp version
#    sl.dev.write_file_on_remote(strFilenameLocal=u'D:\\Université\\Dropbox\\22_H2015\\Red Pitaya\\monitor-tcp\\monitor-tcp', strFilenameRemote='/opt/monitor-tcp-new')
#    
#    # set executable permissions
#    sl.dev.send_shell_command('chmod +x /opt/monitor-tcp-new')
#    # copy over old file
#    sl.dev.send_shell_command('mv /opt/monitor-tcp-new /opt/monitor-tcp')
#    
#    # send reboot command
#    sl.dev.send_reboot_command()
#    sl.dev.sock.shutdown(socket.SHUT_RDWR)
#    sl.dev.sock.close()
#    
#    time.sleep(1) # give some time for tcp server to come back up
##    return
#    sl.getDeviceList() # reconnect
#    
#    #sl.dev.OpenTCPConnection(sl.dev.HOST, sl.dev.PORT) # hack to get things working quickly
##    sl.dev.sock.connect((sl.dev.HOST, sl.dev.PORT))
#    
##    return  # for quick debug tests
    
    
    ###########################################################################
    # Start the User Interface
    
    # Start Qt:
    app = QtCore.QCoreApplication.instance()
    if app is None:
        app = QtWidgets.QApplication(sys.argv)
    
    
    strBroadcastAddress = '192.168.0.255'
    strFPGAFirmware=r'red_pitaya_top.bit'
    strCPUFirmware=u'monitor-tcp'
    initial_config = initialConfiguration(sl.dev, devices_data, strBroadcastAddress, strFPGAFirmware, strCPUFirmware)
    
#    def __init__(self, dev, devices_data={}, strBroadcastAddress="192.168.2.255", strFPGAFirmware='', strCPUFirmware=''):
    
    
    

    
    
#    # this will remove minimized status 
#    # and restore window with keeping maximized/normal state
#    allowSetForegroundWindow.allowSetForegroundWindow()
##    initial_config.setWindowState(initial_config.windowState() & ~QtCore.Qt.WindowMinimized | QtCore.Qt.WindowActive)
#    # this will activate the window
##    initial_config.activateWindow()
##    initial_config.show()
#  #  initial_config.raise_()
#  #  initial_config.show()
#  
#    SetWindowPos(initial_config.winId(),
#                    win32con.HWND_TOPMOST, # = always on top. only reliable way to bring it to the front on windows
#                    0, 0, 0, 0,
#                    win32con.SWP_NOMOVE | win32con.SWP_NOSIZE | win32con.SWP_SHOWWINDOW)
#    SetWindowPos(initial_config.winId(),
#                    win32con.HWND_NOTOPMOST, # disable the always on top, but leave window at its top position
#                    0, 0, 0, 0,
#                    win32con.SWP_NOMOVE | win32con.SWP_NOSIZE | win32con.SWP_SHOWWINDOW)
#    initial_config.raise_()
#    initial_config.show()
#    initial_config.activateWindow()

    #initial_config.setWindowState(initial_config.windowState() & ~QtCore.Qt.WindowMinimized | QtCore.Qt.WindowActive)
    # Run the event loop for this window
    app.exec_()
    
    if initial_config.bOk == False:
        # User clicked cancel. simply close the program:
        return
        
    ###########################################################################
    # Test reading the XADC values:
    # See Xilinx document UG480 chapter 2 for conversion factors
    # we use 2**16 instead of 2**12 for the denominator because the codes are "MSB-aligned" in the register (equivalent to a multiplication by 2**4)
    xadc_unipolar_code_to_voltage    = lambda x: x*1./2.**16
    xadc_temperature_code_to_voltage = lambda x: x*503.975/2.**16-273.15
    xadc_powersupply_code_to_voltage = lambda x: x*3./2.**16
    print("Temperature: %f deg C" % (xadc_temperature_code_to_voltage(    sl.dev.read_Zynq_XADC_register_uint32(0x200)   )))
    print("Vccint: %f V"          % (xadc_powersupply_code_to_voltage(    sl.dev.read_Zynq_XADC_register_uint32(0x204)   )))
    print("Vccaux: %f V"          % (xadc_powersupply_code_to_voltage(    sl.dev.read_Zynq_XADC_register_uint32(0x208)   )))
    print("Vp/vn: %f V"           % (xadc_unipolar_code_to_voltage(       sl.dev.read_Zynq_XADC_register_uint32(0x20C)   )))
    print("Vrefp: %f V"           % (xadc_unipolar_code_to_voltage(       sl.dev.read_Zynq_XADC_register_uint32(0x210)   )))
    print("Vrefn: %f V"           % (xadc_unipolar_code_to_voltage(       sl.dev.read_Zynq_XADC_register_uint32(0x214)   )))
    print("Vbram: %f V"           % (xadc_powersupply_code_to_voltage(    sl.dev.read_Zynq_XADC_register_uint32(0x218)   )))
    
    for kAux in range(16):
        print("Vaux[%d]: %f V" % (kAux, xadc_unipolar_code_to_voltage(       sl.dev.read_Zynq_XADC_register_uint32(0x240+4*kAux)   )))
        
        
    ###########################################################################
    # Test writing the PWM DAC values:
    # range is 0 to 1.8 V
    pwm_dac_voltage_to_code = lambda x: max(min(int(round(x/1.8*(156*2**16))), (156*2**16)), 0)
    sl.dev.write_Zynq_register_uint32(0x00600020, pwm_dac_voltage_to_code(  0.5))   # slow DAC A
    sl.dev.write_Zynq_register_uint32(0x00600024, pwm_dac_voltage_to_code(  0.0))   # slow DAC B
    sl.dev.write_Zynq_register_uint32(0x00600028, pwm_dac_voltage_to_code(  0.0))   # slow DAC C
    sl.dev.write_Zynq_register_uint32(0x0060002C, pwm_dac_voltage_to_code(  0.0))   # slow DAC D
    
    
    # Start the init process (this sets the PLL gain/settings registers and the residuals streaming)
    sl.initSubModules(initial_config.bSendDefaultValues)


   
    ###########################################################################
    # Create the object which handles the configuration parameters (DAC offsets, DAC gains, beat frequency modulation range, etc):
    sp = SLLSystemParameters()
#    # Send the values to the FPGA only if we have just re-programmed it. Otherwise we use whatever value is already in so we don't disturb the operation
#    bTriggerEvents = False
#    if initial_config.bSendFirmware:
#        
#        bTriggerEvents = True
    bTriggerEvents = True
        
    # Lookup filename and load if file is there:
    try:
        custom_config_file = ''
        custom_config_file = devices_data[initial_config.strSelectedSerial]['config file']
        sp.loadFromFile(custom_config_file)
        print('Loaded configuration from %s' % custom_config_file)
    except (KeyError, IOError):
        strFileDefaultConfig = 'system_parameters_RP_Default.xml'
        print('Warning: Could not parse config file "%s" for FPGA serial: %s, loading values from file %s' % (custom_config_file, initial_config.strSelectedSerial, strFileDefaultConfig))
        
        try:
            sp.loadFromFile(strFileDefaultConfig)
            print('Loaded configuration from %s' % strFileDefaultConfig)
        except (KeyError, IOError):
            
            print('Warning: Could not parse config file "%s" for FPGA serial: %s, falling back on script-defined defaults' % (strFileDefaultConfig, initial_config.strSelectedSerial))
            sp.loadDefaults()
        
        
    # sp.loadDefaults()
    # sp.saveToFile('system_parameters_current.xml')
    
    bSendToFPGA = bTriggerEvents
    sp.sendToFPGA(sl, bSendToFPGA)
    
#    config_window = SLLConfigurationWindow()
#    config_window.loadParameters(sp)
#    config_window.hide()
    

    ###########################################################################
    # Load all our windows:
    
    # Style sheet which includes the color scheme for each specific box:
    try:
        custom_style_sheet = ('#MainWindow {color: white; background-color: %s;}' % devices_data[initial_config.strSelectedSerial]['color'])
    except KeyError:
        custom_style_sheet = ''
        
    
    # The shorthand name which gets added to the window names:
    try:
        custom_shorthand = devices_data[initial_config.strSelectedSerial]['shorthand']
    except KeyError:
        custom_shorthand = ''

    # Have to be careful with the modulus setting (double-check with a scope to make sure the output frequency is right)
    # I think the output frequency for the square wave mode is given by:
    # 200 MHz/(2*(modulus+1))
    # While for the pulsed mode (bPulses = 1), the frequency is:
    # 200 MHz/(modulus+1)
#    sl.set_clk_divider_settings(bOn=1, bPulses=0, modulus=67e3-1)
#    sl.set_clk_divider_settings(bOn=1, bPulses=0, modulus=67e3+1-1)
    divider_settings_window = DisplayDividerAndResidualsStreamingSettingsWindow(sl, clk_divider_modulus=67e3, bDividerOn=0, bPulses=0, custom_style_sheet=custom_style_sheet, custom_shorthand=custom_shorthand, bUpdateFPGA = bSendToFPGA)    
    
    
    # Optical lock window
    xem_gui_mainwindow2 = XEM_GUI_MainWindow(sl, custom_shorthand + ': Optical lock', 1, (False, True, False), sp, custom_style_sheet, initial_config.strSelectedSerial)
    xem_gui_mainwindow2.initSL(bTriggerEvents)
    
    # CEO Lock window
    xem_gui_mainwindow = XEM_GUI_MainWindow(sl, custom_shorthand + ': CEO lock', 0, (True, False, False), sp, custom_style_sheet, initial_config.strSelectedSerial)
    xem_gui_mainwindow.initSL(bTriggerEvents)
    
    
#    ###########################################################################
#    # For testing the Red Pitaya with the built-in DDS:
#    
#    addr_vco = 2
#    addr_vco_amplitude = 0x0000
#    addr_vco_freq_msb  = 0x0004
#    addr_vco_freq_lsb  = 0x0008
#
#    vco_amplitude = round(0.01*(2**15-1))
##   vco_freq_word = np.array([round((15e6/100e6+1./600.)*2.**48)]).astype(np.int64)
##   # break vco word into msbs and lsbs:
##   vco_freq_word_msbs = vco_freq_word >> 32
##   vco_freq_word_lsbs = np.bitwise_and(vco_freq_word, (1<<32)-1)
#   
#   # write amplitude
#    address_uint32 = (addr_vco << 20) + addr_vco_amplitude
#    data_uint32 = vco_amplitude
#    sl.dev.write_Zynq_register_uint32(address_uint32, data_uint32)
    
    #########################################################  
    # The two frequency counter:
    strOfTime = time.strftime("%m_%d_%Y_%H_%M_%S_")

    try:
        temp_control_port = devices_data[initial_config.strSelectedSerial]['port']
    except:
        temp_control_port = 0
    
    
    strNameTemplate = 'data_logging\%s' % strOfTime
    strNameTemplate = '%s_%s_' % (strNameTemplate, initial_config.strSelectedSerial)
    freq_error_window1 = FreqErrorWindowWithTempControlV2(sl, 'CEO beat in-loop counter', 0, strNameTemplate, custom_style_sheet, 0, xem_gui_mainwindow)
    freq_error_window2 = FreqErrorWindowWithTempControlV2(sl, 'Optical beat in-loop counter', 1, strNameTemplate, custom_style_sheet, temp_control_port, None)

    counters_window = Qt.QWidget()
    counters_window.setObjectName('MainWindow')
    counters_window.setStyleSheet(custom_style_sheet)
    vbox = Qt.QVBoxLayout()
    vbox.addWidget(freq_error_window1)
    vbox.addWidget(freq_error_window2)
    counters_window.setLayout(vbox)
    counters_window.setWindowTitle(custom_shorthand + ': Frequency counters')
    #counters_window.setGeometry(993, 40, 800, 1010)
    #counters_window.setGeometry(0, 0, 750, 1000)
    #    counters_window.resize(600, 1080-100+30)
    #counters_window.move(QtGui.QDesktopWidget().availableGeometry().topLeft() + Qt.QPoint(985, 10))
    #counters_window.show()
    
    # Dither windows, this code could be moved to another class/file to help with clutter:
    dither_widget0 = DisplayDitherSettingsWindow(sl, 0, modulation_frequency_in_hz='1e3', output_amplitude='1e-3', integration_time_in_seconds='0.1', bEnableDither=True, custom_style_sheet=custom_style_sheet)
    dither_widget1 = DisplayDitherSettingsWindow(sl, 1, modulation_frequency_in_hz='5.1e3' , output_amplitude='1e-3', integration_time_in_seconds='0.1', bEnableDither=True, custom_style_sheet=custom_style_sheet)
    #dither_widget2 = DisplayDitherSettingsWindow(sl, 2, modulation_frequency_in_hz='110' , output_amplitude='1e-4', integration_time_in_seconds='0.1', bEnableDither=True, custom_style_sheet=custom_style_sheet)

    RP_Settings = ConfigRPSettingsUI(sl, custom_style_sheet=custom_style_sheet, custom_shorthand=custom_shorthand, bUpdateFPGA = bSendToFPGA)
    
    settings_window = Qt.QWidget()
    settings_window.setObjectName('MainWindow')
    settings_window.setStyleSheet(custom_style_sheet)
    vbox1 = Qt.QVBoxLayout()
    vbox1.addWidget(dither_widget0)
    vbox1.addWidget(dither_widget1)
    #vbox1.addWidget(dither_widget2)
    vbox1.addStretch(1)
    vbox2 = Qt.QVBoxLayout()
    vbox2.addWidget(RP_Settings)
    vbox2.addWidget(divider_settings_window)
    hbox = Qt.QHBoxLayout()
    hbox.addLayout(vbox1)
    hbox.addLayout(vbox2)
    hbox.addStretch(1)
    settings_window.setLayout(hbox)
    settings_window.setWindowTitle(custom_shorthand + ': Dither controls')
    #settings_window.show()
    
#    ###########################################################################
#    # For testing out the transfer function window:
#    frequency_axis = np.logspace(np.log10(10e3), np.log10(2e6), 10e3)
#    transfer_function = 1/(1 + 1j*frequency_axis/100e3)
#    window_number = 1
#    vertical_units = 'V/V'
#    tf_window1 = DisplayTransferFunctionWindow(frequency_axis, transfer_function, window_number, vertical_units)
#    
    
#    # Regroup the two windows into a single one:
    main_windows = Qt.QWidget()
    main_windows.setObjectName('MainWindow')
    main_windows.setStyleSheet(custom_style_sheet)
    

#    ###########################################################################
#    # Select clock source
#    # clock_source = 0: Internal clock at 100 MHz
#    # clock_source = 1: External clock at 200 MHz on DIN[0]/CLKIN, divided by 2 internally for a system clock still at 100 MHz
#    if initial_config.bSendFirmware:
#        if initial_config.bExternalClock == True:
#            clock_source = 1
#            print('External clock mode')
#        else:
#            clock_source = 0    
#            print('Internal clock mode')
#        sl.selectClockSource(clock_source)
#        # Now we just need to reset the frontend to make sure we start everything in a nice state
#        sl.resetFrontend()
        
    sl.resetFrontend()
    
    tabs = QtGui.QTabWidget()
    # xem_gui_mainwindow2.resize(600, 700)
    
    # xem_gui_mainwindow.setContentsMargins(0, 0, 0, 0)
    # xem_gui_mainwindow.layout().setContentsMargins(0, 0, 0, 0)
    # xem_gui_mainwindow2.setContentsMargins(0, 0, 0, 0)
    # xem_gui_mainwindow2.layout().setContentsMargins(0, 0, 0, 0)
    # counters_window.setContentsMargins(0, 0, 0, 0)
    # counters_window.layout().setContentsMargins(0, 0, 0, 0)
    # dither_window.setContentsMargins(0, 0, 0, 0)
    # dither_window.layout().setContentsMargins(0, 0, 0, 0)
    # dfr_timing_gui.setContentsMargins(0, 0, 0, 0)
    # dfr_timing_gui.layout().setContentsMargins(0, 0, 0, 0)
    # divider_settings_window.setContentsMargins(0, 0, 0, 0)
    # divider_settings_window.layout().setContentsMargins(0, 0, 0, 0)
    
    #tabs.setMaximumSize(1920,1080-100+30)
    
    # main_windows.setMaximumSize(600,600)
    # xem_gui_mainwindow.setMaximumSize(600,600)
    # xem_gui_mainwindow2.setMaximumSize(600,600)
    # counters_window.setMaximumSize(600,600)
    # dither_window.setMaximumSize(600,600)
    # dfr_timing_gui.setMaximumSize(600,600)
    # divider_settings_window.setMaximumSize(600,600)
    tabs.addTab(xem_gui_mainwindow, "CEO Lock")
    tabs.addTab(xem_gui_mainwindow2, "Optical Lock")
    tabs.addTab(counters_window, "Counters")
    tabs.addTab(settings_window, "Settings")
    #FEATURE
    #tabs.addTab(dfr_timing_gui, "DFr trigger generator")
#    tabs.addTab(divider_settings_window, "Filter settings")
    # tabs.setGeometry(0, 0, 750, 1000)
    

    
    box = QtGui.QHBoxLayout()
    box.addWidget(tabs)
    main_windows.setLayout(box)
    main_windows.setWindowTitle(custom_shorthand)
    main_windows.move(QtGui.QDesktopWidget().availableGeometry().topLeft() + Qt.QPoint(945-300, 0))
    
    main_windows.show()



    
    # Enter main event loop
    #app.exec_()
    try:
        app.exec_()
    except:
        print("XEM_GUI3.py: Exception during app.exec_()")
    

if __name__ == '__main__':
    main()     
    
    