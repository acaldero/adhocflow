#!/bin/bash
set -x

apt-get update && \
apt-get install -y --allow-downgrades --allow-change-held-packages --no-install-recommends \
        \
	openmpi-bin \
        openmpi-common \
        openmpi-doc \
        \
        libpmi-pmix-dev  \
        libpmi1-pmix  \
        libpmi2-pmix  \
        libhdf5-openmpi-dev  \
        \
        netpipe-openmpi \
        \
        && \
    apt-get clean 

