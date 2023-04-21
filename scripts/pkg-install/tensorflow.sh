#!/bin/bash
set -x

# 1) Arguments
if [ $# -eq 1 ]; then
     TENSORFLOW_VERSION=$1
else
     TENSORFLOW_VERSION=2.3.0
fi

# 2) Install TensorFlow and Keras (from package)
pip install future typing
pip install tensorflow-cpu==${TENSORFLOW_VERSION} keras h5py

