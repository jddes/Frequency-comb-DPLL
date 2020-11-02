# written for python 3
# converted from MATLAB script: read_from_rigol_scope.m

import socket
import select
import time
import numpy as np
import socket_tools

import traceback
import pprint

class Waveform():
    def __init__(self):
        self.data = np.array(0)
        pass

    def set_scalings(self, YIncrement, YOrigin, YReference, XIncrement):
        self.YIncrement = YIncrement
        self.YOrigin = YOrigin
        self.YReference = YReference
        self.XIncrement = XIncrement
        self.fs = 1/self.XIncrement

    def save_to_disk(self, strFile='rigol_output.bin'):

        # put fs as the first point:
        data_with_fs = np.concatenate((np.array([self.fs]), self.data))

        data_with_fs.tofile(strFile)
        # self.data.tofile(strFile)
        # to load the file in matlab:
        # f = memmapfile('D:\Université\Dropbox\Python3\rigol_output.bin', 'Format', 'double', 'Writable', false); data = f.Data; f = [];




    # helper function for testing:
    def __str__(self):
        return pprint.pformat(vars(self))

class RigolScope:

    # iVerbosity = 0 turns off all prints
    # iVerbosity = 1 displays minimal info
    # iVerbosity = 2 prints all the debugging info, including all text communication with the scope
    def __init__(self, iVerbosity=0):
        self.iVerbosity = iVerbosity
        self.progress_update_callback = None
        pass

    @property
    def iVerbosity(self):
        return self._iVerbosity

    @iVerbosity.setter
    def iVerbosity(self, iVerbosity):
        self._iVerbosity = iVerbosity
        self.updateSocketVerbosity()

    def updateSocketVerbosity(self):
        try:
            self.s.bVerbosity = (self._iVerbosity>=2) # also pass the verbose setting to the socket object
        except AttributeError:
            pass

    # Socket-related functions:
    ###########################################################
    # The IP address can be found from either:
    #    -router's DHCP table
    #    -from instrument (Utility menu)
    # MAC address is 00-19-AF-35-59-68 (shows up as "Appareil inconnu" in Bell's router's DHCP table)
    def connect(self, strIPAddress = '192.168.2.22', port_number = 5555):
        self.strIPAddress = strIPAddress
        self.port_number = port_number

        # set socket options
        self.s = socket_tools.EasySocket(socket.AF_INET, socket.SOCK_STREAM)
        self.updateSocketVerbosity()
        self.s.settimeout(2)
        self.s.setsockopt(socket.SOL_SOCKET, socket.SO_RCVBUF, int(10e6))
        self.s.connect((self.strIPAddress, self.port_number))

    def disconnect(self):
        self.s.close()

    # Low-level functions:
    ###########################################################
    def ensure_str_has_eol(self, strTest):
        if strTest[-1] != '\n':
            traceback.print_stack(limit=5)
            print("warning: adding eol char to string '%s'" % strTest)
            return strTest + '\n'
        else:
            return strTest

    def send_cmd(self, strCmd):
        strCmd = self.ensure_str_has_eol(strCmd)
        self.s.send_str(strCmd)

    def query_line(self, strQuery):
        self.send_cmd(strQuery)
        return self.s.read_line()

    def query_float(self, strQuery):
        strLine = self.query_line(strQuery)
        try:
            result = float(strLine)
        except ValueError:
            result = None

        return result


    # Higher-level functions:
    ###########################################################

    # for testing the connection
    # TODO: change this to use query_line()
    def get_identification(self):
        return self.query_line('*IDN?\n')

    def verify_mode(self, strDesiredMode='raw'):
        mode_str = self.query_line(':waveform:mode?\n')
        if mode_str.lower() == strDesiredMode.lower():
            return True
        else:
            traceback.print_stack(limit=5)
            print("Error: expected '%s' waveform mode. Current mode string = %s" % (strDesiredMode, mode_str))
            print("Please make sure that the scope is in the correct mode before calling this function")
            return False

    def read_waveform_settings(self):
        # we only support "raw" mode (as opposed to "normal") so we first check that this is the case:
        if not self.verify_mode('raw'):
            return None

        YIncrement = self.query_float(':waveform:YIncrement?\n')
        YOrigin    = self.query_float(':waveform:YOrigin?\n')
        YReference = self.query_float(':waveform:YReference?\n')
        XIncrement = self.query_float(':waveform:XIncrement?\n')

        waveform_obj = Waveform()
        waveform_obj.set_scalings(YIncrement, YOrigin, YReference, XIncrement)
        return waveform_obj

    # Important: set channel_number to what you want (1-4)
    # (channel is not autodetected even if there is only one active)
    def read_waveform(self, channel_number=1):
        # RAW mode reads all waveform data, but requires scope to be stopped
        # NORMal: read the waveform data displayed on the screen. 
        self.send_cmd(':stop\n')
        self.send_cmd(':waveform:mode raw\n')
        # self.send_cmd(':waveform:mode normal\n');
        self.send_cmd(':waveform:source channel%d\n' % channel_number)

        waveform_obj = self.read_waveform_settings()
        raw_data     = self.read_waveform_raw_data()
        if raw_data is not None:
            data_np  = self.scale_results_to_physical_units(raw_data, waveform_obj)
            waveform_obj.data = data_np

        return waveform_obj

    def read_waveform_raw_data(self):

        memory_depth_str = self.query_line(':acquire:Mdepth?\n')
        if memory_depth_str == 'AUTO\n':
            # we don't know how to handle this case: the scope just won't tell
            # I don't know how to ask the scope the waveform size if we are in auto mode, so instead we ask the user to change it:
            print('Error: Scope Memory Depth setting is set to "AUTO", which is not supported by this script.\nPlease set the memory depth manually in the "Acquire" menu')
            raise Exception('exit')
        memory_depth = int(float(memory_depth_str))

        # word, byte or ascii
        # word format seems useless because it's just the same as byte with empty MSBs..
        # BYTE: a waveform point occupies one byte (namely 8 bits).
        # ASCii: return the actual voltage value of each waveform point in scientific notation. The voltage values are separated by commas.
        strFormat = 'byte';
        self.send_cmd(':WAVeform:FORMat %s\n' % strFormat)


        # can only read in chunks of 250k pts max for byte,
        # 15625 pts per chunk for ascii
        if strFormat.lower() == 'ascii':
            max_pts_per_chunk = int(15625)
        elif strFormat.lower() == 'byte':
            max_pts_per_chunk = int(250e3)
            # Note by JDD 2019-05-02: Today 1e6 pts per chunk doesn't actually work: it returns 0 (channel 3, 6 Mpts total, 500 MS/s)
            # from reply #61 on https://www.eevblog.com/forum/testgear/ethernet-transfer-speed-for-rigol-ds2072a-and-ds4014/50/ :
            # "Even though the documentation limits the block size to 250000, it is possible to use block size of 1000000, which considerably speeds the transfer up"
            # max_pts_per_chunk = 1000000 
            
        else:
            print('error: unsupported mode. choose "byte" or "ascii")\n')
            raise Exception('exit')

        # update display:
        if self.progress_update_callback is not None:
            if self.progress_update_callback(0, memory_depth) == False:
                # abort reading
                return None

        current_start_pt = 1
        current_stop_pt = current_start_pt + max_pts_per_chunk-1
        current_stop_pt = min(current_stop_pt, memory_depth)

        time_start = time.perf_counter()
        data = [0.0] * memory_depth
        while current_stop_pt <= memory_depth:

            self.send_cmd(':WAV:STAR %d\n' % current_start_pt);
            self.send_cmd(':WAV:STOP %d\n' % current_stop_pt);
            self.send_cmd(':WAVeform:DATA?\n');

            data_chunk = self.__read_TMC_data_chunk()
            
            data[current_start_pt-1:current_stop_pt] = data_chunk

            # update display:
            if self.progress_update_callback is not None:
                if self.progress_update_callback(current_stop_pt, memory_depth) == False:
                    # abort reading
                    return None

            if current_stop_pt == memory_depth:
                break

            current_start_pt = current_start_pt + max_pts_per_chunk
            current_stop_pt  = current_start_pt + max_pts_per_chunk-1
            current_stop_pt  = min(current_stop_pt, memory_depth)

        elapsed = time.perf_counter()-time_start

        if self.iVerbosity >= 1:
            print('%e bytes transfered in %.1f secs: %.2f Mbits/sec' % (len(data), elapsed, 8*len(data)/elapsed/1e6))
        
        self.s.empty_socket()

        
        return data

    def __read_TMC_data_chunk(self):
        # blob_header = char(fread(t, 2, 'char'));
        blob_header = self.s.recv(2)
        # print(blob_header)

        # parse TMC header:
        if blob_header[0] != ord('#'):
            print('error: unrecognized response format: does not start with "#" rep = %s' % blob_header)
            raise Exception('exit')
        
        # read the correct number of ascii chars which indicate the number of
        # bytes to be sent:
        chars_to_read = int(chr(blob_header[1]))
         #print('chars_to_read = %d' % chars_to_read)
        strNumOfBytes = self.s.recv(chars_to_read)
        # print('strNumOfBytes = %s' % strNumOfBytes)
        NumOfBytes = int(strNumOfBytes)
        # print('NumOfBytes = %d' % NumOfBytes)
        data_chunk = self.s.recvall(NumOfBytes)
        self.s.recv(1) # reads the last end-of-line

        return data_chunk

    def scale_results_to_physical_units(self, raw_data, waveform_obj):
        data_np = np.asarray(raw_data)
        return (data_np - waveform_obj.YOrigin - waveform_obj.YReference)* waveform_obj.YIncrement

    def setup_ac_triggering(self):
        # sets sweep = single, source = AC,
        # so that we can simply send manual triggers everytime we want a new trace
        self.send_cmd(':trig:mode edge\n')
        self.send_cmd(':trig:edge:source ac\n')
        self.send_cmd(':trig:sweep single\n')

    def get_current_dc_value(self, channel_number=1):
        """ scope must be set in ac triggering mode first """
        self.send_cmd(':single\n:tforce\n')
        w = self.read_waveform(channel_number=1)
        return (np.mean(w.data), np.std(w.data), w)

# ##

# time_axis = (0:length(data)-1)/fs
# [pxx f] = pwelch(detrend(data), round(length(data)/20), [], [], fs);

# figure;
# ax = subplot(211);
# plot(time_axis, data);
# ylabel('Value [V]');
# xlabel('Time [s]');
# ax(2) = subplot(212);
# loglog(f, sqrt(pxx)*1e9);
# xlabel('Freq [Hz]');
# ylabel('sqrt PSD [nV/sqrt(Hz)]');

def test_read_settings():
    s = RigolScope(iVerbosity = 2) # set iVerbosity >= 2 to see all text communication between the scope and the PC (data won't print out)
    s.connect()
    s.get_identification()
    # This should work:
    s.send_cmd(':waveform:mode raw\n')
    wav_obj = s.read_waveform_settings()
    assert wav_obj is not None, "test_read_settings(): case #1 FAILED"
    print(wav_obj)
    # this should fail:
    s.send_cmd(':waveform:mode normal\n')
    wav_obj = s.read_waveform_settings()
    assert wav_obj is None, "test_read_settings(): case #2 FAILED"

    s.disconnect()
    print("test_read_settings: PASSED")

def test_read_waveform():
    s = RigolScope(iVerbosity = 2) # set iVerbosity to >=2 to see all text communication between the scope and the PC (data won't print out)
    s.connect()
    s.progress_update_callback = progress_update_callback
    waveform_obj = s.read_waveform(channel_number=1)
    s.disconnect()
    waveform_obj.save_to_disk()
    print("test_read_waveform: PASSED")

def test_read_dc_value():
    s = RigolScope(iVerbosity = 0) # set iVerbosity to >=2 to see all text communication between the scope and the PC (data won't print out)
    s.progress_update_callback = progress_update_callback
    s.connect()
    s.setup_ac_triggering()
    (mean, std, w) = s.get_current_dc_value()
    print("%e pts at fs=%e Hz: %e s, avg=%.2f V, stddev=%.2fV" % (len(w.data), w.fs, len(w.data)/w.fs, mean, std))
    s.disconnect()
    # w.save_to_disk()

def progress_update_callback(last_saved_pt, total_pts):
    print("%d/%d" % (last_saved_pt, total_pts))
    return True

if __name__ == '__main__':
    import sys
    if len(sys.argv) > 1:
        arg = sys.argv[1]
    else:
        arg = ""

    if arg.lower() == "dc":
        test_read_dc_value()
    elif arg.lower() == "waveform":
        test_read_waveform()
    else:
        test_read_settings()
    # test_read_settings()
    # test_read_waveform()

    # s = RigolScope(iVerbosity = 2) # set iVerbosity to >=2 to see all text communication between the scope and the PC (data won't print out)
    # s.connect()
    # s.get_identification()
    # # print(s.get_identification())
    # s.read_waveform_settings()

