from PyQt5 import QtGui, Qt, QtCore, QtWidgets
import sys, os, time
import collections
import subprocess

import numpy as np

import common
import text_report
import SuperLaserLand_JD_RP
import initialConfiguration_RP
import SLLSystemParameters
import mux_board
import rigol_scope_tools
import html_report

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
        self.initial_config.qgroupbox_connection.setVisible(False) # hide this, since it's just clutter in this context, the choice is completely ignored

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
        self.delays['freq_counter_settling'] = 3

        self.createInterfaceObjects()
        self.setupScopeForDC()
        self.printStartupMessage()
        self.runTests()
        print("TODO: give the user the change to re-visit some tests? eg if a cable was disconnected or something")
        self.scope.disconnect()

    def printStartupMessage(self):
        print("Welcome. Please make sure the scope is set to 120 kPoints, 500 usecs/div")
        print("Channel 1: Scale: 50 mV/div, DC offset: -150mV")
        # input("Press enter to continue...")

    def setupScopeForDC(self):
        for k in [2, 3, 4]:
            self.scope.send_cmd(":CHAN%d:DISP OFF\n" % k)
        self.scope.send_cmd(":CHAN%d:DISP ON\n" % 1)

        self.scope.send_cmd(":CHAN1:PROBE 1\n")
        self.scope.send_cmd(":CHAN1:OFFSET 0\n")
        self.scope.send_cmd(":CHAN1:RANGE 0.4\n") # this is 400 mV of range, or 50 mV/div
        self.scope.send_cmd(":CHAN1:OFFSET -0.15\n")

        self.setupScopeTimebase(500e-6)

        # self.scope.send_cmd(":ACQ:MDEP 120000\n") # 120 kPoints, THIS DOES NOT SEEM TO WORK, NEEDS TO BE SET MANUALLY!

    def setupScopeForHighFreq(self):
        self.scope.send_cmd(":CHAN1:OFFSET 0\n")
        self.scope.send_cmd(":CHAN1:RANGE 4\n") # this is 4 V of range, or 500 mV/div

    def setupScopeTimebase(self, time_per_div):
        """ sets the scope's timebase in seconds/division """
        self.scope.send_cmd(":TIM:OFFSET 0\n")
        self.scope.send_cmd(":TIM:SCALE %e\n" % time_per_div)

    def runTests(self):
        """ Main function that runs all the tests in the correct sequence """
        self.write_to_report({"test_name": "Test start information",
                              "mac_address": self.gui.mac_address,
                              "operator name": "JDD"})

        self.setupRP()
        self.setup30Vamp()
        self.testOutputs()
        self.testAnalogInputs()
        self.testDinInput()
        self.testExtClkInput()
        self.testManualReadings()
        # self.testDigitalOutputs() # this is now included in the testOutputs()
        self.write_to_report({"test_name": "Test stop information"})

    def createInterfaceObjects(self):
        self.sl = SuperLaserLand_JD_RP.SuperLaserLand_JD_RP()
        self.gui = TestGUIController(self.sl)
        self.scope = self.initScope()
        self.mux = mux_board.MuxBoard('COM8')
        self.report = text_report.TextReport(mac_address=self.gui.mac_address)

    def setupRP(self):
        """ Makes sure that the RP device is in a known state for the test that we will run """
        for x in range(len(self.sl.DACs_offset)):
            self.sl.setDitherLockInState(x, False)
        self.sl.setup_VNA_as_synthesizer(frequency_in_hz=1, output_select=0,
            output_amplitude=0, bEnable=False, bSquareWave=False)

    def write_to_report(self, x):
        """ Augments x with the current zynq temperature and saves the dict to the report """
        self.report.saveTestResult(x, temperature=self.sl.readZynqTemperature())

    def save_data_trace(self, data, filename, fs=1):
        with open(os.path.join(self.report.reportFolder, filename), 'wb') as f:
            # we place the samppling rate in the first data point:
            data = np.concatenate(((fs,), data))
            f.write(data.tobytes())

        # self.write_to_report({"data file": filename})

    def initScope(self):
        s = rigol_scope_tools.RigolScope(iVerbosity = 0)
        # s.progress_update_callback = rigol_scope_tools.progress_update_callback
        s.connect()
        s.setup_ac_triggering()
        return s

    def print_line(self):
        print("-----------------------------------------------------------")

    def setup30Vamp(self):
        self.print_line()
        self.setupScopeTimebase(500e-6)
        dac_number = 1
        self.sl.set_dac_to_extremum(dac_number, 'mid')
        self.sl.setup_VNA_as_synthesizer(frequency_in_hz=1e3, output_select=dac_number,
            output_amplitude=0.99, bEnable=True, bSquareWave=False)
        self.mux.selectInput('DAC1_30V')
        self.scope.send_cmd(':run\n')
        print("Please adjust the sine wave's DC offset so that it is centered in the rails.")
        input("Press enter to continue...")
        self.print_line()

        scope_result = self.scope.get_current_dc_value()
        scope_result = self.undoScalingFromMuxBoard(scope_result)
        (mean, std, w) = scope_result
        self.save_data_trace(w.data, "30V_amp_bias_adjustment.bin", w.fs)

        self.sl.set_dac_to_extremum(dac_number, 'min')
        self.sl.setup_VNA_as_synthesizer(frequency_in_hz=1e3, output_select=dac_number,
            output_amplitude=0.99, bEnable=False, bSquareWave=False)

        self.scope.setup_ac_triggering()

    def testAnalogInputs(self):
        results = dict()
        results["test_name"] = "testAnalogInputs"
        print("\n")
        self.print_line()
        print("testAnalogInputs started...")
        self.setupScopeTimebase(10e-9) # should yield 1 GS/s

        amplitude_for_300mVpp_at_adc = 0.168 #  this includes some loss through the mux board, calibrated for 24 MHz only

        for k in range(2):
            input_select = 'ADC%d' % k
            self.sl.set_dac_to_extremum(k, 'mid')
            self.sl.setup_VNA_as_synthesizer(frequency_in_hz=24e6, output_select=k,
                output_amplitude=amplitude_for_300mVpp_at_adc, bEnable=True, bSquareWave=False)
            time.sleep(self.delays["dac_settling"])
            data = self.sl.getADCorDACdata(input_select, 8e3)
            incremental_results = self.handleDCtestResults(input_select, "24MHz_300mVpp", data, fs=self.sl.fs)
            print(incremental_results)
            results.update(incremental_results)

            # input("Press enter to continue...")

        self.sl.setup_VNA_as_synthesizer(frequency_in_hz=24e6, output_select=k,
            output_amplitude=amplitude_for_300mVpp_at_adc, bEnable=False, bSquareWave=False)

        self.write_to_report(results)
        print("testAnalogInputs done")
        self.print_line()

    def testDigitalOutputs(self):
        self.sl.setDout(0, 0)
        input("outputs should be 0, 0")
        self.sl.setDout(0, 1)
        input("outputs should be 0, 1")
        self.sl.setDout(1, 0)
        input("outputs should be 1, 0")
        self.sl.setDout(1, 1)
        input("outputs should be 1, 1")
        self.sl.setDout(0, 0)

    def testDinInput(self):
        print("\n")
        self.print_line()
        print("testDinInput started...")
        dac_number = 1
        self.sl.set_dac_to_extremum(dac_number, 'mid')
        self.sl.setup_VNA_as_synthesizer(frequency_in_hz=10e6, output_select=dac_number,
            output_amplitude=0.99, bEnable=True, bSquareWave=False)

        time.sleep(self.delays['freq_counter_settling'])

        results = dict()
        results["test_name"] = "testDinInput"
        count = 0
        while count < 5:
            freq = self.sl.getDin1Freq()
            if freq is None:
                continue
            count += 1
            results["DIN1_freq_%02d [Hz]" % count] = freq

        print(results)
        self.write_to_report(results)

        self.sl.set_dac_to_extremum(dac_number, 'min')
        self.sl.setup_VNA_as_synthesizer(frequency_in_hz=10e6, output_select=dac_number,
            output_amplitude=0.99, bEnable=False, bSquareWave=False)

        self.print_line()
        print("testDinInput complete!")

    def setExtClkMode(self, ext_clk):
        # For 200 MHz clock input, these settings should yield 125 MHz ADC clock, 1000 MHz VCO
        f_ref          = 200e6
        CLKFBOUT_MULT  = 5
        CLKOUT0_DIVIDE = 8
        self.sl.setADCclockPLL(f_ref, ext_clk, CLKFBOUT_MULT, CLKOUT0_DIVIDE)

    def quantifyPhaseLock(self, expected_phase_lock):
        """ scope should contain the sum of a 10 MHz and 200 MHz, which are expected to be phase-locked or not depending on expected_phase_lock """
        N_traces = 10
        onoff_string = "on" if expected_phase_lock else "off"
        for k in range(N_traces):
            scope_result = self.scope.get_current_dc_value()
            (mean, std, w) = scope_result
            self.save_data_trace(w.data, "extclk_%s_%02d.bin" % (onoff_string, k), w.fs)
            print("quantifyPhaseLock(): %d/%d, fs=%s" % (k, N_traces, w.fs))


    def testExtClkInput(self):
        print("\n")
        self.print_line()
        print("testExtClkInput started...")
        self.scope.setup_ac_triggering()
        self.setupScopeForHighFreq()

        dac_number = 0
        self.sl.set_dac_to_extremum(dac_number, 'mid')
        self.sl.setup_VNA_as_synthesizer(frequency_in_hz=10e6, output_select=dac_number,
            output_amplitude=0.2, bEnable=True, bSquareWave=False)

        self.setExtClkMode(False)
        self.mux.selectInput("DAC0")
        self.mux.setOscillator(True)
        self.scope.setup_edge_triggering(1)
        time.sleep(0.5)
        # input("before setupScopeTimebase(10e-9): hit enter to continue")
        self.setupScopeTimebase(10e-9) # should yield 1 GS/s. DOES NOT WORK, SO MUST DO IT MANUALLY
        # input("before setupScopeTimebase(10e-9): hit enter to continue")
        print("Scope should now be set up to validate phase lock state or not (10 MHz + 200 MHz superposed)")
        print("Sampling rate should be 1 GS/s")
        print("Current state should be NON-PHASE-LOCKED.")
        # input("Current state should be non phase-locked.")
        self.quantifyPhaseLock(expected_phase_lock=False)
        print("Current state should be now be PHASE-LOCKED.")
        self.setExtClkMode(True)
        self.quantifyPhaseLock(expected_phase_lock=True)

        self.scope.setup_edge_triggering(1)
        results = dict()
        results["test_name"] = "testExtClkInput"
        response = input("Current state should be phase-locked. Enter 'PASS' to confirm, or 'FAIL' to indicate failure: ")
        results["phase-locked?"] = response

        self.write_to_report(results)

        print("testExtClkInput Complete!")
        self.setExtClkMode(False)
        self.mux.setOscillator(False)
        self.sl.set_dac_to_extremum(dac_number, 'min')
        self.sl.setup_VNA_as_synthesizer(frequency_in_hz=10e6, output_select=dac_number,
            output_amplitude=0.2, bEnable=False, bSquareWave=False)

        self.print_line()


    def testOutputs(self):
        print("\n")
        self.print_line()
        print("testOutputs started...")
        self.setupScopeTimebase(5e-3)
        results = dict()
        results['test_name'] = 'analog outputs DC test'

        dac_final_setting = {
            0: "min",
            1: "max",
            2: "min"
        }

        for output_name in ['DAC0', 'DAC1', 'DAC1_30V', 'DAC2_100V', 'DOUT0', 'DOUT1']:
            
            for mode, mux_mode, dac_setting, bPrint in [
                        ('no_connect', 'no_connect', 'min', False),
                        ('min',        'connect',    'min', True),
                        ('max',        'connect',    'max', True),]:
                # print("%s to %s, mux = %s" % (output_name, dac_setting, mux_mode))
                # set the mux according to mux_mode
                if mux_mode == 'connect':
                    self.mux.selectInput(output_name)
                else:
                    self.mux.selectInput('none')

                if output_name.startswith('DAC'):
                    dac_number = int(output_name[len('DAC')])
                    self.sl.set_dac_to_extremum(dac_number, dac_setting)
                else:
                    # this is a digital output
                    current_value = 1 if dac_setting=='max' else 0
                    if output_name == 'DOUT0':
                        self.sl.setDout(current_value, 0)
                    else:
                        self.sl.setDout(0, current_value)

                time.sleep(self.delays['dac_settling'])
                scope_result = self.scope.get_current_dc_value()
                scope_result = self.undoScalingFromMuxBoard(scope_result)
                (mean, std, w) = scope_result
                incremental_results = self.handleDCtestResults(output_name, mode, w.data, w.fs)
                results.update(incremental_results)
                if bPrint:
                    print(incremental_results)

                # input("Press enter to continue...")
            # set the DAC back to min to avoid biasing the next results:

            self.sl.set_dac_to_extremum(dac_number, dac_final_setting[dac_number])

        self.write_to_report(results)

        print("testOutputs done")
        self.print_line()

    def testManualReadings(self):
        """ Ask the user to perform a few manual readings on the device and report the results via text """
        results = dict()
        results['test_name'] = 'Manual readings'
        print("Manual readings:")
        response = input("Please verify that the positive side is on the center pin. Enter PASS, FAIL or SKIP: ")
        results["Positive on center pin"] = response
        response = input("Enter the measured voltage (nominal 30V): ")
        results["Actual voltage"] = response
        self.write_to_report(results)

    def undoScalingFromMuxBoard(self, scope_result):
        """ Applies the inverse scaling ratio done by the mux board """
        tf = self.mux.getTransferRatio()
        (mean, std, w) = scope_result
        w.data = w.data/tf
        return (mean/tf, std/tf, w)

    def handleDCtestResults(self, output_name, mode, data, fs):
        """ Receives the scope's results, and converts them to the format desired in the report dict
        and saves the raw trace to the report folder """
        filename = "%s_%s.bin" % (output_name, mode)
        self.save_data_trace(data, filename, fs)
        return self.formatDCtestResults(output_name, mode, data, filename)

    def formatDCtestResults(self, output_name, mode, data, filename=""):
        result = dict()
        prefix = "%s_%s_" % (output_name, mode)
        result[prefix + "mean [V]"]  = "%.6f" % (self.weighted_mean(data))
        result[prefix + "std [V]"]   = "%.6f" % (np.std(data))
        result[prefix + "pk-pk [V]"] = "%.6f" % (np.max(data)-np.min(data))
        result[prefix + "filename"]  = filename
        return result

    def weighted_mean(self, data):
        """ returns the mean of the data, weighted with a smooth window function """
        window = np.blackman(len(data))
        return np.sum(np.multiply(data, window))/np.sum(window)

def main():
    if len(sys.argv) > 1:
        # testing only, without running any actual test:
        class t():
            pass
        obj = t()
        obj.gui = t()
        obj.gui.mac_address = "11223344"

        import json
        with open(r"I:\Data\RP_test_reports\002632f087c6__2020-11-05__01_55_54\report.txt", 'r') as f:
            report = json.load(f)
        header, r = html_report.generate_simple_report(report)
        html_report.print_html_report(header, r, r"I:\Data\RP_test_reports\002632f087c6__2020-11-05__01_55_54\report.html")

    else:
        t = TestController()
        header, r = html_report.generate_simple_report(t.report.items)
        html_report_file = os.path.join(t.report.reportFolder, "report.html")
        html_report.print_html_report(header, r, html_report_file)
        html_report.generate_plot_images(t.report.reportFolder)

        # print(html_report_file)
        # os.system('start "' + html_report_file + '"')
        # subprocess.run(['start', html_report_file])

if __name__ == '__main__':
    main()