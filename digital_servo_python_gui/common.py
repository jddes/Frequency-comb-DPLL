import os, errno
import time
import inspect

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