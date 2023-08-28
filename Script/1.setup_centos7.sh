#!/bin/bash

# Update system
yum update -y

# Install epel-release repository
yum install epel-release -y

# Install required packages
yum install net-tools wget vim -y

# Stop and disable firewalld
systemctl stop firewalld
systemctl disable firewalld

# Disable SELinux
sed -i 's/^SELINUX=.*/SELINUX=disabled/g' /etc/sysconfig/selinux

# Create an alias for vi to vim
echo "alias vi=vim" >> ~/.bashrc

# Set hostname
hostnamectl set-hostname ceph1

# Install and configure chrony
yum install -y chrony
systemctl enable chronyd.service
systemctl start chronyd.service
systemctl restart chronyd.service
chronyc sources

# Add a new user
useradd cephuser
echo '1' | passwd cephuser --stdin

# Add the new user to the sudoers file
echo "cephuser ALL = (root) NOPASSWD:ALL" | sudo tee /etc/sudoers.d/cephuser
chmod 0440 /etc/sudoers.d/cephuser

# Install Ceph and EPEL repository
cat <<EOF> /etc/yum.repos.d/ceph.repo
[ceph]
name=Ceph packages for \$basearch
baseurl=https://download.ceph.com/rpm-nautilus/el7/x86_64/
enabled=1
priority=2
gpgcheck=1
gpgkey=https://download.ceph.com/keys/release.asc

[ceph-noarch]
name=Ceph noarch packages
baseurl=https://download.ceph.com/rpm-nautilus/el7/noarch
enabled=1
priority=2
gpgcheck=1
gpgkey=https://download.ceph.com/keys/release.asc

[ceph-source]
name=Ceph source packages
baseurl=https://download.ceph.com/rpm-nautilus/el7/SRPMS
enabled=0
priority=2
gpgcheck=1
gpgkey=https://download.ceph.com/keys/release.asc
EOF

yum update -y

# Install additional packages
yum install byobu curl git python-setuptools python-virtualenv -y

echo "Setup completed."

