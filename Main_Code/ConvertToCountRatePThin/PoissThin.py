#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Fri Aug 19 11:02:24 2022
@author: Robert Stillwell, NCAR
"""

import numpy

def PoissThin(a):
    s = numpy.array(a).astype(numpy.int64, casting='unsafe')
    f = numpy.random.binomial(s, 0.5, size=s.shape)
    g = s - f
    return f, g

if __name__ == '__main__':
    try:
        x
    except:
        x = [10,10,10]
    F = PoissThin(x)