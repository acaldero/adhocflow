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


# A.1) Download TENSORFLOW source code
RUN mkdir -p /usr/src/daloflow && \
    cd /usr/src/daloflow && \
    wget https://github.com/tensorflow/tensorflow/archive/v2.3.0.tar.gz && \
    rm -fr tensorflow && \
    tar zxf v2.3.0.tar.gz && \
    mv tensorflow-2.3.0 tensorflow

# A.2) Compile TENSORFLOW source code
#RUN cd /usr/src/daloflow/tensorflow && \
#    yes "" | $(which python3) configure.py && \
#    bazel build --config=opt //tensorflow/tools/pip_package:build_pip_package --action_env PYTHON_BIN_PATH=/usr/bin/python3  && \
#    ./bazel-bin/tensorflow/tools/pip_package/build_pip_package /usr/src/daloflow/tensorflow/tensorflow_pkg
#    # pip3 install /usr/src/daloflow/tensorflow/tensorflow_pkg/tensorflow-*.whl

# A.3) Install TensorFlow, Keras, PyTorch and MXNet (from package)
RUN pip install future typing
RUN pip install tensorflow-cpu==${TENSORFLOW_VERSION} \
                keras \
                h5py
#RUN pip install torch==${PYTORCH_VERSION} torchvision==${TORCHVISION_VERSION}
#RUN pip install mxnet==${MXNET_VERSION}


# B.1) Download Open MPI
RUN mkdir -p /usr/src/daloflow && \
    cd /usr/src/daloflow && \
    wget https://www.open-mpi.org/software/ompi/v4.0/downloads/openmpi-4.0.5.tar.gz && \
    rm -fr openmpi && \
    tar zxf openmpi-4.0.5.tar.gz && \
    mv openmpi-4.0.5 openmpi

# B.2) Install Open MPI (from source code)
RUN cd /usr/src/daloflow/openmpi && \
    ./configure --enable-orterun-prefix-by-default && \
    make -j $(nproc) all && \
    make install && \
    ldconfig


# C.1) Download HOROVOD source code
RUN mkdir -p /usr/src/daloflow && \
    cd /usr/src/daloflow && \
    wget https://github.com/horovod/horovod/archive/v0.20.3.tar.gz && \
    rm -fr horovod && \
    tar zxf v0.20.3.tar.gz && \
    mv horovod-0.20.3 horovod

# C.2) Compile HOROVOD source code
#RUN cd /usr/src/daloflow/horovod && \
#    python3 setup.py clean && \
#    CFLAGS="-march=native -mavx -mavx2 -mfma -mfpmath=sse" python3 setup.py bdist_wheel
#  # HOROVOD_WITH_MPI=1 HOROVOD_WITH_TENSORFLOW=1 pip3 install ./dist/horovod-*.whl

# C.3) Install Horovod (from package)
RUN HOROVOD_WITH_TENSORFLOW=1 HOROVOD_WITHOUT_PYTORCH=1 HOROVOD_WITHOUT_MXNET=1 HOROVOD_WITH_MPI=1 \
    pip install --no-cache-dir horovod


# D.1) OpenSSH: Install for MPI to communicate between containers
RUN apt-get install -y --no-install-recommends openssh-client openssh-server
RUN mkdir -p /var/run/sshd

# D.2) OpenSSH: Allow Root login
RUN sed 's@session\s*required\s*pam_loginuid.so@session optional pam_loginuid.so@g' -i /etc/pam.d/sshd
RUN sed -i 's/PermitRootLogin prohibit-password/#PermitRootLogin prohibit-password/' /etc/ssh/sshd_config
RUN echo "PermitRootLogin yes" >> /etc/ssh/sshd_config
# OpenSSH: Allow to talk to containers without asking for confirmation
RUN cat /etc/ssh/ssh_config | grep -v StrictHostKeyChecking > /etc/ssh/ssh_config.new && \
    echo "    StrictHostKeyChecking no" >> /etc/ssh/ssh_config.new && \
    mv /etc/ssh/ssh_config.new /etc/ssh/ssh_config
# OpenSSH: keygen
RUN ssh-keygen -q -t rsa -N "" -f /root/.ssh/id_rsa
RUN cp /root/.ssh/id_rsa.pub /root/.ssh/authorized_keys


# Initial env
RUN echo 'root:daloflow' | chpasswd

RUN mkdir -p /daloflow
RUN ln -s /usr/src/daloflow /root/daloflow_src
RUN ln -s /daloflow         /root/daloflow
WORKDIR "/daloflow"

EXPOSE 22
CMD ["/usr/sbin/sshd", "-D"]

