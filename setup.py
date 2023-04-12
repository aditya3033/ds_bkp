import os
from setuptools import setup, find_packages

with open("README.md",  "r") as fh:
    long_description = fh.read()

def read(rel_path: str) -> str:
    here = os.path.abspath(os.path.dirname(__file__))
    with open(os.path.join(here, rel_path)) as fp:
        return fp.read()

def get_version(rel_path: str) -> str:
    for line in read(rel_path).splitlines():
        if line.startswith("__version__"):
            delim = '"' if '"' in line else "'"
            return line.split(delim)[1]
    raise RuntimeError("Unable to find version string.")


setup(
    name = 'DirectSupply',
    version = get_version("_version.py"),
    description = 'DirectSupply Pyspark Project',
    url = '<git_lab_url>',
    author = 'prakash.reddy@directsupply.com',
    keywords = '',
    packages = find_packages(),
    setup_requires = ["pytest-runner"],
    tests_require = ["pytest"],
    entry_points = {
        'console_scripts': ['main_task = dependencies.job_submitter:main']
    },
    classifiers = [
        "Programming Language :: Python :: 3",
        "License ::: OSI Not Approved :: Direct Supply",
        "Operating System :: OS Independent",
    ],
)
