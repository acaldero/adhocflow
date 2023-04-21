#!/bin/bash
set -x

# 1) Check arguments
if [ $# -lt 1 ]; then
	echo "Usage: $0 <full path where software will be installed>"
	exit
fi

# 2) Clean-up
DESTINATION_PATH=$1
mkdir -p $(DESTINATION_PATH)
mv    -f $(DESTINATION_PATH) $(DESTINATION_PATH)_$$

# 3) Download TENSORFLOW source code
cd /tmp
wget https://github.com/tensorflow/tensorflow/archive/v2.3.0.tar.gz
tar zxf v2.3.0.tar.gz
mv tensorflow-2.3.0 $(DESTINATION_PATH)

if [ ! -d $(DESTINATION_PATH) ]; then
	echo "Tensorflow Download has failed :-("
	exit -1
fi

# 4) Compile TENSORFLOW source code
cd $(DESTINATION_PATH)
yes "" | $(which python3) configure.py
bazel build --config=opt //tensorflow/tools/pip_package:build_pip_package --action_env PYTHON_BIN_PATH=/usr/bin/python3
./bazel-bin/tensorflow/tools/pip_package/build_pip_package $(DESTINATION_PATH)/tensorflow_pkg
pip3 install $(DESTINATION_PATH)/tensorflow_pkg/tensorflow-*.whl

