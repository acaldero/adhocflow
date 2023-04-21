#!/bin/bash
set -x

# 1) Check arguments
if [ $# -lt 1 ]; then
	echo "Usage: $0 <full path where software will be installed>"
	exit
fi

 XPN_PATH=$1
MXML_PATH=$(basedir ${XPN_PATH})
MPICC_PATH=$(whereis -b mpicc | awk '{ print $2 }')

# 2) MXML
mkdir -p ${MXML_PATH}
mv    -f ${MXML_PATH} ${XPN_PATH}_$$

cd /tmp
git clone https://github.com/michaelrsweet/mxml.git
mv mxml $(MXML_PATH)

if [ ! -d $(MXML_PATH) ]; then
	echo "MXML download has failed :-("
	exit -1
fi

cd $(MXML_PATH)
./configure; make clean; make -j 
# ./configure --prefix=$INSTALL_PATH/mxml
# make clean; make -j; make install


# XPN
mkdir -p ${XPN_PATH}
mv    -f ${XPN_PATH}  ${XPN_PATH}_$$

cd /tmp
git clone https://github.com/xpn-arcos/xpn.git
mv xpn $(XPN_PATH)

if [ ! -d $(XPN_PATH) ]; then
	echo "XPN download has failed :-("
	exit -1
fi

cd $(XPN_PATH) 
ACLOCAL_FLAGS="-I /usr/share/aclocal/" autoreconf -v -i -s -W all
./configure --enable-tcp_server --enable-mpi_server="$MPICC_PATH"
make clean 
make -j

# ACLOCAL_FLAGS="-I /usr/share/aclocal/" autoreconf -v -i -s -W all
# ./configure --prefix=$INSTALL_PATH/xpn --enable-tcp_server --enable-mpi_server="$MPICC_PATH"
# make clean; make -j; make install

