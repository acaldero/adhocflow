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

# 3) Download MXML
cd /tmp
git clone https://github.com/michaelrsweet/mxml.git
mv mxml $(DESTINATION_PATH)

if [ ! -d $(DESTINATION_PATH) ]; then
	echo "MXML download has failed :-("
	exit -1
fi

# 4) Install MXML (from source code)
cd $(DESTINATION_PATH)
./configure; make clean; make -j 
# ./configure --prefix=$INSTALL_PATH/mxml
# make clean; make -j; make install

