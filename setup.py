import sys
import numpy as np

from setuptools import Extension, setup, find_packages
from Cython.Build import cythonize


def main():
    annotate = False
    if "--annotate" in sys.argv:
        annotate = True
        sys.argv.remove("--annotate")

    extensions = [
        Extension("peak_finding.interface", ["src/peak_finding/interface.pyx"],
                  include_dirs=[np.get_include()]),
        Extension("peak_finding._peak_finding", ["src/peak_finding/_peak_finding.pyx"]),
        Extension("peak_finding._peak_finding_utils", ["src/peak_finding/_peak_finding_utils.pyx"])
    ]
    setup(
        name="hololens_visualization",
        ext_modules=cythonize(extensions, annotate=annotate),
        package_dir={'': 'src'},
        packages=find_packages(where="src")
    )

if __name__ == "__main__":
    main()