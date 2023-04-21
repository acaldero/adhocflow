FROM ubuntu:18.04

ENV PYTHON_VERSION=3.7
ENV TENSORFLOW_VERSION=2.3.0
ENV PYTORCH_VERSION=1.6.0
ENV TORCHVISION_VERSION=0.7.0
ENV MXNET_VERSION=1.6.0

# Set default shell to /bin/bash
SHELL ["/bin/bash", "-cu"]

# Install essential software
COPY scripts/pkg-install/*.sh /tmp
RUN  chmod a+x /tmp/*.sh
RUN  /tmp/essential-util.sh
RUN  /tmp/essential-net.sh
RUN  /tmp/essential-build.sh

# Install Python
RUN apt-get update && apt-get install -y --allow-downgrades --allow-change-held-packages --no-install-recommends \
        python${PYTHON_VERSION} \
        python${PYTHON_VERSION}-dev \
        python${PYTHON_VERSION}-distutils \
        virtualenv \
        && \
    apt-get clean 
RUN ln -s /usr/bin/python${PYTHON_VERSION} /usr/bin/python
RUN curl -O https://bootstrap.pypa.io/get-pip.py && \
    python get-pip.py && \
    rm get-pip.py

# Install OpenMPI and XPN (from source)
COPY scripts/src-install/*.sh /tmp
RUN  chmod a+x /tmp/*.sh
RUN  /tmp/openmpi.sh  /usr/src/daloflow/openmpi
RUN  /tmp/xpn.sh      /usr/src/daloflow/xpn

# Install Tensorflow, Horovod and SSH (from package)
COPY scripts/pkg-install/*.sh /tmp
RUN  chmod a+x /tmp/*.sh
RUN  /tmp/tensorflow.sh  ${TENSORFLOW_VERSION}
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

