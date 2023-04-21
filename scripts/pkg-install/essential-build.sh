#!/bin/bash
set -x

RUN apt-get update && apt-get install -y --allow-downgrades --allow-change-held-packages --no-install-recommends \
        build-essential \
        cmake \
        autoconf \
        libtool \
        git \
        g++-4.8 \
        openjdk-8-jdk \
        openjdk-8-jre-headless \
        \
        vim \
        libmxml1 \
        swig \
        libmxml-dev \
        libjpeg-dev \
        libpng-dev \
        zlib1g-dev \
        && \
    apt-get clean 

