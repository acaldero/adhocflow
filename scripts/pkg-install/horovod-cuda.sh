#!/bin/bash
set -x

# 1) Install Horovod, temporarily using CUDA stubs (from package)
ldconfig /usr/local/cuda/targets/x86_64-linux/lib/stubs && \
HOROVOD_WITH_TENSORFLOW=1 HOROVOD_WITHOUT_PYTORCH=1 HOROVOD_WITHOUT_MXNET=1 HOROVOD_WITH_MPI=1 HOROVOD_GPU_OPERATIONS=NCCL \
pip install --no-cache-dir horovod && \
ldconfig

# 2) Download examples
svn checkout https://github.com/horovod/horovod/trunk/examples && \
rm -rf /examples/.svn

