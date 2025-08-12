cdef struct dynamic_arr:
    Py_ssize_t* arr
    Py_ssize_t size

cdef dynamic_arr _local_maxima_1d(const double* x, const Py_ssize_t size) noexcept nogil
cdef double* _peak_prominences(const double* x,
                      const Py_ssize_t* peaks, const Py_ssize_t x_size, const Py_ssize_t num_peaks) noexcept nogil
cdef unsigned char* _select_by_peak_distance(const Py_ssize_t* peaks,
                             const double* x,
                             Py_ssize_t distance, Py_ssize_t peaks_size) noexcept nogil
cdef Py_ssize_t* argsort(const double* priority, const Py_ssize_t prio_len) noexcept nogil