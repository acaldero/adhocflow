#!/bin/bash
set -x

# 1) Arguments
if [ $# -eq 1 ]; then
     TENSORFLOW_VERSION=$1
else
     TENSORFLOW_VERSION=2.3.0
fi

# 2) Install TensorFlow and Keras (from package)
pip install future typing packaging
pip install tensorflow-cpu==${TENSORFLOW_VERSION} \
            keras \
            h5py \
            setuptools \
            Pillow \
            wheel \
            typing \
            keras_preprocessing \
            matplotlib \
            mock \
            numpy \
            scipy \
            pandas \
            mock \
            enum34 \
            scikit-learn \
            future \
            portpicker

