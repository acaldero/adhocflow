#!/bin/bash
set -x

cd /usr/src/daloflow/tensorflow

yes "" | $(which python3) configure.py
bazel build --config=opt //tensorflow/tools/pip_package:build_pip_package --action_env PYTHON_BIN_PATH=/usr/bin/python3 
./bazel-bin/tensorflow/tools/pip_package/build_pip_package /usr/src/daloflow/tensorflow/tensorflow_pkg
pip3 install /usr/src/daloflow/tensorflow/tensorflow_pkg/tensorflow-*.whl

