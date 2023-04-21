#!/bin/bash
set -x

sudo apt-get update
sudo apt-get upgrade
sudo apt-get install -y curl apt-transport-https ca-certificates software-properties-common

curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
curl https://bazel.build/bazel-release.pub.gpg | sudo apt-key add -
sudo apt-get update
sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
sudo apt-get update
sudo apt install -y docker-ce docker-ce-cli containerd.io

