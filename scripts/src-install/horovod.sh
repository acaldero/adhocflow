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

# 3) Download HOROVOD source code
cd /tmp
wget https://github.com/horovod/horovod/archive/v0.20.3.tar.gz
tar zxf v0.20.3.tar.gz
mv horovod-0.20.3 $(DESTINATION_PATH)

if [ ! -d $(DESTINATION_PATH) ]; then
	echo "Horovod download has failed :-("
	exit -1
fi

# 4) Compile HOROVOD source code
cd $(DESTINATION_PATH)
python3 setup.py clean
CFLAGS="-march=native -mavx -mavx2 -mfma -mfpmath=sse" python3 setup.py bdist_wheel

# 5) Install Horovod (from source)
cd $(DESTINATION_PATH)
HOROVOD_WITH_MPI=1 HOROVOD_WITH_TENSORFLOW=1 pip3 install ./dist/horovod-*.whl

