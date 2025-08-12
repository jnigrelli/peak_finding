# cython: boundscheck=False, wraparound=False

from libc.math cimport ceil

from libc.stdlib cimport malloc, realloc, free, qsort

from peak_finding._peak_finding_utils cimport dynamic_arr


cdef dynamic_arr _local_maxima_1d(const double* x, const Py_ssize_t size) noexcept nogil:
    cdef:
        Py_ssize_t* midpoints
        Py_ssize_t m, i, i_ahead, i_max
        Py_ssize_t* left_edges
        Py_ssize_t* right_edges
        dynamic_arr result

    # Preallocate, there can't be more maxima than half the size of `x`
    midpoints = <Py_ssize_t*> malloc(size // 2 * sizeof(Py_ssize_t))
    left_edges = <Py_ssize_t*> malloc(size // 2 * sizeof(Py_ssize_t))
    right_edges = <Py_ssize_t*> malloc(size // 2 * sizeof(Py_ssize_t))
    
    m = 0  # Pointer to the end of valid area in allocated arrays

    i = 1  # Pointer to current sample, first one can't be maxima
    i_max = size - 1  # Last sample can't be maxima
    while i < i_max:
        # Test if previous sample is smaller
        if x[i - 1] < x[i]:
            i_ahead = i + 1  # Index to look ahead of current sample

            # Find next sample that is unequal to x[i]
            while i_ahead < i_max and x[i_ahead] == x[i]:
                i_ahead += 1

            # Maxima is found if next unequal sample is smaller than x[i]
            if x[i_ahead] < x[i]:
                left_edges[m] = i
                right_edges[m] = i_ahead - 1
                midpoints[m] = (left_edges[m] + right_edges[m]) // 2
                m += 1
                # Skip samples that can't be maximum
                i = i_ahead
        i += 1

    # Keep only valid part of array memory.
    free(left_edges)
    free(right_edges)

    mem = <Py_ssize_t *> realloc(
        midpoints, (m+1) * sizeof(Py_ssize_t)
    )

    if not mem:
        with gil:
            raise MemoryError()
    
    midpoints = mem

    # return midpoints.base

    # RETURN array where 
    result.arr = midpoints
    result.size = m
    return result


cdef double* _peak_prominences(const double* x,
                      const Py_ssize_t* peaks, const Py_ssize_t x_size, const Py_ssize_t num_peaks) noexcept nogil:
    cdef:
        double left_min, right_min
        Py_ssize_t peak_nr, peak, i_min, i_max, i
        double* prominences
        Py_ssize_t* left_bases
        Py_ssize_t* right_bases

    prominences = <double*> malloc(num_peaks * sizeof(double))
    left_bases = <Py_ssize_t*> malloc(num_peaks * sizeof(Py_ssize_t))
    right_bases = <Py_ssize_t*> malloc(num_peaks * sizeof(Py_ssize_t))

    for peak_nr in range(num_peaks):
        peak = peaks[peak_nr]
        i_min = 0
        i_max = x_size - 1
        if not i_min <= peak <= i_max:
            with gil:
                raise ValueError("peak {} is not a valid index for `x`"
                                    .format(peak))

        # Find the left base in interval [i_min, peak]
        i = left_bases[peak_nr] = peak
        left_min = x[peak]
        while i_min <= i and x[i] <= x[peak]:
            if x[i] < left_min:
                left_min = x[i]
                left_bases[peak_nr] = i
            i -= 1

        # Find the right base in interval [peak, i_max]
        i = right_bases[peak_nr] = peak
        right_min = x[peak]
        while i <= i_max and x[i] <= x[peak]:
            if x[i] < right_min:
                right_min = x[i]
                right_bases[peak_nr] = i
            i += 1

        prominences[peak_nr] = x[peak] - max(left_min, right_min)
    
    # Return memoryviews as ndarrays
    free(left_bases)
    free(right_bases)

    return prominences


cdef struct priority_member:
    double value
    Py_ssize_t index


cdef int priority_compare(const void* a, const void* b) noexcept nogil:
    cdef priority_member *a1 = <priority_member*> a
    cdef priority_member *b1 = <priority_member*> b

    cdef double value_a1 = a1.value
    cdef double value_b1 = b1.value

    if value_a1 > value_b1:
        return 1
    elif value_b1 > value_a1:
        return -1
    else:
        return 0

cdef Py_ssize_t* argsort(const double* priority, const Py_ssize_t prio_len) noexcept nogil:
    cdef priority_member* pairs = <priority_member*> malloc(
        prio_len * sizeof(priority_member)
    )

    cdef Py_ssize_t i = 0
    for i in range(prio_len):
        pairs[i].value = priority[i]
        pairs[i].index = i
    
    qsort(pairs, prio_len, sizeof(priority_member), priority_compare)

    cdef Py_ssize_t* indices = <Py_ssize_t*> malloc(
        prio_len * sizeof(Py_ssize_t)
    )

    for i in range(prio_len):
        indices[i] = pairs[i].index

    free(pairs)
    return indices


cdef unsigned char* _select_by_peak_distance(const Py_ssize_t* peaks,
                             const double* x,
                             Py_ssize_t distance, Py_ssize_t peaks_size) noexcept nogil:
    cdef:
        unsigned char* keep
        double* priority
        Py_ssize_t* priority_to_position
        Py_ssize_t i, j, k
    keep = <unsigned char*> malloc(
        peaks_size * sizeof(unsigned char)
    )

    priority = <double*> malloc(
        peaks_size * sizeof(double)
    )

    for i in range(peaks_size):
        keep[i] = 1
        priority[i] = x[peaks[i]]

    # Create map from `i` (index for `peaks` sorted by `priority`) to `j` (index
    # for `peaks` sorted by position). This allows to iterate `peaks` and `keep`
    # with `j` by order of `priority` while still maintaining the ability to
    # step to neighbouring peaks with (`j` + 1) or (`j` - 1).
    # print(f"priority size: {priority.size}")
    priority_to_position = argsort(priority, peaks_size)

    # Highest priority first -> iterate in reverse order (decreasing)
    for i in range(peaks_size - 1, -1, -1):
        # "Translate" `i` to `j` which points to current peak whose
        # neighbours are to be evaluated
        j = priority_to_position[i]
        if keep[j] == 0:
            # Skip evaluation for peak already marked as "don't keep"
            continue

        k = j - 1
        # Flag "earlier" peaks for removal until minimal distance is exceeded
        while 0 <= k and peaks[j] - peaks[k] < distance:
            keep[k] = 0
            k -= 1

        k = j + 1
        # Flag "later" peaks for removal until minimal distance is exceeded
        while k < peaks_size and peaks[k] - peaks[j] < distance:
            keep[k] = 0
            k += 1


    free(priority)
    free(priority_to_position)
    return keep  # Return as boolean array