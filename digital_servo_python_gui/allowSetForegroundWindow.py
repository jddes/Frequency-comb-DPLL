# -*- coding: utf-8 -*-
"""
Created on Thu Feb 06 11:50:27 2014

@author: jnd
"""



import os   # used by allowSetForegroundWindow()

# This is a workaround to make our window show on top on Windows 7:
# Taken from https://bitbucket.org/tortoisehg/thg/src/232b9d263a5fbd05f39ebce5d7e6b053d813da3a/tortoisehg/hgqt/qtapp.py
def allowSetForegroundWindow():
    """Allow a given process to set the foreground window"""
    # processid = -1 means ASFW_ANY (i.e. allow any process)
    # processid = -1 also doesn't seem to work, but it works when I use the actual process ID of the current process.
    if os.name == 'nt':
        # on windows we must explicitly allow bringing the main window to
        # the foreground. To do so we must use ctypes
        processid = os.getpid()
        try:
            from ctypes import windll
            windll.user32.AllowSetForegroundWindow(processid)
        except ImportError:
            pass