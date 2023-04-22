#!/bin/bash
set -x

apt-get update && \
apt-get install -y --allow-downgrades --allow-change-held-packages --no-install-recommends \
        build-essential \
        cmake \
        g++ \
        g++-4.8 \
        \
        autoconf \
        libtool \
	automake \
        \
        git \
        subversion \
        \
        openjdk-8-jdk \
        openjdk-8-jre-headless \
        \
        swig \
        libmxml1 \
        libmxml-dev \
        \
        libjpeg-dev \
        libpng-dev \
        zlib1g-dev \
        libcurl3-dev \
        libfreetype6-dev \
        libhdf5-serial-dev \
        libzmq3-dev \
        && \
    apt-get clean 

# Not in GPU listing: g++-4.8
# Not in CPU listing: g++

