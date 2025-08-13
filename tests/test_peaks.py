import numpy as np
import scipy.signal as signal

from tests.test_utils import DIV_1, DIV_2, DIV_3, DIV_NONE, PRIORITY,\
    DIV_PS_1, DIV_PS_2, DIV_PS_3

from peak_finding import find_peak, find_peaks
from peak_finding.interface import argsort_wrapper, keep_func_wrapper


def peak_template(div_samples):
    a, _ = signal.find_peaks(div_samples, prominence=0.15, distance=10)
    b = find_peak(div_samples, 0.15, 10)
    c = find_peaks(div_samples, 0.15, 10)

    assert np.allclose(a, c)

    if len(a) == 1:
        assert(a[0] == b)

    else:
        assert(b == -1)

def sort_from_argsort(func, arr):
    return arr[func(arr)]

def compare_argsort(func1, func2, arr):
    return np.allclose(sort_from_argsort(func1, arr),\
                    sort_from_argsort(func2, arr))

class TestPeakStandard:
    def test_peak_1(self):
        peak_template(DIV_1)

    def test_peak_2(self):
        peak_template(DIV_2)

    def test_peak_3(self):
        peak_template(DIV_3)

class TestPeakParseSingles:
    def test_pps1(self):
        peak_template(DIV_PS_1)
    def test_pps2(self):
        peak_template(DIV_PS_2)
    def test_pps3(self):
        peak_template(DIV_PS_3)
    

def test_peak_no_peak():
    peak_template(DIV_NONE)

def test_argsort_priority():
    assert(compare_argsort(argsort_wrapper, np.argsort, PRIORITY))

class TestKeepFunc():
    def helper(self, arr, keep):
        arr = np.array(arr, dtype=np.intp)
        keep = np.array(keep, dtype=bool)

        assert np.all(keep_func_wrapper(arr, keep) == arr[keep])

    def test_keep_normal(self):
        keep = np.array([0, 0, 1])
        arr = np.array([3, 9, 2])
        self.helper(arr, keep)
        
    
    def test_keep_none(self):
        keep = np.array([0, 0, 0])
        arr = np.array([4, 1, 3])

        self.helper(arr, keep)


    def test_keep_all(self):
        keep = np.array([1, 1, 1])
        arr = np.array([3, 2, 9])

        self.helper(arr, keep)