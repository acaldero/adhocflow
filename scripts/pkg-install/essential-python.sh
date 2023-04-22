#!/bin/bash
set -x

# 1) Arguments
if [ $# -eq 1 ]; then
     PYTHON_VERSION=$1
else
     PYTHON_VERSION=3.7
fi

# 2) Install Python
apt-get update && \
apt-get install -y --allow-downgrades --allow-change-held-packages --no-install-recommends \
        python${PYTHON_VERSION} \
        python${PYTHON_VERSION}-dev \
        python${PYTHON_VERSION}-distutils \
        python3-pip \
        python3-setuptools \
        virtualenv \
        && \
apt-get clean 

ln -s /usr/bin/python${PYTHON_VERSION} /usr/bin/python

curl -O https://bootstrap.pypa.io/get-pip.py && \
python get-pip.py && \
rm get-pip.py

