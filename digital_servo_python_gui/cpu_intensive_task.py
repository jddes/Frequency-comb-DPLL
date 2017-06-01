# -*- coding: utf-8 -*-
"""
Created on Fri Feb 14 12:13:38 2014

@author: jnd
"""

import numpy as np

data = np.random.randn(1e6)
while 1:
    data = np.fft.fft(data)
    