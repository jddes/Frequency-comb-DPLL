import collections
import os, sys

import numpy as np
import matplotlib.pyplot as plt
from scipy import signal

def generate_simple_report(report):
    """ Generates an easy-to-read summary of the report
    """

    header = collections.OrderedDict()
    top_level = collections.OrderedDict()

    start_info = findTestByName(report, 'Test start information')
    header["mac_address"] = start_info["mac_address"]

    validate_range = lambda x, xmin, xmax: (xmin <= x) and (x <= xmax)

    manual_test = findTestByName(report, "Manual readings")
    if manual_test is not None:
        top_level["30V power supply"] = list()
        passfail_polarity = manual_test["Positive on center pin"].upper()
        try:
            voltage = float(manual_test["Actual voltage"])
        except ValueError:
            voltage = 0.
        top_level["30V power supply"].append(["Correct polarity", "Positive on center pin", passfail_polarity, passfail_polarity=="PASS"])
        top_level["30V power supply"].append(["Actual voltage", "30V", "%.1fV"%voltage, validate_range(voltage, 28, 32)])

    temp_test = findTestByName(report, "Test stop information")
    top_level["Temperature"] = list()
    temp = float(temp_test["Zynq temperature [degC]"])
    top_level["Temperature"].append(["Zynq Temperature**", "60 degC after 5 mins", "%.2f degC"%temp, validate_range(temp, 15, 65)])

    ext_clk_test = findTestByName(report, "testExtClkInput")
    if ext_clk_test is not None:
        top_level["Clock input:"] = list()
        passfail = ext_clk_test["phase-locked?"]
        top_level["Clock input:"].append(["200 MHz clock in", "DAC output phase locked", passfail.upper(), passfail.upper()=="PASS"])

    # Analog inputs:
    ai_test = findTestByName(report, "testAnalogInputs")
    if ai_test is not None:
        top_level["Analog inputs:"] = list()
        for k in (0, 1):
            val_pkpk = float(ai_test["ADC%d_24MHz_300mVpp_std [V]"%k]) * np.sqrt(2)*2
            top_level["Analog inputs:"].append(["AI%d"%k, "300 mVpp at 25 MHz", "%.2f mV" % (1e3*val_pkpk), validate_range(val_pkpk, 80e-3*3, 120e-3*3)])


    # analog outputs
    ao_test_info = collections.OrderedDict()
    ao_test_info["AO0, output range*"]           = ["0-2V",   "DAC0",      (-0.1, 0.1), (2-0.1, 2+0.1)]
    ao_test_info["AO1, output range*"]           = ["0-2V",   "DAC1",      (-0.1, 0.1), (2-0.1, 2+0.1)]
    ao_test_info["AO1, amplified output range*"] = ["0-30V",  "DAC1_30V",  (-0.1, 4),   (25, 31)]
    ao_test_info["AO2, amplified output range*"] = ["0-100V", "DAC2_100V", (-0.1, 12),  (95, 120)]

    ao_test = findTestByName(report, "analog outputs DC test")
    if ao_test is not None:
        top_level["Analog outputs:"] = list()
        for name, info in ao_test_info.items():
            nominal_value, dac_name, min_range, max_range = info
            if dac_name == "DAC1_30V":
                # handle inverting amplifier
                min_val = float(ao_test[dac_name+"_max_mean [V]"])
                max_val = float(ao_test[dac_name+"_min_mean [V]"])
            else:
                min_val = float(ao_test[dac_name+"_min_mean [V]"])
                max_val = float(ao_test[dac_name+"_max_mean [V]"])
            out    = [None]*4
            out[0] = name
            out[1] = nominal_value
            out[2] = "%.2f-%.2f" % (min_val, max_val)
            out[3] = (validate_range(min_val, *min_range)  and
                      validate_range(max_val, *max_range))
            top_level["Analog outputs:"].append(out)
        print(top_level["Analog outputs:"])


    # change this to a list, which is the expected format for the next step
    r = list()
    for test_type in top_level:
        r.append(("test_type", test_type))
        # print("test_type=", test_type)
        for test_item in top_level[test_type]:
            # print("test_item=", test_item)
            r.append(("test_item", test_item))

    return header, r

def print_html_report(header, r, output_file):
    """ Prints an easy-to-read summary of the report """
    # # example report (this should be a table, maybe do it with HTML?):

    # Temperature     
    # Zynq Temperature**              60 degC after 5 mins        52.1 degC
    # Clock input:        
    # 200 MHz clock in                DAC output phase locked?    PASS
    # Analog inputs:      
    # AI0                             100 mVpp at 25 MHz          84.0 mVpp
    # AI1                             100 mVpp at 25 MHz          83.2 mVpp
    # Analog outputs:     
    # AO0, output range*              0-2V                        0.00-2.07V
    # AO1, output range*              0-2V                        0.00-2.06V
    # AO1, amplified output range*    0-30V                       1.4-28.2V
    # AO2, amplified output range*    0-100V                      7.99-109V
    style_green = 'style="background-color:rgb(194,214,155);"'
    style_red   = 'style="background-color:rgb(192,0,0); color:white;"'
    gray_bck   = 'style="background-color:rgb(217,217,217); border-bottom: 1px solid black;"'
    style = {True: style_green, False: style_red}
    header_style = 'style="background-color:black; color:white; font-weight:bold; border-bottom: 1px solid black;"'

    # test_type_line = lambda x: '<tr %s><td><span style="font-weight:bold">%s</span></td><td></td><td></td></tr>\n' % (gray_bck, x)
    test_type_line = lambda x: '<tr %s><td colspan=3 style="font-weight:bold">%s</td></tr>\n' % (gray_bck, x)

    power_on_center_pin_result = True

    html_header = "<html><head><title>%s Test report</title></head>\n" % header["mac_address"]
    output = html_header
    output += "<body>\n"
    output += "<h1>Test report</h1>\n"
    output += "<h2>Red Pitaya Frequency-Comb digital phase-lock platform</h2>"
    output += "<p>Daughterboard revision 4b<br>\n"
    output += "Customer: TBD<br>\n"
    output += "Unit mac address: %s</p>\n" % header["mac_address"]

    # output += '<table class="myclass">\n'
    output += '<table style="border-collapse:collapse; border:1px solid black;">\n'
    output += '<tr><td %s></td><td %s>Nominal value</td><td %s>Actual value</td></tr>\n' % (header_style, header_style, header_style)

    for line_type, line_data in r:
        if line_type == "test_type":
            output += test_type_line(line_data)
        else:
            # print(line_data)
            td1, td2, td3, pass_or_fail = line_data
            output += '<tr style="border-bottom: 1px solid black;">'
            output += '<td style="font-weight:bold">%s</td><td>%s</td><td %s>%s</td></tr>\n' % (td1, td2, style[pass_or_fail], td3)

    output += "</table>\n"
    output += "<p></p>\n"
    output += "<p></p>\n"

    # add in images
    output += '<table>\n'
    output += '<tr><td colspan=2><img src="ADC0_24MHz_300mVpp.png"></td></tr>\n'
    output += '<tr><td colspan=2><img src="ADC1_24MHz_300mVpp.png"></td></tr>\n'
    output += '<tr><td><img src="DAC0.png"></td><td><img src="DAC1.png"></tr>\n'
    output += '<tr><td><img src="DAC1_30V.png"></td><td><img src="DAC2_100V.png"></tr>\n'
    output += '<tr><td><img src="30V_amp_bias_adjustment.png"></td><td></tr>\n'
    output += '<tr><td><img src="DOUT0.png"></td><td><img src="DOUT1.png"></tr>\n'
    output += '<tr><td><img src="ext_clk_off.png"></td><td><img src="ext_clk_on.png"></tr>\n'

    output += '</table>\n'
    output += '</body>\n'
    output += '</html>\n'


    with open(output_file, "w") as f:
        f.write(output)

def load_bin_file(filename):
    data = np.fromfile(filename)
    # sampling rate is the first data point
    fs = data[0]
    data = data[1:]
    time = np.arange(len(data))/fs
    return (time, data)

def output_plots(folder):
    dac_plot_limits = collections.OrderedDict()
    dac_plot_limits["DAC0"] =      (-0.5, 2.5)
    dac_plot_limits["DAC1"] =      (-0.5, 2.5)
    dac_plot_limits["DAC1_30V"] =  (-0.5, 31)
    dac_plot_limits["DAC2_100V"] = (0, 120)
    dac_plot_limits["DOUT0"] =     (-0.5, 4)
    dac_plot_limits["DOUT1"] =     (-0.5, 4)

    for dac_name in dac_plot_limits:
        suffixes = ['_min.bin', '_max.bin']
        if dac_name == 'DAC1_30V':
            # handle inverting amplifier:
            suffixes.reverse()
        fig = plt.figure()
        for suffix in suffixes:
            filename = os.path.join(folder, dac_name + suffix)
            (time, data) = load_bin_file(filename)
            plt.plot(time, data, linewidth=0.5)

        plt.title(dac_name.replace('_', ' '))
        plt.ylabel('DAC Voltage [V]')
        plt.xlabel('Time [s]')
        plt.ylim(dac_plot_limits[dac_name])
        plt.savefig(os.path.join(folder, dac_name + '.png'))


    plt.figure()
    dac_name = '30V_amp_bias_adjustment'
    filename = os.path.join(folder, dac_name + '.bin')
    (time, data) = load_bin_file(filename)
    plt.plot(time*1e3, data, linewidth=0.5)
    plt.title(dac_name.replace('_', ' '))
    plt.ylabel('DAC Voltage [V]')
    plt.xlabel('Time [ms]')
    plt.ylim(dac_plot_limits["DAC1_30V"])
    plt.xlim((0, 4))
    plt.savefig(os.path.join(folder, dac_name + '.png'))
    

def input_plots(folder):
    # ADC measurements:
    # first find all files starting with 'ADC'
    adc_files = list()
    for dir_entry in os.scandir(folder):
        if dir_entry.name.startswith('ADC') and dir_entry.name.endswith('.bin'):
            adc_files.append(dir_entry.name)

    adc_files.sort()
    for filename in adc_files:
        fullname = os.path.join(folder, filename)
        plt.figure()
        (time, data) = load_bin_file(fullname)
        fs = 1/(time[2]-time[1])
        window = np.blackman(len(data))
        spc = np.fft.fftshift(np.fft.fft(np.multiply(data, window)))
        spc = spc/np.max(np.abs(spc))
        freq = np.fft.fftshift(np.fft.fftfreq(len(spc), (time[2]-time[1])))
        ind = (freq > 0)
        plt.plot(freq[ind]/1e6, 20*np.log10(np.abs(spc[ind])), linewidth=0.5)

        plt.title(filename.replace('_', ' ')[:-4])
        # plt.ylabel('ADC Voltage [V]')
        # plt.xlabel('Time [s]')
        plt.ylabel('Amplitude [dB rel to peak]')
        plt.xlabel('Freq [MHz]')
        plt.savefig(fullname.replace('.bin', '.png'))
        # plt.ylim(dac_plot_limits[dac_name])

def extclk_plots(folder):
    # ext clk test:
    # first find all files starting with 'extclk_'
    f_low  = 10e6
    f_high = 200e6

    clk_files = list()
    for dir_entry in os.scandir(folder):
        if dir_entry.name.lower().startswith('extclk_') and dir_entry.name.endswith('.bin'):
            clk_files.append(dir_entry.name)

    clk_files.sort()
    last_type = ''
    for filename in clk_files:
        fullname = os.path.join(folder, filename)
        plot_type = filename.split('_')[1]
        if plot_type != last_type:
            if last_type != '':
                # print(last_type.replace('.bin', '.png'))
                plt.savefig(os.path.join(folder, 'ext_clk_%s.png' % last_type))

            plt.figure()
            last_type = plot_type
            plt.title('Ext clk mode %s' % plot_type)
            plt.ylabel('ADC Voltage [V]')
            plt.xlabel('Time ns [s]')
            # plt.ylim(dac_plot_limits[dac_name])



        (time, data) = load_bin_file(fullname)
        fs = 1/(time[2]-time[1])

        # plot a short section of the data in the middle, also doing software triggering on the 10 MHz (f_slow) tone
        ind_middle = round(len(data)/2)
        N = int(75)
        N_trigger = int(round(fs/f_low/2))
        N_filter = int(round(fs/f_high))
        data_small = data[ind_middle-int(N_trigger/2):ind_middle+int(N_trigger/2)]

        lpf = np.ones(N_filter)
        data_smallf = signal.filtfilt(lpf, 1, data_small)
        try:
            index_zerocrossing = np.where(np.diff(data_smallf >= 0)==1)[0][0]
        except:
            index_zerocrossing = int(round(len(data_small)/2))
            print("Exception while finding zero crossing. will use middle")
        plt.plot(1e9*(time[ind_middle+index_zerocrossing-N:ind_middle+index_zerocrossing+N]-time[ind_middle-int(N_trigger/2)+index_zerocrossing]),
                      data[ind_middle+index_zerocrossing-N:ind_middle+index_zerocrossing+N], linewidth=0.5)

    if last_type != '':
        plt.savefig(os.path.join(folder, 'ext_clk_%s.png' % last_type))

def generate_plot_images(folder):
    output_plots(folder)
    input_plots(folder)
    extclk_plots(folder)

def findTestByName(report, test_name):
    """ Returns the dict corresponding to a particular test """
    for d in report:
        if d["test_name"] == test_name:
            return d

    return None


def main():
    if len(sys.argv) > 1:
        import json

        folder = sys.argv[1]
        generate_plot_images(folder)


        with open(os.path.join(folder, "report.txt"), 'r') as f:
            report = json.load(f)
        header, r = generate_simple_report(report)
        print_html_report(header, r, os.path.join(sys.argv[1], "report.html"))


if __name__ == '__main__':
    main()
