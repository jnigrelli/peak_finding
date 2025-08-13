"""Provide Python interfaces for `peak_finding` Cython functions."""
import numpy as np
from libc.stdlib cimport free

from peak_finding._peak_finding_utils cimport dynamic_arr, argsort
from peak_finding._peak_finding cimport keep_func, _find_peaks, _find_peak


def keep_func_wrapper(Py_ssize_t[::1] arr, const unsigned char[::1] indices):
    """A Python wrapper to keep_func for testing."""
    cdef dynamic_arr st = keep_func(&arr[0], &indices[0], arr.size)
    new_arr = st.arr
    size = st.size

    if new_arr != NULL:
        new_arr_view = <Py_ssize_t[:size]> new_arr #type: ignore
        return np.array(new_arr_view)

    return np.array([])


def argsort_wrapper(const double[::1] priority):
    """Wraps the C function `argsort` for use in Python (testing)."""
    arg_view = <Py_ssize_t[:len(priority)]> argsort(&priority[0], priority.size) #type: ignore
    return np.array(arg_view)


def find_peak(iterable, double prominence, Py_ssize_t distance):
    """Python wrapper to _find_peak."""
    cdef double [:] x = iterable

    return _find_peak(&x[0], prominence, distance, 400)


def find_peaks(iterable, double prominence, Py_ssize_t distance):
    """Python wrapper to _find_peaks."""
    cdef double [:] x = iterable
    cdef dynamic_arr darr = _find_peaks(&x[0], prominence, distance, iterable.size)

    cdef Py_ssize_t [:] darr_view = <Py_ssize_t[:darr.size]> darr.arr # type: ignore
    res = np.array(darr_view)

    free(darr.arr)
    return res