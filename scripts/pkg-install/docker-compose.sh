#!/bin/bash
set -x

sudo apt-get update
sudo apt-get upgrade
sudo apt-get install -y pip3

pip3 install docker-compose

