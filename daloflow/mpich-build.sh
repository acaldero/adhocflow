#!/bin/bash
set -x

cd /usr/src/daloflow/mpich

./configure --enable-orterun-prefix-by-default --disable-fortran
make -j $(nproc) all
make install
ldconfig 

cd /usr/src/daloflow/mpich/examples
make -j $(nproc) all

