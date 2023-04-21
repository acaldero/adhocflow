#!/bin/bash
set -x

# NVIDIA GPU: https://nvidia.github.io/nvidia-container-runtime/
curl -s -L https://nvidia.github.io/nvidia-container-runtime/gpgkey | sudo apt-key add -
distribution=$(. /etc/os-release;echo $ID$VERSION_ID)
curl -s -L https://nvidia.github.io/nvidia-container-runtime/$distribution/nvidia-container-runtime.list | \
	  sudo tee /etc/apt/sources.list.d/nvidia-container-runtime.list
sudo apt-get update
apt-get install -y nvidia-container-runtime
#docker run -it --rm --gpus all ubuntu nvidia-smi

