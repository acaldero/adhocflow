FROM ubuntu:18.04

ENV TENSORFLOW_VERSION=2.3.0
ENV PYTORCH_VERSION=1.6.0
ENV TORCHVISION_VERSION=0.7.0
ENV MXNET_VERSION=1.6.0

# Python 3.7 is supported by Ubuntu Bionic out of the box
ARG python=3.7
ENV PYTHON_VERSION=${python}

# Set default shell to /bin/bash
SHELL ["/bin/bash", "-cu"]

RUN apt-get update && apt-get install -y --allow-downgrades --allow-change-held-packages --no-install-recommends \
        build-essential \
        cmake \
        g++-4.8 \
        git \
        curl \
        vim \
        wget \
        ca-certificates \
        libjpeg-dev \
        libpng-dev \
        python${PYTHON_VERSION} \
        python${PYTHON_VERSION}-dev \
        python${PYTHON_VERSION}-distutils \
        librdmacm1 \
        libibverbs1 \
        ibverbs-providers \
        \
        aptitude \
        pkg-config \
        rsync \
        apt-utils \
        software-properties-common \
        sudo \
        gpg-agent \
        unzip \
        zip \
        zlib1g-dev \
        virtualenv \
        autoconf \
        libtool \
        swig \
        openjdk-8-jdk \
        openjdk-8-jre-headless \
        iputils-ping \
        net-tools \
        && \
    apt-get clean 

RUN ln -s /usr/bin/python${PYTHON_VERSION} /usr/bin/python

RUN curl -O https://bootstrap.pypa.io/get-pip.py && \
    python get-pip.py && \
    rm get-pip.py

# Install AdHocFlow related software:
#  a) from source (OpenMPI)
COPY scripts/src-install/*.sh /tmp
RUN  chmod a+x /tmp/*.sh
RUN  /tmp/openmpi.sh  /usr/src/daloflow/openmpi
#  b) from package (Tensorflow, Horovod, SSH)
COPY scripts/pkg-install/*.sh /tmp
RUN  chmod a+x /tmp/*.sh
RUN  /tmp/tensorflow.sh
RUN  /tmp/horovod.sh
RUN  /tmp/ssh.sh

# Initial env
RUN echo 'root:daloflow' | chpasswd

RUN mkdir -p /daloflow
RUN ln -s /usr/src/daloflow /root/daloflow_src
RUN ln -s /daloflow         /root/daloflow
WORKDIR "/daloflow"

EXPOSE 22
CMD ["/usr/sbin/sshd", "-D"]

