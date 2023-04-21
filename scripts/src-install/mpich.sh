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

# 3) Download MPICH
cd /tmp
wget https://www.mpich.org/static/downloads/4.1.1/mpich-4.1.1.tar.gz
tar zxf mpich-4.1.1.tar.gz
mv mpich-4.1.1 $(DESTINATION_PATH)

if [ ! -d $(DESTINATION_PATH) ]; then
	echo "MPICH download has failed :-("
	exit -1
fi

# 4) Install MPICH (from source code)
cd $(DESTINATION_PATH) && \
./configure --enable-orterun-prefix-by-default --disable-fortran && \
make -j $(nproc) all && \
make install && \
ldconfig

cd examples && \
make -j $(nproc) all

