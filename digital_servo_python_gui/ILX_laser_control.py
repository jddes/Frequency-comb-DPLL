import visa

# Encapsulates the ILX commands to control the current driver:
class ILX_laser_control():
    def __init__(self, str_VISA_address='GPIB0::1::INSTR'):
        # Open GPIB connection:
        rm = visa.ResourceManager()
        self.ilx = rm.get_instrument(str_VISA_address)
        
    def selectChannel(self, channel_number):
        # Set the ILX to the correct channel:
        self.ilx.write('LAS:CHAN %d' % channel_number)
        
    def getEnableStatus(self, channel_number):
        
        if self.ilx is not None:
            # Ask 
            answer = self.ilx.ask('LAS:OUT?')
            return (answer == '1')
        else:
            return False
        
    def setEnableStatus(self, bEnable):
        if self.ilx is not None:
            if bEnable:
                # Activate the channel
                self.ilx.write('LAS:OUT 1')
                print('turning output on')
            else:
                # De-activate the channel
                self.ilx.write('LAS:OUT 0')
                print('turning output off')
                
    def setLaserCurrent(self, current):
        # Note that there is an offset between the current that the ILX is reading and the current setpoint
        self.ilx.write('LAS:LDI %f' % current)
        
    def getLaserCurrent(self):
        # Note that there is an offset between the current that the ILX is reading and the current setpoint
        current = self.ilx.ask('LAS:LDI?')
        current = float(current)
        return current
        
    def setPDCurrentSetpoint(self, current):
        # This sets the monitor photodiode current setpoint when operating in "constant power" mode.
        # The scaling coefficient between optical power and monitor diode current in the ILX needs to be 0 for this mode to work.
        self.ilx.write('LAS:MDI %f' % current)
        
    def getPDCurrentSetpoint(self, current):
        # This reads the monitor photodiode current when operating in "constant power" mode.
        # The scaling coefficient between optical power and monitor diode current in the ILX needs to be 0 for this mode to work.
        current = self.ilx.ask('LAS:MDI?')
        current = float(current)
        return current