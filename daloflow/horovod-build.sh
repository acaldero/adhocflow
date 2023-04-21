#!/bin/bash
set -x

cd /usr/src/daloflow/horovod

python3 setup.py clean
CFLAGS="-march=native -mavx -mavx2 -mfma -mfpmath=sse" python3 setup.py bdist_wheel
pip3 install ./dist/horovod-*.whl

