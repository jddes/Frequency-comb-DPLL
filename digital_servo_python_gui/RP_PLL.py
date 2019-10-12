# -*- coding: utf-8 -*-

from __future__ import print_function
import socket
import struct
import traceback    # for print_stack, for debugging purposes: traceback.print_stack()
import time

import sys

import numpy as np
import logging
#import matplotlib.pyplot as plt

class CommsError(Exception):
    pass

class CommsLoggeableError(CommsError):
    pass


class socket_placeholder():
    def __init__(self):
        pass
    def sendall(*args):
        print("socket_placeholder::sendall(): No active socket. Was called from {}".format(sys._getframe().f_back.f_code.co_name))
        traceback.print_stack()
        pass
    def recv(*args):
        print("socket_placeholder::recv(): No active socket")
        return []

class RP_PLL_device():

    MAGIC_BYTES_WRITE_REG       = 0xABCD1233
    MAGIC_BYTES_READ_REG        = 0xABCD1234
    MAGIC_BYTES_READ_BUFFER     = 0xABCD1235
    
    MAGIC_BYTES_WRITE_FILE      = 0xABCD1237
    MAGIC_BYTES_SHELL_COMMAND   = 0xABCD1238
    MAGIC_BYTES_REBOOT_MONITOR  = 0xABCD1239
    
    FPGA_BASE_ADDR              = 0x40000000    # address of the main PS <-> PL memory map (GP 0 AXI master on PS)
    FPGA_BASE_ADDR_XADC         = 0x80000000    # address of the XADC PS <-> PL memory map (GP 1 AXI master on PS)

    MAX_SAMPLES_READ_BUFFER = 2**15 # should be equal to 2**ADDRESS_WIDTH from ram_data_logger.vhd


    def __init__(self, controller=None):
        self.logger = logging.getLogger(__name__)
        self.logger_name = ':RP_PLL'

        self.sock = socket_placeholder()
        self.controller = controller
        self.valid_socket = False

        self.type_to_format_string = {False: '=III',
                                      True: '=IIi'}

    def socketErrorEvent(self, e):
        # disconnect from socket, and start reconnection timer:
        print("RP_PLL::socketErrorEvent()")
        if self.controller is not None:
            self.controller.socketErrorEvent(e)
        else:
            # we are running in stand-alone mode
            self.CloseTCPConnection()
            raise CommsLoggeableError(e)

    def CloseTCPConnection(self):
        print("RP_PLL_device::CloseTCPConnection()")
        self.sock = None # socket_placeholder()
        self.valid_socket = False

    def OpenTCPConnection(self, HOST, PORT=5000, valid_socket_for_general_comms=True):
        print("RP_PLL_device::OpenTCPConnection(): HOST = '%s', PORT = %d" % (HOST, PORT))
        self.HOST = HOST
        self.PORT = PORT
        self.sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
        self.sock.setsockopt(socket.IPPROTO_TCP, socket.TCP_NODELAY, 1) # this avoids a ~33 ms on Windows before our request packets are sent (!!)
        # self.sock.setblocking(1)
        self.sock.settimeout(2)
        try:
            self.sock.connect((self.HOST, self.PORT))
            self.valid_socket = valid_socket_for_general_comms
        except Exception as e:
            logging.error(traceback.format_exc())
            self.valid_socket = False

    # from http://stupidpythonideas.blogspot.ca/2013/05/sockets-are-byte-streams-not-message.html
    def recvall(self, count):
        buf = b''
        
        while count:
            newbuf = self.sock.recv(count)
            if not newbuf: return None
            buf += newbuf
            count -= len(newbuf)
            
        return buf

    # Function used to send a file write command:
    def write_file_on_remote(self, strFilenameLocal, strFilenameRemote):
        # open local file and load into memory:
        file_data = np.fromfile(strFilenameLocal, dtype=np.uint8)
        try:
            # send header
            packet_to_send = struct.pack('=III', self.MAGIC_BYTES_WRITE_FILE, len(strFilenameRemote), len(file_data))
            self.sock.sendall(packet_to_send)
            # send filename
            self.sock.sendall(strFilenameRemote.encode('ascii'))
            # send actual file
            self.sock.sendall(file_data.tobytes())
        except OSError as e:
            print("RP_PLL.py: write_file_on_remote(): exception while sending file!")
            self.logger.warning('Red_Pitaya_GUI{}: write_file_on_remote(): exception while sending file!'.format(self.logger_name))
            self.socketErrorEvent(e)

    # Function used to send a shell command to the Red Pitaya:
    def send_shell_command(self, strCommand):
        try:
            # send header
            packet_to_send = struct.pack('=III', self.MAGIC_BYTES_SHELL_COMMAND, len(strCommand), 0)
            self.sock.sendall(packet_to_send)
            # send command
            self.sock.sendall(strCommand.encode('ascii'))
        except OSError as e:
            print("RP_PLL.py: send_shell_command(): exception while sending command!")
            self.logger.warning('Red_Pitaya_GUI{}: send_shell_command(): exception while sending command!'.format(self.logger_name))
            self.socketErrorEvent(e)

    # Function used to reboot the monitor-tcp program
    def send_reboot_command(self):
        try:
            # send header
            packet_to_send = struct.pack('=III', self.MAGIC_BYTES_REBOOT_MONITOR, 0, 0)
            self.sock.sendall(packet_to_send)
        except OSError as e:
            print("RP_PLL.py: send_reboot_command(): exception while sending command!")
            self.logger.warning('Red_Pitaya_GUI{}: send_reboot_command(): exception while sending command!'.format(self.logger_name))
            self.socketErrorEvent(e)

    def validate_address(self, addr):
        if addr % 4:
            raise Exception("validate_address", "non-32-bits-aligned write/read")

        return True

    #######################################################
    # Functions used to access the memory-mapped registers of the Zynq
    #######################################################

    def send(self, packet_to_send):
        if self.valid_socket == False:
            raise CommsError

        try:
            self.sock.sendall(packet_to_send)
        except OSError as e:
            print("RP_PLL::send(): caught exception")
            logging.error(traceback.format_exc())
            self.socketErrorEvent(e)
        except:
            print("RP_PLL::read(): unhandled exception")

    def read(self, bytes_to_read):
        if self.valid_socket == False:
            raise CommsError

        data_buffer = None
        try:
            data_buffer = self.recvall(bytes_to_read)
        except OSError as e:
            print("RP_PLL::read(): caught exception")
            logging.error(traceback.format_exc())
            self.socketErrorEvent(e)
        except:
            print("RP_PLL::read(): unhandled exception")

        if data_buffer is None:
            return bytes(bytes_to_read)
        else:
            return data_buffer

    def write_Zynq_register_32bits(self, absolute_addr, data_32bits, bSigned=False):
        self.validate_address(absolute_addr)
        packet_to_send = struct.pack(self.type_to_format_string[bSigned], self.MAGIC_BYTES_WRITE_REG, absolute_addr, int(data_32bits) & 0xFFFFFFFF)
        self.send(packet_to_send)

    def read_Zynq_register_32bits(self, absolute_addr, bIsAXI=False):
        self.validate_address(absolute_addr)
        packet_to_send = struct.pack('=III', self.MAGIC_BYTES_READ_REG, absolute_addr, 0)  # last value is reserved
        self.send(packet_to_send)
        return self.read(4)

    def read_Zynq_buffer_int16(self, number_of_points):
        if number_of_points > self.MAX_SAMPLES_READ_BUFFER:
            number_of_points = self.MAX_SAMPLES_READ_BUFFER
            print("number of points clamped to %d." % number_of_points)

        packet_to_send = struct.pack('=III', self.MAGIC_BYTES_READ_BUFFER, self.FPGA_BASE_ADDR, number_of_points)    # last value is reserved
        self.send(packet_to_send)
        return self.read(int(2*number_of_points))

    #######################################################
    # Functions used to access Zynq registers, but which do not interact directly with the socket,
    # and instead use the lower-level functions above
    #######################################################

    def write_Zynq_register_uint32(self, address_uint32, data_uint32):
        self.write_Zynq_register_32bits(self.FPGA_BASE_ADDR+address_uint32, data_uint32, bSigned=False)

    def write_Zynq_register_int32(self, address_uint32, data_int32):
        self.write_Zynq_register_32bits(self.FPGA_BASE_ADDR+address_uint32, data_int32, bSigned=True)

    def write_Zynq_AXI_register_uint32(self, address_uint32, data_uint32):
        self.write_Zynq_register_32bits(self.FPGA_BASE_ADDR_XADC+address_uint32, data_uint32, bSigned=False)

    def read_Zynq_register_uint32(self, address_uint32):
        data_buffer = self.read_Zynq_register_32bits(self.FPGA_BASE_ADDR+address_uint32)
        register_value_as_tuple = struct.unpack('I', data_buffer)
        return register_value_as_tuple[0]

    def read_Zynq_register_int32(self, address_uint32):
        data_buffer = self.read_Zynq_register_32bits(self.FPGA_BASE_ADDR+address_uint32)
        register_value_as_tuple = struct.unpack('i', data_buffer)
        return register_value_as_tuple[0]

    def read_Zynq_AXI_register_uint32(self, address_uint32):
        data_buffer = self.read_Zynq_register_32bits(self.FPGA_BASE_ADDR_XADC+address_uint32)
        register_value_as_tuple = struct.unpack('I', data_buffer)
        return register_value_as_tuple[0]

    def read_Zynq_register_uint64(self, address_uint32_lsb, address_uint32_msb):
        print("read_Zynq_register_uint64()")
        results_lsb = self.read_Zynq_register_uint32(address_uint32_lsb)
        results_msb = self.read_Zynq_register_uint32(address_uint32_msb)

        # convert to 64 bits using numpy's casts
        results = np.array((results_lsb, results_msb), np.dtype(np.uint32))
        results = np.frombuffer(results, np.dtype(np.uint64) )

        return results

    def read_Zynq_register_int64(self, address_uint32_lsb, address_uint32_msb):
        # print "read_Zynq_register_uint64()"
        results_lsb = self.read_Zynq_register_uint32(address_uint32_lsb)
        results_msb = self.read_Zynq_register_uint32(address_uint32_msb)

        # convert to 64 bits using numpy's casts
        results = np.array((results_lsb, results_msb), np.dtype(np.uint32))
        results = np.frombuffer(results, np.dtype(np.int64) )

        return results

    #######################################################
    # Functions to emulate the Opal Kelly API:
    #######################################################
    # this function is now disabled because we simply implemented "triggers" differently: they are simply the update_flag of an empty, but otherwise standard parallel bus register
    # def ActivateTriggerIn(self, endpoint, value):
    #   # this should send a trigger, most likely by toggling a value, and having the fpga diff that value
    #   # or it could be simply a write to a dummy address and we just use the sys_we as the trigger
    #   # although I am not sure if it is guaranteed to be 1-clock-cycle long
    #   #print('ActivateTriggerIn(): TODO')
    #   self.write_Zynq_register_uint32((endpoint+value)*4+value*4, 0)

    def SetWireInValue(self, endpoint, value_16bits):
        # this only needs to update the internal state
        # for this, there would need to be two versions of the internal state, so that we can diff them and commit only the addresses that have changed
        # but its much simpler for now to just commit the change directly
        # the multiply by 4 is because right now the zynq code doesn't work unless reading on a 32-bits boundary, so we map the addresses to different values
        if value_16bits < 0:
            # write as a signed value
            self.write_Zynq_register_int32(endpoint*4, value_16bits)
        else:
            # write as an unsigned value
            self.write_Zynq_register_uint32(endpoint*4, value_16bits)


    def UpdateWireIns(self):
        # commit changes to the fpga
        # Wire ins are from the PC to the FPGA
        # for now we don't do anything since every SetWireInValue() call actually commits the changes to the fpga...
        #print('UpdateWireIns(): TODO')
        return

    def GetWireOutValue(self, endpoint):
        # print('GetWireOutValue(): TODO')
        # this reads a single 32-bits value from the fpga registers
        # the Opal Kelly code expected a 16-bits value, so we mask them out for compatibility
        rep = self.read_Zynq_register_uint32(4*endpoint)
        return rep & 0xFFFF # the multiply by 4 is because right now the zynq code doesn't work unless reading on a 32-bits boundary, so we map the addresses to different values

    def UpdateWireOuts(self):
        # wire outs are from the FPGA to the PC
        # in the Opal Kelly API, this function was necessary to perform a read (ie to update the values returned by GetWireOutValue)
        # but with the Red Pitaya Zynq, we actually perform the read at every GetWireOutValue() call, 
        # and this function is completely unecessary
        return 0

    def ReadFromPipeOut(self, pipe_address, buffer):
        # read bytes into the buffer, which is a pre-allocated string of the right length
        #buffer = "\x00"*len(buffer)    # for now, return all zeros only
#        print "ReadFromPipeOut: address = %d" % pipe_address
        buffer = self.read_Zynq_buffer_int16(int(round(len(buffer)/2)))

        return len(buffer)



def main():
    rp = RP_PLL_device()
    rp.OpenTCPConnection("192.168.1.100")
    #rp.sock.sendall(struct.pack('=IHhIiIhd', 0xABCD1236, 0, -8*1024, 3, 16*1024, 5, -1, 1.0000000000000004))
    magic_bytes_flank_servo = 0xABCD1236
    iStopAfterZC = 1    # 1 or 0 (true or false)
    ramp_minimum = -8*1024  # -8*1024 is the minimum of the DAC output (-1V into 50 ohms)
    number_of_ramps = 3
    number_of_steps = 16*1024   # 16*1024 is the full span of the dac output (2 Vpp into 50 ohms)
    max_iterations = 500000
    threshold_int16 = 2300
    ki = 1e-3
    
    print("calling sendall")
    for k in range(1):
        rp.sock.sendall(struct.pack('=IHhIiIhd', magic_bytes_flank_servo, iStopAfterZC,
                                    ramp_minimum, number_of_ramps, number_of_steps, 
                                    max_iterations, threshold_int16, ki))
        print("after sendall, calling recvall")
        if max_iterations != 0:
            data_buffer = rp.recvall((number_of_ramps*number_of_steps+max_iterations)*2*2)
            print("after recvall")
            data_np = np.fromstring(data_buffer, dtype=np.int16)
    print('before sleep')
    if max_iterations == 0:
        time.sleep(5)
    print('after sleep')
    rp.sock.close()
    
    
    
    if max_iterations != 0:
        # show data
        plt.close('all')
        plt.figure()
        plot(data_np[1::2], data_np[0::2])
        plt.figure()
        plot(data_np[0::2])
        plt.figure()
        plot(data_np[1::2])
        
        return data_np
    else:
        return 0

def main2():
#if 1:
    rp = RP_PLL_device()
    rp.OpenTCPConnection("192.168.2.12")
    
#    rp.write_file_on_remote(strFilenameLocal='d:\\test_file.bin', strFilenameRemote='/opt/test_file.bin')
    

    
    time.sleep(3)
    print("quitting")
    return
    
    
    addr_housekeeping = 3
    addr_leds = 0x00030
    
    address_uint32 = (addr_housekeeping << 20) + addr_leds
    data_uint32 = 8+1*16
    rp.write_Zynq_register_uint32(address_uint32, data_uint32)
#   
#   addr_vco = 2Z
#   addr_vco_amplitude = 0x0000
#   addr_vco_freq_msb  = 0x0004
#   addr_vco_freq_lsb  = 0x0008
#   
#   vco_amplitude = round(0.01*(2**15-1))
#   vco_freq_word = np.array([round((15e6/100e6+1./600.)*2.**48)]).astype(np.int64)
#   # break vco word into msbs and lsbs:
#   vco_freq_word_msbs = vco_freq_word >> 32
#   vco_freq_word_lsbs = np.bitwise_and(vco_freq_word, (1<<32)-1)
#   
#   # write amplitude
#   address_uint32 = (addr_vco << 20) + addr_vco_amplitude
#   data_uint32 = vco_amplitude
#   rp.write_Zynq_register_uint32(address_uint32, data_uint32)
#   # write msbs
#   address_uint32 = (addr_vco << 20) + addr_vco_freq_msb
#   data_uint32 = vco_freq_word_msbs
#   rp.write_Zynq_register_uint32(address_uint32, vco_freq_word_msbs)
#   # write lsbs
#   address_uint32 = (addr_vco << 20) + addr_vco_freq_lsb
#   data_uint32 = vco_freq_word_lsbs
#   rp.write_Zynq_register_uint32(address_uint32, vco_freq_word_lsbs)
    
    # write some frequency
    addr_dpll = 0
    addr_ref_freq_msb = 0x8001
    address_uint32 = (addr_dpll << 20) + addr_ref_freq_msb*4    # times 4 due to address space translation
    rp.write_Zynq_register_uint32(address_uint32, 0x1000)

    # first trigger a write
    addr_logger = 1
    addr_trig_write = 0x1004
    address_uint32 = (addr_logger << 20) + addr_trig_write
    rp.write_Zynq_register_uint32(address_uint32, 0)
 
    address_uint32 = 0  # apparently this is currently unused
    number_of_points = rp.MAX_SAMPLES_READ_BUFFER   
    data_buffer = rp.read_Zynq_buffer_int16(number_of_points)
#   print("after recvall")
    data_np = np.fromstring(data_buffer, dtype=np.int16)
    print(data_np)
    for k in range(10):
        print('%d:\t%s' % (k, hex((data_np[k])&0xFFFF)))
#    print hex(data_np[7])
#    print hex(data_np[7])
#    print hex(data_np[7])
    
    plt.figure()
    plt.plot(data_np, '.-')
    
#   spc = np.fft.fft(data_np * np.blackman(len(data_np)))
#   plt.figure()
#   plt.plot(10*np.log10(np.abs(spc)**2.))
    
#   return data_np
        
if __name__ == '__main__':
##    data_np = main()
    main2()
    
