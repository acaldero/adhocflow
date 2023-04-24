#!/bin/bash
set -x

# 1) Check arguments
if [ $# -lt 1 ]; then
	echo "Usage: $0 <full path where software will be installed>"
	exit
fi

# 2) Clean-up
DESTINATION_PATH=$1
mkdir -p ${DESTINATION_PATH}
mv    -f ${DESTINATION_PATH} ${DESTINATION_PATH}_$$

# 3) Download XPN
cd /tmp
git clone https://github.com/xpn-arcos/xpn.git
mv xpn ${DESTINATION_PATH}

if [ ! -d ${DESTINATION_PATH} ]; then
	echo "XPN download has failed :-("
	exit -1
fi

# 4) Install XPN (from source code)
MPICC_PATH=$(whereis -b mpicc | awk '{ print $2 }')
mkdir -p $HOME/bin/xpn

cd ${DESTINATION_PATH} 
ACLOCAL_FLAGS="-I /usr/share/aclocal/" autoreconf -v -i -s -W all
./configure --enable-tcp_server --enable-mpi_server="$MPICC_PATH" --prefix=${HOME}/bin/xpn
make clean 
make -j
make install

