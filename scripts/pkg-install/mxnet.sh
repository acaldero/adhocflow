#!/bin/bash
set -x

# 1) Arguments
if [ $# -eq 1 ]; then
     MXNET_VERSION=$1
else
     MXNET_VERSION=1.6.0
fi

# 3) Install MXNet (from package)
pip install mxnet==${MXNET_VERSION}

