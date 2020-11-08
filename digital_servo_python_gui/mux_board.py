import struct
import serial

class MuxBoard():
    """ used to interface our custom multiplexer board used to run automated tests at daughterboard bringup """
    def __init__(self, serial_port_name='COM8'):
        self.osc_en = 0
        self.all_off = 0x7f
        self.pin_select = {
            'none':      self.all_off,
            'DAC0':      self.all_off ^ (1<<6),
            'DAC1':      self.all_off ^ (1<<5),
            'DOUT0':     self.all_off ^ (1<<4),
            'DOUT1':     self.all_off ^ (1<<3),
            'DAC2':      self.all_off ^ (1<<2), # this one has no mosfet because it has been cannibalized
            'DAC1_30V':  self.all_off ^ (1<<1),
            'DAC2_100V': self.all_off ^ (1<<0),
            }
        if serial_port_name is not None:
            self.s = serial.Serial(serial_port_name, baudrate=9600)
        else:
            self.s = None
        self.selectInput('none') # so that we start in a known state

    def getTransferRatio(self):
        """ Returns the voltage transfer ratio at DC from the currently-selected input to the scope. """
        RshuntPerChannel = 1e3
        N_channels = 6 # FIXME: This may change back to 7 if we solder the missing mosfet on the board..
        Rshunt2 = RshuntPerChannel/(N_channels-1)
        Rseries2 = 1e3

        Rsource1 = {
            'none':        1., # undefined, but won't be used anyway
            'DAC0':        1e3,
            'DAC1':        1e3,
            'DOUT0':       1e3,
            'DOUT1':       1e3,
            'DAC2':        1e3,
            'DAC1_30V':   10e3,
            'DAC2_100V': 100e3,
        }
        Rshunt1 = {
            'none':      1., # undefined, but won't be used anyway
            'DAC0':      1e10, # infinite, so that should be good enough
            'DAC1':      1e10, # infinite, so that should be good enough
            'DOUT0':     1e10, # infinite, so that should be good enough
            'DOUT1':     1e10, # infinite, so that should be good enough
            'DAC2':      1e10, # infinite, so that should be good enough
            'DAC1_30V':  1e3,
            'DAC2_100V': 1e3,
        }

        tf1stStage = {selector:voltageDivider(Rsource1[selector], Rshunt1[selector]) for selector in self.pin_select}
        # tf1stStage = {
        #     'none':      1., # undefined, but won't be used anyway
        #     'DAC0':      1,
        #     'DAC1':      1,
        #     'DOUT0':     1,
        #     'DOUT1':     1,
        #     'DAC2':      1,
        #     'DAC1_30V':  ,
        #     'DAC2_100V': voltageDivider(Rsource1[self.selector], Rshunt1[self.selector]),
        # }

        Rsource2 = Rseries2 + Rsource1[self.selector]*Rshunt1[self.selector]/(Rsource1[self.selector]+Rshunt1[self.selector])

        tf2ndStage = {selector:voltageDivider(Rsource2, Rshunt2) for selector in self.pin_select}
        # tf2ndStage = {
        #     'none':      1., # undefined, but won't be used anyway
        #     'DAC0':      voltageDivider(Rsource2, RshuntTotal),
        #     'DAC1':      voltageDivider(Rsource2, RshuntTotal),
        #     'DOUT0':     voltageDivider(Rsource2, RshuntTotal),
        #     'DOUT1':     voltageDivider(Rsource2, RshuntTotal),
        #     'DAC2':      voltageDivider(Rsource2, RshuntTotal),
        #     'DAC1_30V':  voltageDivider(Rsource2, RshuntTotal),
        #     'DAC2_100V': voltageDivider(Rsource2, RshuntTotal),
        #     }

        return tf1stStage[self.selector] * tf2ndStage[self.selector]

    def selectInput(self, selector):
        """ Connects the designated input to the output to scope.
        see the self.pin_select dictionary for valid choices """
        self.selector = selector
        self.commitToDevice()

    def _getRegValue(self):
        """ Encode the desired state into the correct byte """
        return self.pin_select[self.selector] | (self.osc_en<<7)

    def commitToDevice(self):
        """ Write the current selection to the device """
        if self.s is None:
            return
        self.s.write(struct.pack('B', self._getRegValue() ))

    def setOscillator(self, enable):
        self.osc_en = int(bool(enable))
        self.commitToDevice()

def voltageDivider(Rseries, Rshunt):
    """ Returns the voltage transfer function for a resistive voltage divider """
    return Rshunt/(Rshunt+Rseries)


if __name__ == '__main__':
    mux = MuxBoard(None)
    for input_select in mux.pin_select:
        mux.selectInput(input_select)
        print("%s: transfer ratio = %e, atten=1/tf=%.1f"  % (input_select, mux.getTransferRatio(), 1/mux.getTransferRatio()))


    mux = MuxBoard()
    mux.setOscillator(True)

