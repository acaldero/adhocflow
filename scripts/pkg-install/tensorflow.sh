#!/bin/bash
set -x

# Install TensorFlow, Keras, PyTorch and MXNet (from package)
pip install future typing
pip install tensorflow-cpu==${TENSORFLOW_VERSION} \
            keras \
            h5py

#pip install torch==${PYTORCH_VERSION} torchvision==${TORCHVISION_VERSION}
#pip install mxnet==${MXNET_VERSION}

