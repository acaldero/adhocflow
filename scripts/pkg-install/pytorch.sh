#!/bin/bash
set -x

# 1) Arguments
if [ $# -eq 2 ]; then
     PYTORCH_VERSION=$1
     TORCHVISION_VERSION=$2
else
     PYTORCH_VERSION=1.6.0
     TORCHVISION_VERSION=0.7.0
fi

# 3) Install PyTorch (from package)
pip install torch==${PYTORCH_VERSION} torchvision==${TORCHVISION_VERSION}

