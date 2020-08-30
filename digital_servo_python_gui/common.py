""" Functions used by multiple classes in this program """
import os, errno
import time
import inspect
import numpy as np

style_sheets = {
    'Normal': '',
    'bad': 'color: rgb(255, 255, 255); background-color: rgb(231, 0, 50)',
    'warning': 'background-color: rgb(250, 151, 0)',
    'ok': 'color: rgb(255, 255, 255); background-color: rgb(0, 165, 114)',
}

def readFloatFromTextbox(textbox):
    """ Attempt to read in a value from a textbox using eval() to allow inputs such as "10e6" to work.
    If this fails, set the textbox's background to red, and re-raise the exception
    If the read is succeeds, clear any stylesheet on that widget to return it to default color """
    try:
        value = float(eval(textbox.text()))
        textbox.setStyleSheet('') # set back to default style
    except ValueError:
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
    elif mean_power_dBm <= -20:
        return 'warning'
    else:
        return 'ok'

def colorCoding(widget, color_name, font_size=None):
    if font_size is not None:
        font_size_text = 'font-size: %dpt;' % font_size
    else:
        font_size_text = ''
    widget.setStyleSheet(font_size_text + style_sheets[color_name])

def round_to_N_sig_figs(x, Nsigfigs):
    leading_pos = np.floor(np.log10(np.abs(x)))
    factor = 10**((Nsigfigs-1)-leading_pos)
    return np.round(x * factor)/factor

# From: http://stackoverflow.com/questions/273192/create-directory-if-it-doesnt-exist-for-file-write
def make_sure_path_exists(path):
    try:
        os.makedirs(path)
    except OSError as exception:
        if exception.errno != errno.EEXIST:
            raise

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