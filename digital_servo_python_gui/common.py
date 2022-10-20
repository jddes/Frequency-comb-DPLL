""" Functions used by multiple classes in this program """
import os
import errno
import socket

import time
import inspect
import numpy as np

style_sheets = {
    'Normal': '',
    'bad': 'color: rgb(255, 255, 255); background-color: rgb(231, 0, 50)',
    'warning': 'background-color: rgb(250, 151, 0)',
    'ok': 'color: rgb(255, 255, 255); background-color: rgb(0, 165, 114)',
}


def bitmask(Nbits):
    return (1 << Nbits)-1


def round_to_N_sig_figs(x, Nsigfigs):
    """ Returns x rounded to Nsigfigs significant figures """
    leading_pos = np.floor(np.log10(np.abs(x)))
    factor = 10**((Nsigfigs-1)-leading_pos)
    return np.round(x * factor)/factor


def show_N_sig_figs(x, Nsigfigs):
    """ Returns a string representing the value x with Nsigfigs significant figures """
    leading_pos = np.floor(np.log10(np.abs(x)))
    decimals = max(0, Nsigfigs - (leading_pos+1))
    format_str = "{:.%df}" % decimals
    return format_str.format(round_to_N_sig_figs(x, Nsigfigs))


def freq_text_eng_format(freq, Nsigfigs=2):
    """ Returns the text in engineering format (ie using Hz, kHz or MHz units)
    for a given frequency in Hz """
    if freq >= 1e6:
        text = show_N_sig_figs(freq/1e6, Nsigfigs) + " MHz"
    elif freq >= 1e3:
        text = show_N_sig_figs(freq/1e3, Nsigfigs) + " kHz"
    else:
        text = show_N_sig_figs(freq/1e0, Nsigfigs) + " Hz"
    return text


def freq_value_from_text(text):
    """ Returns the frequency value in Hz from the display text
    in engineering format (ie using Hz, kHz or MHz units)
    Inverse of freq_text_eng_format() function above """
    if text[-3:] == 'MHz':
        scale = 1e6
    elif text[-3:] == 'kHz':
        scale = 1e3
    else:
        scale = 1
    return float(text.split(' ')[0]) * scale


def readFloatFromTextbox(textbox):
    """ Attempt to read in a value from a textbox using eval() to allow inputs such as "10e6" to work.
    If this fails, set the textbox's background to red, and re-raise the exception
    If the read is succeeds, clear any stylesheet on that widget to return it to default color """
    try:
        value = float(eval(textbox.text()))
        textbox.setStyleSheet('') # set back to default style
    except (ValueError, SyntaxError):
        colorCoding(textbox, "bad")
        raise
    return value


def getSNRcolorName(SNR):
    if SNR <= 20:
        return 'bad'
    elif SNR <= 25:
        return 'warning'
    else:
        return 'ok'


def getPowerColorName(mean_power_dBm):
    if mean_power_dBm <= -40:
        return 'bad'
    elif mean_power_dBm <= -30:
        return 'warning'
    else:
        return 'ok'


def getExtClkColorName(ext_clk_freq):
    if ext_clk_freq <= 1e6:
        return 'bad'
    else:
        return 'ok'


def colorCoding(widget, color_name, font_size=None):
    if font_size is not None:
        font_size_text = 'font-size: %dpt;' % font_size
    else:
        font_size_text = ''
    widget.setStyleSheet(font_size_text + style_sheets[color_name])


def tictoc(obj, text=None):
    """ Prints the calling function's name, the provided string 'text'
    and the elapsed time since the object's last call to tictoc() (this function).
    Doesn't print anything if obj.bDisplayTiming is not True """
    if not obj.bDisplayTiming:
        return

    t = time.perf_counter()
    if text != None:
        caller_stack_frame = inspect.stack()[1]
        caller_name = caller_stack_frame.function
        print("%s: %s: %.1f ms" % (caller_name, text, 1e3*(t-obj.tictoc_last)))
    obj.tictoc_last = t


def smooth(x,window_len=11,window='hanning'):
    """smooth the data using a window with requested size.
    
    This method is based on the convolution of a scaled window with the signal.
    The signal is prepared by introducing reflected copies of the signal 
    (with the window size) in both ends so that transient parts are minimized
    in the begining and end part of the output signal.
    
    input:
        x: the input signal 
        window_len: the dimension of the smoothing window; should be an odd integer
        window: the type of window from 'flat', 'hanning', 'hamming', 'bartlett', 'blackman'
            flat window will produce a moving average smoothing.

    output:
        the smoothed signal
        
    example:

    t=linspace(-2,2,0.1)
    x=sin(t)+randn(len(t))*0.1
    y=smooth(x)
    
    see also: 
    
    numpy.hanning, numpy.hamming, numpy.bartlett, numpy.blackman, numpy.convolve
    scipy.signal.lfilter
 
    TODO: the window parameter could be the window itself if an array instead of a string
    NOTE: length(output) != length(input), to correct this: return y[(window_len/2-1):-(window_len/2)] instead of just y.
    """

    if x.ndim != 1:
        raise ValueError("smooth only accepts 1 dimension arrays.")

    if x.size < window_len:
        raise ValueError("Input vector needs to be bigger than window size.")


    if window_len<3:
        return x


    if not window in ['flat', 'hanning', 'hamming', 'bartlett', 'blackman']:
        raise ValueError("Window is on of 'flat', 'hanning', 'hamming', 'bartlett', 'blackman'")


    s=np.r_[x[window_len-1:0:-1],x,x[-1:-window_len:-1]]
    #print(len(s))
    if window == 'flat': #moving average
        w=np.ones(window_len,'d')
    else:
        w=eval('np.'+window+'(window_len)')

    y=np.convolve(w/w.sum(),s,mode='valid')
    return y[(window_len//2-1):-(window_len//2)]


# From: http://stackoverflow.com/questions/273192/create-directory-if-it-doesnt-exist-for-file-write
def make_sure_path_exists(path):
    try:
        os.makedirs(path)
    except OSError as exception:
        if exception.errno != errno.EEXIST:
            raise

def test_findMostLikelyLANBroadcastIPAddress():
    ipv4Addresses = ["192.168.2.10", "192.168.1.10", "10.1.1.25"]
    assert(findMostLikelyLANBroadcastIPAddress_inner(ipv4Addresses) == "192.168.1.255")

def findMostLikelyLANBroadcastIPAddress():
    """ list all possible IPv4 addresses and choose the most likely candidate for the subnet on which the red pitaya is
    heuristics used:
       -choose the subnet that has the lowest third byte: eg if there are both 192.168.1.10 and 192.168.2.10, chooose 129.168.1.10 as the correct one
       -prefer if the address starts with 192.168 (not actually implemented yet)
    """
    listAddr = socket.getaddrinfo(socket.gethostname(), None)
    ipv4Addresses = [sockaddr[0] for (family, _, _, _, sockaddr) in listAddr if family == socket.AF_INET]
    return findMostLikelyLANBroadcastIPAddress_inner(ipv4Addresses)

def findMostLikelyLANBroadcastIPAddress_inner(ipv4Addresses):

    # move addresses that start with 192.168.x.y at the top of the list:
    priorityList    = [ip for ip in ipv4Addresses if ip.startswith('192.168')]
    nonPriorityList = [ip for ip in ipv4Addresses if not ip.startswith('192.168')]

    # sort according to third byte's value:
    third_bytes_value = lambda x: int(x.split('.')[2])
    priorityList.sort(   key = third_bytes_value)
    nonPriorityList.sort(key = third_bytes_value)
    fullList = priorityList + nonPriorityList

    for ip in fullList:
        print('IP candidate: %s' % ip)

    addrCandidate = fullList[0]
        print('Chosen local IP: %s' % addrCandidate)


    # Take this machine's IP address and transform into broadcast address for the whole subnet (change last byte to 255)
    addrSplit = addrCandidate.split('.')
    addrSplit[3] = '255'
    strBroadCastAddress = '.'.join(addrSplit)

    print('Chosen broadcast IP: %s' % strBroadCastAddress)

    return strBroadCastAddress


def waitUntilNextTimeQuanta(time_quantum=10):
    """ sleep until the current time is greater or equal to
    the time at start rounded up to the nearest time_quantum.
    This is meant to be used for rough synchronization 
    of data acquisition across multiple processes
    without doing inter-process communication """
    time_now = time.time()
    time_target = np.ceil(time_now/time_quantum) * time_quantum
    print('time_now = %f, time_target = %f' % (time_now, time_target))
    
    while time_target > time_now:
        time.sleep(1e-3)
        time_now = time.time()


if __name__ == '__main__':
    test_findMostLikelyLANBroadcastIPAddress()
