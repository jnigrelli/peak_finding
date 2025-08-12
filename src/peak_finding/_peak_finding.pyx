# cython: boundscheck=False, wraparound=False
from peak_finding._peak_finding_utils cimport _local_maxima_1d, _peak_prominences, dynamic_arr, _select_by_peak_distance


import numpy as np
# cimport numpy as cnp
from libc.stdlib cimport malloc, realloc, free


cdef dynamic_arr keep_func(const Py_ssize_t* arr, const unsigned char* indices,\
    const Py_ssize_t num_indices) noexcept nogil:

    cdef:
        dynamic_arr keep
        Py_ssize_t* new_arr = <Py_ssize_t*> malloc(
            num_indices * sizeof(Py_ssize_t)
        )
        Py_ssize_t i = 0
        Py_ssize_t bound = 0


    for i in range(num_indices):
        if indices[i] > 0:
            new_arr[bound] = arr[i]
            bound += 1
    
    keep.size = bound

    if bound == 0:
        keep.arr = <Py_ssize_t*> NULL
    else:
        new_arr = <Py_ssize_t *> realloc(
            new_arr, bound * sizeof(Py_ssize_t)
        )
        keep.arr = new_arr

    return keep


cdef unsigned char* _select_by_property(const double* peak_properties, const double pmin, const Py_ssize_t size) noexcept nogil:
    # keep = np.ones(peak_properties.size, dtype=bool)
    cdef unsigned char* keep = <unsigned char*> malloc(
        size * sizeof(unsigned char)
    )

    cdef Py_ssize_t i = 0
    for i in range(size):
        if pmin <= peak_properties[i]:
            keep[i] = 1
        else:
            keep[i] = 0

    # if pmin is not None:
    #     keep &= (pmin <= peak_properties)
    return keep

cdef Py_ssize_t find_peaks(const double* x, const double prominence, const Py_ssize_t distance, const Py_ssize_t size) noexcept nogil:
    cdef:
        Py_ssize_t peak_idx = -1
        dynamic_arr peaks
        unsigned char* keep
        Py_ssize_t* temp
        double* prominences
    
    peaks = _local_maxima_1d(x, size)

    keep = _select_by_peak_distance(peaks.arr, x, distance, peaks.size)

    temp = peaks.arr
    peaks = keep_func(peaks.arr, keep, peaks.size)
    free(temp)
    free(keep)
    
    prominences = _peak_prominences(x, peaks.arr, size, peaks.size)

    keep = _select_by_property(prominences, prominence, peaks.size)
    free(prominences)

    temp = peaks.arr
    peaks = keep_func(peaks.arr, keep, peaks.size)
    free(temp)
    free(keep)

    if peaks.size == 1:
        peak_idx = peaks.arr[0]
    
    free(peaks.arr)
    return peak_idx