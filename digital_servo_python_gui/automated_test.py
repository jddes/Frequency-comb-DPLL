from PyQt5 import QtGui, Qt, QtCore, QtWidgets
import sys, os, time

import numpy as np

import common
import text_report
import SuperLaserLand_JD_RP
import initialConfiguration_RP
import SLLSystemParameters

import rigol_scope_tools

class TestGUIController():
    def __init__(self, sl):
        self.sl = sl
        self.sp = SLLSystemParameters.SLLSystemParameters()
        # these are the "callback-style" functions that the initialConfig dialog will call once the user is ready
        self.pushDefaultValues = self.deviceSelected
        self.getActualValues   = self.deviceSelected
        self.stopCommunication = lambda x, y, z: None # empty function, just to make sure that this wouldn't cause an exception

        # Start Qt:
        self.app = QtWidgets.QApplication(sys.argv)
        self.createInitialConfigDialog()
        # run the event loop until the user chooses a RP to connect to, then the code will continue on as a pure console application
        self.app.exec_()

    def createInitialConfigDialog(self):
        strBroadcastAddress = common.findMostLikelyLANBroadcastIPAddress()
        #strBroadcastAddress = "192.168.0.255"
        strFPGAFirmware=r'red_pitaya_top_extint_clk.bit'
        strCPUFirmware=u'monitor-tcp'
        self.initial_config = initialConfiguration_RP.initialConfiguration(self.sl.dev, self, {},
            strBroadcastAddress, strFPGAFirmware, strCPUFirmware)

    def deviceSelected(self, strSelectedSerial = "000000000000", ip_addr = "192.168.0.150", port=5000):
        QtCore.QCoreApplication.instance().quit() # stop the event loop

        self.mac_address = strSelectedSerial

        self.sl.dev.OpenTCPConnection(ip_addr, port)
        self.sl.resetFrontend()
        # commit the default values, ex for limits etc
        self.sp.loadFromFile('system_parameters_RP_Default.xml')
        self.sp.sendToFPGA(self.sl, bSendToFPGA=True)

class TestController():
    def __init__(self):

        # contains the sleep() duration after various operations
        self.delays = {}
        self.delays['dac_settling'] = 0.1

    # -sequence of operations:
    #     -create all 3 required objects (SL, Scope, mux_board)
        self.sl = SuperLaserLand_JD_RP.SuperLaserLand_JD_RP()
        self.gui = TestGUIController(self.sl)
        self.setupRP()
        self.mac_address = self.gui.mac_address

        # print("avg (volts) = ", np.mean(sl.getADCorDACdata('ADC0', 8e3)))
        self.scope = self.initScope()

        self.report = text_report.TextReport(mac_address=self.gui.mac_address)
        self.folder = self.report.reportFolder
        self.write_to_report({"test_name": "Test start information",
                              "mac_address": self.gui.mac_address,
                              "operator name": "JDD"})

        self.testAnalogOutputs()

        (mean, std, w) = self.scope.get_current_dc_value()
        print("%e pts at fs=%e Hz: %e s, avg=%.2f V, stddev=%.2fV" % (len(w.data), w.fs, len(w.data)/w.fs, mean, std))
        self.scope.disconnect()
        # w.save_to_disk()

        # self.save_data_trace(w.data, "first test.bin", write_to_report)

        self.write_to_report({"test_name": "Test stop information"})

        # self.sl.openDevice
    #     -connect to all 3 devices
    #       -sl: done
    #       -scope: TODO
    #       -mux board: TODO, also need to write the object that will control it
    #     -run each test one after the other

    def setupRP(self):
        """ Makes sure that the RP device is in a known state for the test that we will run """
        for x in range(len(self.sl.DACs_offset)):
            self.sl.setDitherLockInState(x, False)
        self.sl.setup_VNA_as_synthesizer(frequency_in_hz=1, output_select=0,
            output_amplitude=0, bEnable=False, bSquareWave=False)

    def write_to_report(self, x):
        """ Augments x with the current zynq temperature and saves the dict to the report """
        self.report.saveTestResult(x, temperature=self.sl.readZynqTemperature())

    def save_data_trace(self, data, filename):
        with open(os.path.join(self.folder, filename), 'wb') as f:
            f.write(data.tobytes())

        # self.write_to_report({"data file": filename})

    def initScope(self):
        s = rigol_scope_tools.RigolScope(iVerbosity = 0)
        s.progress_update_callback = rigol_scope_tools.progress_update_callback
        s.connect()
        s.setup_ac_triggering()
        return s



    def testAnalogOutputs(self):
        # TODO: select the correct input on the mux_board
        # TODO: do a measurement with the scope with no input selected
        print("\n-----------------------------------------------------------")
        print("testAnalogOutputs started...")
        results = dict()
        results['test_name'] = 'analog outputs DC test'

        for dac_name in ['DAC0', 'DAC1', 'DAC1_30V', 'DAC2_100V']:
            dac_number = int(dac_name[len('DAC')])
            for mode, mux_mode, dac_setting in [('no_connect', 'no_connect', 'min'),
                                                ('min',        'connect', 'min'),
                                                ('max',        'connect', 'max'),]:
                print("%s to %s, mux = %s" % (dac_name, dac_setting, mux_mode))
                # TODO: set the mux according to mux_mode
                self.sl.set_dac_to_extremum(dac_number, dac_setting)
                time.sleep(self.delays['dac_settling'])
                scope_result = self.scope.get_current_dc_value()
                # TODO: results would need to be scaled by the mux_board object
                incremental_results = self.handleDCtestResults(dac_name, mode, scope_result)
                results.update(incremental_results)
                print(incremental_results)
            # set the DAC back to min to avoid biasing the next results:
            self.sl.set_dac_to_extremum(dac_number, 'min')

        self.write_to_report(results)

        print("testAnalogOutputs done")
        print("-----------------------------------------------------------")

    def handleDCtestResults(self, dac_name, mode, scope_result):
        """ Receives the scope's results, and converts them to the format desired in the report dict
        and saves the raw trace to the report folder """
        (mean, std, w) = scope_result
        filename = "%s_%s.bin" % (dac_name, mode)
        self.save_data_trace(w.data, filename)
        return self.generateDCtestResults(dac_name, mode, mean, std, filename)

    def generateDCtestResults(self, dac_name, mode, mean, std, filename=""):
        result = dict()
        prefix = "%s_%s_" % (dac_name, mode)
        result[prefix + "mean [V]"] = "%.3f" % (mean)
        result[prefix + "std [V]"]  = "%.3f" % (std)
        result[prefix + "filename"] = filename
        return result

def main():
    TestController()
    

if __name__ == '__main__':
    main()