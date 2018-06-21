import os
import torch
from setuptools import setup, find_packages
from torch.utils.ffi import create_extension

from cpp_extension import BuildExtension

extra_compile_args = {
    "cxx": ["-std=c++11", "-O2", "-fopenmp"],
    "nvcc": ["-std=c++11", "-O2"],
}

CC = os.getenv('CC', None)
if CC is not None:
    extra_compile_args["nvcc"].append("-ccbin=" + CC)

include_dirs = ["../"]

headers = [
    "src/cpu/adaptive_avgpool_2d.h",
    "src/cpu/adaptive_maxpool_2d.h",
    "src/cpu/mask_image_from_size.h",
]

sources = [
    "src/cpu/adaptive_avgpool_2d.cc",
    "src/cpu/adaptive_maxpool_2d.cc",
    "src/cpu/mask_image_from_size.cc",
]

if torch.cuda.is_available():
    headers += [
        "src/gpu/adaptive_avgpool_2d.h",
        "src/gpu/adaptive_maxpool_2d.h",
        "src/gpu/mask_image_from_size.h",
    ]

    sources += [
        "src/gpu/adaptive_avgpool_2d.cu",
        "src/gpu/adaptive_maxpool_2d.cu",
        "src/gpu/mask_image_from_size.cu",
    ]

ffi = create_extension(
    name="nnutils_pytorch._nnutils",
    package=True,
    language="c++",
    headers=headers,
    sources=sources,
    with_cuda=torch.cuda.is_available(),
    include_dirs=include_dirs,
    extra_compile_args=extra_compile_args,
)
ffi = ffi.distutils_extension()

setup(
    name="nnutils_pytorch",
    version="0.2",
    description="PyTorch bindings of the nnutils library",
    url="https://github.com/jpuigcerver/nnutils",
    author="Joan Puigcerver",
    author_email="joapuipe@gmail.com",
    license="MIT",
    packages=find_packages(),
    ext_modules=[ffi],
    cmdclass={"build_ext": BuildExtension},
    classifiers=[
        "Development Status :: 3 - Alpha",
        "Intended Audience :: Developers",
        "Intended Audience :: Education",
        "Intended Audience :: Science/Research",
        "License :: OSI Approved :: MIT License",
        "Programming Language :: Python :: 2",
        "Programming Language :: Python :: 2.7",
        "Programming Language :: Python :: 3",
        "Programming Language :: Python :: 3.5",
        "Programming Language :: Python :: 3.6",
        "Topic :: Scientific/Engineering",
        "Topic :: Scientific/Engineering :: Artificial Intelligence",
        "Topic :: Scientific/Engineering :: Image Recognition",
        "Topic :: Software Development",
        "Topic :: Software Development :: Libraries",
        "Topic :: Software Development :: Libraries :: Python Modules",
    ],
    setup_requires=[
        'torch>=0.3',
    ],
    install_requires=[
        'torch>=0.3',
    ],
)