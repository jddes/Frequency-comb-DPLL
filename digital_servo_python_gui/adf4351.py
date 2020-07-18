""" ADF4351's register map """
from collections import namedtuple
import bin_conv
import pprint
import math

r = namedtuple('RegisterDescription', ('addr', 'bit_start', 'bit_stop'))

reg_map = {
    # register 0
    "CTRL0":                   r(0, 0, 2),
    "FRAC":                    r(0, 3, 14),
    "INT":                     r(0, 15, 30),
    # register 1
    "CTRL1":                   r(1, 0, 2),
    "MOD":                     r(1, 3, 14),
    "PHASE":                   r(1, 15, 26),
    "PRESCALER":               r(1, 27, 27),
    "PHASE_ADJUST":            r(1, 28, 28),
    # register 2
    "CTRL2":                   r(2, 0, 2),
    "COUNTER_RESET":           r(2, 3, 3),
    "CP_THREE_STATE":          r(2, 4, 4),
    "POWER_DOWN":              r(2, 5, 5),
    "PD_POLARITY":             r(2, 6, 6),
    "LDP":                     r(2, 7, 7),
    "LDF":                     r(2, 8, 8),
    "CP_CURRENT":              r(2, 9, 12), 
    "DOUBLE_BUFFER":           r(2, 13, 13),
    "R":                       r(2, 14, 23),
    "RDIV2":                   r(2, 24, 24),
    "REF_DOUBLER":             r(2, 25, 25),
    "MUXOUT":                  r(2, 26, 28),
    "LOWNOISE_AND_LOWSPUR":    r(2, 29, 30),
    # register 3
    "CTRL3":                   r(3, 0, 2),
    "CLK_DIV":                 r(3, 3, 14),
    "CLK_DIV_MODE":            r(3, 15, 16),
    "CSR":                     r(3, 18, 18),
    "CHARGE_CANCEL":           r(3, 21, 21),
    "ANTIBACKLASH_PULSEWIDTH": r(3, 22, 22),
    "BAND_SELECT_CLK_MODE":    r(3, 23, 23),
    # register 4
    "CTRL4":                   r(4, 0, 2),
    "OUTPUT_PWR":              r(4, 3, 4),
    "RF_OUTPUT_ENABLE":        r(4, 5, 5),
    "AUX_OUTPUT_POWER":        r(4, 6, 7),
    "AUX_OUTPUT_ENABLE":       r(4, 8, 8),
    "AUX_OUTPUT_SEL":          r(4, 9, 9),
    "MTLD":                    r(4, 10, 10),
    "VCO_PD":                  r(4, 11, 11),
    "BAND_SELECT_CLK_DIV":     r(4, 12, 19),
    "RF_DIVIDER_SEL":          r(4, 20, 22),
    "FB_SEL":                  r(4, 23, 23),
    # register 5
    "CTRL5":                   r(5, 0, 2),
    "RSVD":                    r(5, 19, 20),
    "LD_PIN_MODE":             r(5, 22, 23)
}



class adf4351():
    def __init__(self):
        self.reg = {reg_name: 0 for reg_name in reg_map}
        self.pwr_map = {'-4dBm': 0, '-1dBm': 1, '+2dBm': 2, '+5dBm': 3}
        self.prescaler_cutoff = 3.6e9 # above 3.6 GHz, we must use the 8/9 prescaler according to the datasheet
        self.prescaler_map = {'4/5': 0, '8/9': 1}
        self.int_min = {'4/5': 23, '8/9': 75}
        self.fb_sel_map = {"VCO_OUTPUT":1, "DIVIDERS": 0}
        self.cp_current_map = {('%.2f' % (312.6667e-003*(k+1))):k for k in range(2**4) } # assumes a 5.1 kOhms current-setting resistor (we used 4.7k)
        self.target_bandsel_clk = 500e3
        self.vco_min = 2.2e9
        self.vco_max = 4.4e9
        self.load_defaults()

    def print_state(self):
        print(pprint.pformat(self.reg))
        print("Output pwr: %s" % a.get_output_power())

    def load_reg_vals(self, reg_list):
        for addr, reg in enumerate(reg_list):
            if reg is not None:
                self.reg_vals_to_internal_state(reg, addr)

    def reg_vals_to_internal_state(self, val, addr):
        """ copies all the first from register value "val", at address "addr" to our internal state """
        for (reg_name, reg_info) in reg_map.items():
            if reg_info.addr != addr:
                continue
            self.reg[reg_name] = bin_conv.extract_bits(val, reg_info.bit_start, reg_info.bit_stop)

    def internal_state_to_reg_vals(self):
        """ Returns a list of integer containing the six register values to be sent to the chip.
        the list is ordered from r0 to r5, but the write should be done in reverse order (r0 last) """
        ret_val = list()
        for addr in range(6):
            reg_val = 0
            for (reg_name, reg_info) in reg_map.items():
                if reg_info.addr != addr:
                    continue
                reg_val = bin_conv.replace_bits(reg_val, reg_info.bit_start, reg_info.bit_stop, self.reg[reg_name])
            ret_val.append(reg_val)
        return ret_val

    def set_noise_optimization(self, mode="lownoise"):
        """ Sets either low noise or low spur mode (see datasheet).
        mode is either 'lownoise' or 'lowspur' """
        if mode == "lownoise":
            val = 0
        else:
            val = 1
        self.reg["LOWNOISE_AND_LOWSPUR"] = val

    def load_defaults(self):
        self.reg["PHASE"] = 1
        self.reg["PHASE_ADJUST"] = 0
        self.reg["LOWNOISE_AND_LOWSPUR"] = 0 # 0 = lownoise, 3 = lowspur
        self.reg["RSVD"] = 3 # reserved, but must be b"11"
        # mostly unused regs here, but just to match what the AD tool gives by default
        self.reg["MOD"] = 2
        self.reg["PD_POLARITY"] = 1
        self.reg["CLK_DIV"] = 150
        self.reg["VCO_PD"] = 0
        self.enforce_constraints()

    def enforce_constraints(self):
        # these bits are called "control bits" in the datasheet, but they really are just
        # the address of the register
        for k in range(6):
            self.reg["CTRL%d"%k] = k

    def set_output_power(self, pwr="+5dBm"):
        """ Valid values for pwr are:
        '-4dBm', '-1dBm', '+2dBm', '+5dBm' """
        self.reg["OUTPUT_PWR"] = self.pwr_map.get(pwr, 3)
        self.reg["RF_OUTPUT_ENABLE"] = 1
        self.reg["VCO_PD"] = 0

    def turn_off_vco(self):
        self.reg["VCO_PD"] = 1

    def get_output_power(self):
        return dict_rev_lookup(self.pwr_map, self.reg["OUTPUT_PWR"], '-4dBm')

    def setup_integer_n(self, out_freq, ref_freq, pfd_target_freq=10e6):
        """ Setup all the registers for synthesizing out_freq.
        Currently only attemps an integer-N solution,
        ie output freq = vco_freq/D = INT*pfd_freq/D = INT*ref_freq/(R*D).
        Returns the actual output frequency that will be synthesized """
        # rf_out = pfd_freq * INT / D = ref_freq * INT / (R*D)
        # pfd_freq = ref_freq/R
        # D can only take 1, 2, 4, 8, 16, 32 or 64 as values
        nearest_power_of_two = lambda x: 2**round(math.log2(x))
        print("-----------------------------------------------------------------------")

        vco_target = (self.vco_min + self.vco_max)/2
        D = nearest_power_of_two(vco_target/out_freq)
        vco_target = out_freq*D
        print("Chosen vco target freq = %.2f MHz, D=%d, output target freq = %.2f MHz" % (vco_target/1e6, D, out_freq/1e6))
        R = round(ref_freq/pfd_target_freq)
        if R < 1:
            R = 1
        pfd_actual_freq = ref_freq/R
        INT = round(vco_target/pfd_actual_freq)
        vco_actual = pfd_actual_freq*INT
        out_freq_actual = vco_actual/D
        print("Chosen INT=%d, R=%d, pfd freq = %f MHz, vco freq = %f MHz, output freq = %.2f MHz " % (INT, R, pfd_actual_freq/1e6, vco_actual/1e6, out_freq_actual/1e6))

        self.prescaler_cutoff = 3.6e9 # above 3.6 GHz, we must use the 8/9 prescaler according to the datasheet
        self.prescaler_map = {'4/5': 0, '8/9': 1}
        self.int_min = {'4/5': 23, '8/9': 75}

        # check that the INT minimum value is respected:
        if vco_actual > self.prescaler_cutoff:
            prescaler = '8/9'
        else:
            prescaler = '4/5'
        int_min = self.int_min[prescaler]
        if INT < int_min:
            print("Error: INT is out of range. Please select different settings to achieve a solution (might require changing the code here")


        self.reg["FB_SEL"] = self.fb_sel_map["VCO_OUTPUT"]
        self.reg["RF_DIVIDER_SEL"] = int(math.log2(D))
        self.reg["INT"] = int(INT)
        self.reg["R"] = int(R)


        self.reg["ANTIBACKLASH_PULSEWIDTH"] = 1 # 3 ns: recommended for integer-n

        if pfd_actual_freq > 125e3:
            self.reg["BAND_SELECT_CLK_MODE"] = 1
        else:
            self.reg["BAND_SELECT_CLK_MODE"] = 0

        self.reg["LDF"] = 1
        self.reg["LDP"] = 1
        self.reg["CHARGE_CANCEL"] = 1 # reduces PFD spurs in integer-N
        self.reg["CP_CURRENT"] = self.cp_current_map["2.50"]


        self.reg["PRESCALER"] = self.prescaler_map[prescaler]
        self.reg["BAND_SELECT_CLK_DIV"] = round(pfd_actual_freq/self.target_bandsel_clk)
        if self.reg["BAND_SELECT_CLK_DIV"] < 1:
            self.reg["BAND_SELECT_CLK_DIV"] = 1 # this is fine
        if self.reg["BAND_SELECT_CLK_DIV"] > 254:
            print("Error: Value out of range for BAND_SELECT_CLK_DIV. This indicates a too fast PFD frequency")
            self.reg["BAND_SELECT_CLK_DIV"] = 254

        self.set_output_power()
        return out_freq_actual


def dict_rev_lookup(dictionary, key, default=None):
    values = list(dictionary.values())
    keys = list(dictionary.keys())
    try:
        return keys[values.index(key)]
    except AttributeError:
        return default

def test_freq_steps():
    """ Test the biggest error in synthesized frequency from 1 MHz to 1000 MHz,
    with 10 MHz ref freq. Expect a worst-case error of 1 MHz """
    a = adf4351()
    worse_error = 0
    for k in range(int(1e9/1e6)):
        out_freq = (1+k)*1e6
        out_actual_freq = a.setup_integer_n(out_freq=out_freq, ref_freq=10e6, pfd_target_freq=10e6)
        print("error = %.2f MHz" % ((out_actual_freq-out_freq)/1e6))
        if abs(out_actual_freq-out_freq)>worse_error:
            worse_error = out_actual_freq-out_freq
    print("Complete. worse_error = %.2f MHz" % (worse_error/1e6))

def test_convert_and_back():
    """ Test converting from raw register values to internal state, then back.
    We can't just throw random values in, since unused bits are not handled,
    so instead we generated an example valid configuration using the Analog Devices tool """
    a.load_reg_vals([0x320000, 0x8008011, 0x4E42, 0x4B3, 0x8C803C, 0x580005])
    in_regs = [0x640000, 0x8008011, 0x4E42, 0x4B3, 0xCA002C, 0x580005]
    a.load_reg_vals(in_regs)
    out_regs = a.internal_state_to_reg_vals()
    print(list(map(hex, in_regs)))
    print(list(map(hex, out_regs)))
    assert in_regs == out_regs

def test_specific_config():
    """ I generated register values from the AD development tool,
    and compare to what my class generates for one specific set of conditions """
    expected_regs = [0xD80000, 0x8008011, 0x4FC2, 0xE004B3, 0xD1403C, 0x180005]
    a_expected = adf4351()
    a_expected.load_reg_vals(expected_regs)

    a = adf4351()
    a.setup_integer_n(out_freq=135e6, ref_freq=10e6, pfd_target_freq=10e6)
    out_regs = a.internal_state_to_reg_vals()
    print(list(map(hex, expected_regs)))
    print(list(map(hex, out_regs)))

    print("reg: expected, actual")
    for reg_name in a.reg:
        equal_or_not = "EQUAL" if a_expected.reg[reg_name] == a.reg[reg_name] else "NOT EQUAL"
        print("%s: %s: %d, %d" % (equal_or_not, reg_name, a_expected.reg[reg_name], a.reg[reg_name]))

    assert out_regs == expected_regs

if __name__ == '__main__':
    a = adf4351()
    # a.print_state()
    test_freq_steps()
    a.set_output_power('+2dBm')
    a.print_state()
    test_convert_and_back()
    test_specific_config()
