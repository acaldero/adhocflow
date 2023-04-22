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
PYTAGS=$(python -c "from packaging import tags; tag = list(tags.sys_tags())[0]; print(f'{tag.interpreter}-{tag.abi}')") && \
pip install https://download.pytorch.org/whl/cu101/torch-${PYTORCH_VERSION}%2Bcu101-${PYTAGS}-linux_x86_64.whl \
            https://download.pytorch.org/whl/cu101/torchvision-${TORCHVISION_VERSION}%2Bcu101-${PYTAGS}-linux_x86_64.whl

