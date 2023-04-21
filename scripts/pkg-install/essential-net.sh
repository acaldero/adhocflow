#!/bin/bash
set -x

RUN apt-get update && apt-get install -y --allow-downgrades --allow-change-held-packages --no-install-recommends \
        \
        librdmacm1 \
        libibverbs1 \
        \
        ibverbs-providers \
        net-tools \
        iputils-ping \
        nload \
        && \
    apt-get clean 

