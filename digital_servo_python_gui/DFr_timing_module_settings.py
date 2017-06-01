"""
XEM6010 Phase-lock box GUI, Settings controls for the DFr timing module
by JD Deschenes, April 2014

"""

import time
from PyQt4 import QtGui, Qt
import PyQt4.Qwt5 as Qwt
import numpy as np

import weakref
#from SuperLaserLand_JD2 import SuperLaserLand_JD2
#from DisplayTransferFunctionWindow import DisplayTransferFunctionWindow


class DFr_timing_module_settings(QtGui.QWidget):
        
    def __init__(self, sl, custom_style_sheet='', custom_shorthand=''):
        super(DFr_timing_module_settings, self).__init__()
        
        
        self.sl = weakref.proxy(sl)
        self.setObjectName('MainWindow')
        self.setStyleSheet(custom_style_sheet)
        self.custom_shorthand = custom_shorthand


        self.initUI()
        

        
    def update_prbs(self):
        # Read UI values:
        try:
            chip_length = int(float(self.qedit_chip_length.text()))
            number_of_chips = float(self.qedit_number_of_chips.text())
            bPolarityInvert = int(self.qchk_prbs_invert.isChecked())
            
        except:
            return
            pass
        
        # Update FPGA registers:
        self.sl.set_prbs(chip_length, number_of_chips, bPolarityInvert)
        
    def trigger_prbs(self):
        self.sl.prbs_manual_trigger()
        
    def update_dfr(self):
        # Read UI values:
        try:
#            fbeat1 = float(self.qedit_fbeat1.text())
#            fbeat2 = float(self.qedit_fbeat2.text())
#            fceo1 = float(self.qedit_fceo1.text())
#            fceo2 = int(float(self.qedit_fceo2.text()))
            mode_number_difference = int(float(self.qedit_modenumberdifference.text()))
            mode_number = int(float(self.qedit_modenumber.text()))
        except:
            fbeat1 = 26e6
            fbeat2 = 25e6
            fceo1 = 25e6
            fceo2 = 25e6
            mode_number_difference = int(10)
            mode_number = int(1e6)
            pass
        
        # Update FPGA registers:
#        self.sl.set_dfr(fbeat1, fbeat2, fceo1, fceo2)
        self.sl.set_dfr(mode_number_difference)
        self.sl.set_dfr_modulus(mode_number)
        
    def update_dfr_phase(self):
        # Read UI values:
        try:
            time_offset = float(self.qedit_time_offset.text())
#            fbeat1 = float(self.qedit_fbeat1.text())
#            fbeat2 = float(self.qedit_fbeat2.text())
#            fceo1 = float(self.qedit_fceo1.text())
#            fceo2 = int(float(self.qedit_fceo2.text()))
            
            mode_number_difference = int(float(self.qedit_modenumberdifference.text()))
            mode_number = int(float(self.qedit_modenumber.text()))
            
        except:
            time_offset = 0.
            fbeat1 = 26e6
            fbeat2 = 25e6
            fceo1 = 25e6
            fceo2 = 25e6
            mode_number = int(1e6)
            pass
        # Convert to the integer units used in the FPGA:
            
        time_offset_in_points = time_offset * self.sl.fs
        print('time_offset_in_points = %s' % (time_offset_in_points))        
        time_offset_int = int(round(time_offset_in_points*mode_number_difference))
        print('time_offset_int = %s' % (time_offset_int))        
        
        
#        time_offset_int = time_offset * (fbeat1-fbeat2+fceo2-fceo1)
#        integer_part = np.floor(time_offset_int)
#        fractional_part = time_offset_int - integer_part
#        integer_part = long(integer_part)
#        fractional_part = long(fractional_part * 2**48)
#        print('integer part = %s, fractional part = %s' % (integer_part, fractional_part))
        # Update FPGA registers:
        self.sl.set_dfr_phase_adjust(time_offset_int)
        
    def update_ref_freq(self):
        # Read UI values:
        try:
            fref_nominal = float(self.qedit_nominal_freq.text())
            fref_new = float(self.qedit_new_freq.text())
            bForceNominal = int(self.qchk_force_nominal.isChecked())
            bSwitchToNew = int(self.qchk_switch_to_new.isChecked())
        except:
            fref_nominal = 26e6
            fref_new = 25e6
            bForceNominal = 1
            bSwitchToNew = 0
            pass
        
        # Update FPGA registers:
        self.sl.set_ddc1_ref_freq(fref_nominal)
        self.sl.set_ddc1_new_ref_freq(fref_new)
        self.sl.set_ref1_state(bForceNominal, bSwitchToNew)
    
    def initUI(self):


        ######################################################################
        # Create the widgets which control the DFr trigger output
        ######################################################################
        self.qgroupbox_dfr_trigger = Qt.QGroupBox('DFr trigger generator  (DOUT1)')
        self.qgroupbox_dfr_trigger.setAutoFillBackground(True)

        
#        self.qlbl_fbeat1 = Qt.QLabel('Fbeat1 [Hz]:')
#        self.qedit_fbeat1 = Qt.QLineEdit('26e6')
#        self.qlbl_fbeat2 = Qt.QLabel('Fbeat2 [Hz]:')
#        self.qedit_fbeat2 = Qt.QLineEdit('25e6')
#        self.qlbl_fceo1 = Qt.QLabel('Fceo1 [Hz]:')
#        self.qedit_fceo1 = Qt.QLineEdit('25e6')
#        self.qlbl_fceo2 = Qt.QLabel('Fceo2 [Hz]:')
#        self.qedit_fceo2 = Qt.QLineEdit('25e6')
        
        self.qlbl_modenumberdifference = Qt.QLabel('Mode number difference [no units]:')
        self.qedit_modenumberdifference = Qt.QLineEdit('11')
        
        self.qlbl_modenumber = Qt.QLabel('Mode number [no units]:')
        self.qedit_modenumber = Qt.QLineEdit('953933')
        
        
        self.qbtn_update_dfr = Qt.QPushButton('Update registers')
        self.qbtn_update_dfr.clicked.connect(self.update_dfr)
        
        # Put all the widgets into a grid layout
        grid = QtGui.QGridLayout()
        
#        grid.addWidget(self.qlbl_fbeat1,               0, 0)
#        grid.addWidget(self.qedit_fbeat1,              0, 1)
#        grid.addWidget(self.qlbl_fbeat2,               1, 0)
#        grid.addWidget(self.qedit_fbeat2,              1, 1)
#        grid.addWidget(self.qlbl_fceo1,               2, 0)
#        grid.addWidget(self.qedit_fceo1,              2, 1)
#        grid.addWidget(self.qlbl_fceo2,               3, 0)
#        grid.addWidget(self.qedit_fceo2,              3, 1)
#        grid.addWidget(self.qlbl_modenumber,               4, 0)
#        grid.addWidget(self.qedit_modenumber,              4, 1)
#        grid.addWidget(self.qbtn_update_dfr,              5, 0, 1, 2)
        

        grid.addWidget(self.qlbl_modenumberdifference,               0, 0)
        grid.addWidget(self.qedit_modenumberdifference,              0, 1)
        grid.addWidget(self.qlbl_modenumber,               1, 0)
        grid.addWidget(self.qedit_modenumber,              1, 1)
        grid.addWidget(self.qbtn_update_dfr,              2, 0, 1, 2)
        
        self.qgroupbox_dfr_trigger.setLayout(grid)
        
        ######################################################################
        # Create the widgets which control the DFr trigger output
        ######################################################################
        self.qgroupbox_dfr_adjust = Qt.QGroupBox('DFr trigger phase adjust')
        self.qgroupbox_dfr_adjust.setAutoFillBackground(True)

        
        self.qlbl_time_offset = Qt.QLabel('Time advance [seconds]:')
        self.qedit_time_offset = Qt.QLineEdit('0')
        
        self.qbtn_update_dfr_phase = Qt.QPushButton('Update registers')
        self.qbtn_update_dfr_phase.clicked.connect(self.update_dfr_phase)
        
        # Put all the widgets into a grid layout
        grid = QtGui.QGridLayout()
        
        grid.addWidget(self.qlbl_time_offset,               0, 0)
        grid.addWidget(self.qedit_time_offset,              0, 1)
        grid.addWidget(self.qbtn_update_dfr_phase,              1, 0, 1, 2)
        
        self.qgroupbox_dfr_adjust.setLayout(grid)
        
        ######################################################################
        # Create the widgets which control the reference frequency generator module
        ######################################################################
        self.qgroupbox_ref_freq = Qt.QGroupBox('Reference frequency generator')
        self.qgroupbox_ref_freq.setAutoFillBackground(True)

        
        self.qlbl_nominal_freq = Qt.QLabel('Nominal reference freq [Hz]:')
        self.qedit_nominal_freq = Qt.QLineEdit('26e6')
        self.qlbl_new_freq = Qt.QLabel('New reference freq [Hz]:')
        self.qedit_new_freq = Qt.QLineEdit('25e6')
        
        self.qchk_force_nominal = Qt.QCheckBox('Force nominal freq')
        self.qchk_force_nominal.setChecked(True)
        self.qchk_switch_to_new = Qt.QCheckBox('Switch to new ref freq')
        self.qchk_switch_to_new.setChecked(False)

        
        self.qbtn_update_ref_freq = Qt.QPushButton('Update registers')
        self.qbtn_update_ref_freq.clicked.connect(self.update_ref_freq)
        
        # Put all the widgets into a grid layout
        grid = QtGui.QGridLayout()
        
        grid.addWidget(self.qlbl_nominal_freq,               0, 0)
        grid.addWidget(self.qedit_nominal_freq,              0, 1)
        
        grid.addWidget(self.qlbl_new_freq,               1, 0)
        grid.addWidget(self.qedit_new_freq,              1, 1)
        
        grid.addWidget(self.qchk_force_nominal,               2, 0, 1, 2)
        grid.addWidget(self.qchk_switch_to_new,              2, 1, 1, 2)
        grid.addWidget(self.qbtn_update_ref_freq,              3, 0, 1, 2)
        
        self.qgroupbox_ref_freq.setLayout(grid)


        ######################################################################
        # Create the widgets which control the DFr trigger output
        ######################################################################
        self.qgroupbox_prbs = Qt.QGroupBox('PRBS generator  (DOUT2)')
        self.qgroupbox_prbs.setAutoFillBackground(True)

        
        self.qlbl_chip_length = Qt.QLabel('Chip length [samples]:')
        self.qedit_chip_length = Qt.QLineEdit('0')
        
        self.qlbl_number_of_chips = Qt.QLabel('Number of chips [chips]:')
        self.qedit_number_of_chips = Qt.QLineEdit('0')
        
        self.qchk_prbs_invert = Qt.QCheckBox('Polarity invert')
        self.qchk_prbs_invert.setChecked(False)
        
        self.qbtn_update_prbs = Qt.QPushButton('Update registers')
        self.qbtn_update_prbs.clicked.connect(self.update_prbs)
        
        self.qbtn_trigger_prbs = Qt.QPushButton('Trigger PRBS')
        self.qbtn_trigger_prbs.clicked.connect(self.trigger_prbs)
        
        # Put all the widgets into a grid layout
        grid = QtGui.QGridLayout()
        
        grid.addWidget(self.qlbl_chip_length,                   0, 0)
        grid.addWidget(self.qedit_chip_length,                  0, 1)
        grid.addWidget(self.qlbl_number_of_chips,               1, 0)
        grid.addWidget(self.qedit_number_of_chips,              1, 1)
        grid.addWidget(self.qchk_prbs_invert,                   2, 0, 1, 2)
        grid.addWidget(self.qbtn_trigger_prbs,                   4, 0, 1, 2)
        grid.addWidget(self.qbtn_update_prbs,                   5, 0, 1, 2)
        
        self.qgroupbox_prbs.setLayout(grid)
        
        
        
        # Regroup the different groupboxes into one layout then assign this to the window:
        vbox = Qt.QVBoxLayout()
        vbox.addWidget(self.qgroupbox_dfr_trigger)
        vbox.addWidget(self.qgroupbox_dfr_adjust)
        vbox.addWidget(self.qgroupbox_ref_freq)
        vbox.addWidget(self.qgroupbox_prbs)
        self.setLayout(vbox)
        

        # Adjust the size and position of the window
#        self.resize(800, 600)
        self.center()
        self.setWindowTitle(self.custom_shorthand + ': DFr trigger generator')    
        self.show()
        

        
    def center(self):
        
        qr = self.frameGeometry()
        cp = QtGui.QDesktopWidget().availableGeometry().center()
        qr.moveCenter(cp)
#        self.move(qr.topLeft())
#        self.move(QtGui.QDesktopWidget().availableGeometry().topLeft() + Qt.QPoint(50, 50))
        

        
        
        