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

# 3) Download Open MPI
cd /tmp
wget https://www.open-mpi.org/software/ompi/v4.0/downloads/openmpi-4.0.5.tar.gz
tar zxf openmpi-4.0.5.tar.gz
mv openmpi-4.0.5 $(DESTINATION_PATH)

if [ ! -d $(DESTINATION_PATH) ]; then
	echo "OpenMPI download has failed :-("
	exit -1
fi

# 4) Install Open MPI (from source code)
cd $(DESTINATION_PATH) && \
./configure --enable-orterun-prefix-by-default && \
make -j $(nproc) all && \
make install && \
ldconfig

