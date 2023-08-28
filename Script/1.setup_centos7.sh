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
sudo rpm -Uvh https://download.ceph.com/rpm-nautilus/el7/noarch/ceph-release-1-0.el7.noarch.rpm

yum update -y

# Install additional packages
yum install byobu curl git python-setuptools python-virtualenv -y

echo "Setup completed."

