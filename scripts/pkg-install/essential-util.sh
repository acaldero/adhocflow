#!/bin/bash
set -x

RUN apt-get update && apt-get install -y --allow-downgrades --allow-change-held-packages --no-install-recommends \
        \
        ca-certificates \
        aptitude \
        pkg-config \
        rsync \
        apt-utils \
        software-properties-common \
        sudo \
        gpg-agent \
        curl \
        wget \
        \
        unzip \
        zip \
        htop \
        vim \
        && \
    apt-get clean 

