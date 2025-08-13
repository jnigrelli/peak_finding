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


def find_peak(x, height=None, threshold=None, distance=None,
        prominence=None, width=None, wlen=None, rel_height=0.5,
        plateau_size=None):
    """Python wrapper to _find_peak."""
    if height is not None:
        raise ValueError("height is not implemented yet")
    
    if threshold is not None:
        raise ValueError("threshold is not implemented yet")

    if width is not None:
        ValueError("width is not implemented yet")
    
    if wlen is not None:
        ValueError("wlen is not implemented yet")

    if rel_height is not None:
        ValueError("rel_height is not implemented yet")
    
    if plateau_size is not None:
        ValueError("plateau_size is not implemented yet")
    
    cdef double [:] view = x

    return _find_peak(&view[0], prominence, distance, view.size)


def find_peaks(x, height=None, threshold=None, distance=None,
        prominence=None, width=None, wlen=None, rel_height=0.5,
        plateau_size=None):
    """Python wrapper to _find_peaks."""
    if height is not None:
        raise ValueError("height is not implemented yet")
    
    if threshold is not None:
        raise ValueError("threshold is not implemented yet")

    if width is not None:
        ValueError("width is not implemented yet")
    
    if wlen is not None:
        ValueError("wlen is not implemented yet")

    if rel_height is not None:
        ValueError("rel_height is not implemented yet")
    
    if plateau_size is not None:
        ValueError("plateau_size is not implemented yet")
    
    cdef double [:] view = x
    cdef dynamic_arr darr = _find_peaks(&view[0], prominence, distance, x.size)

    cdef Py_ssize_t [:] darr_view = <Py_ssize_t[:darr.size]> darr.arr # type: ignore
    res = np.array(darr_view)

    free(darr.arr)
    return res