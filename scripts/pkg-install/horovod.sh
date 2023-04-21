#!/bin/bash
set -x

# 1) Install Horovod (from package)
HOROVOD_WITH_TENSORFLOW=1 HOROVOD_WITHOUT_PYTORCH=1 HOROVOD_WITHOUT_MXNET=1 HOROVOD_WITH_MPI=1 \
pip install --no-cache-dir horovod

