from peak_finding._peak_finding_utils cimport dynamic_arr

cdef dynamic_arr keep_func(const Py_ssize_t* arr, const unsigned char* indices,\
    const Py_ssize_t num_indices) noexcept nogil
cdef Py_ssize_t find_peaks(const double* x, const double prominence, const Py_ssize_t distance, const Py_ssize_t size) noexcept nogil