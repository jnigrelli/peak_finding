# `peak_finding`

A Cython implementation of part of the `scipy.signal` [`find_peaks`](https://docs.scipy.org/doc/scipy/reference/generated/scipy.signal.find_peaks.html) function.

Written as part of an internship at the [University of Michigan DNNG lab](https://dnng.engin.umich.edu/), working on the [AR HoloLens visualization](https://gitlab.eecs.umich.edu/umich-dnng/hololens-visualization-v2.0) project. This implementation of `find_peaks` completely releases the GIL, allowing for parallelization of tasks repeatedly calling the function.

---

# Overview

`find_peaks` takes a NumPy array of doubles as input and returns a tuple containing NumPy array consisting of the indices of all the peaks in the array and a dictionary (to mimic the properties returned by the SciPy implementation - the properties dictionary is not implemented yet). `find_peak` returns the index of a singular peak, or -1 if there is more than one. At the moment, the `find_peaks` function requires the parameters `prominence` and `distance` as these are used in the HoloLens visualization project. 

---

# Usage

`find_peaks` and `find_peak` can be imported from `peak_finding`. 

```python
from peak_finding import find_peaks, find_peak
```

The function can now be used to find the peaks in NumPy arrays. 

```python
x = np.array(...)
peaks, _ = find_peaks(x, prominence=0.15, distance=10)
peak_idx = find_peak(x, prominence=0.15, distance=10)
```