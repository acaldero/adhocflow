#!/bin/bash
set -x

apt-get update && \
apt-get install -y --allow-downgrades --allow-change-held-packages --no-install-recommends \
        \
        librdmacm1 \
        libibverbs1 \
        \
        ibverbs-providers \
        net-tools \
        iputils-ping \
        \
        nmap \
        nload \
        netcat \
        && \
    apt-get clean 

# Not in GPU listing: librdmacm1 nload

