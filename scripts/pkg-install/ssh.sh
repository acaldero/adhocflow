#!/bin/bash
set -x


# 1) Install OpenSSH
apt-get install -y --no-install-recommends openssh-client openssh-server
mkdir -p /var/run/sshd

# 2) Allow Root login
sed -i 's@session\s*required\s*pam_loginuid.so@session optional pam_loginuid.so@g'  /etc/pam.d/sshd
sed -i 's/PermitRootLogin prohibit-password/#PermitRootLogin prohibit-password/'    /etc/ssh/sshd_config
echo   "PermitRootLogin yes"  >> /etc/ssh/sshd_config

# 3) Allow connections without asking for confirmation
cat /etc/ssh/ssh_config | grep -v StrictHostKeyChecking > /etc/ssh/ssh_config.new 
echo "    StrictHostKeyChecking no" >> /etc/ssh/ssh_config.new 
mv /etc/ssh/ssh_config.new /etc/ssh/ssh_config

# 4) keygen
ssh-keygen -q -t rsa -N "" -f /root/.ssh/id_rsa
cp /root/.ssh/id_rsa.pub /root/.ssh/authorized_keys

