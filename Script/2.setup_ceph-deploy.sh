#!/bin/bash

# Install ceph-deploy
sudo yum install -y ceph-deploy

# Switch to cephuser
su - cephuser

# Generate SSH key
ssh-keygen -t rsa

# Copy SSH key to nodes
function copy_ssh_key {
    ssh-copy-id cephuser@$1
}

copy_ssh_key ceph1
copy_ssh_key ceph2
copy_ssh_key ceph3

# Create cluster directory
cd ~
mkdir my-cluster
cd my-cluster

# Initialize ceph-deploy
ceph-deploy new ceph1 ceph2 ceph3
echo "public network = 192.168.65.0/24" >> ceph.conf
echo "osd objectstore = bluestore"  >> ceph.conf
echo "mon_allow_pool_delete = true"  >> ceph.conf
echo "osd pool default size = 3"  >> ceph.conf
echo "osd pool default min size = 1"  >> ceph.conf

# Install Ceph on nodes
ceph-deploy install --release nautilus ceph1 ceph2 ceph3

# Create initial monitors
ceph-deploy mon create-initial

# Deploy admin key
ceph-deploy admin ceph1 ceph2 ceph3
ssh cephuser@ceph1 'sudo chmod +r /etc/ceph/ceph.client.admin.keyring'
ssh cephuser@ceph2 'sudo chmod +r /etc/ceph/ceph.client.admin.keyring'
ssh cephuser@ceph3 'sudo chmod +r /etc/ceph/ceph.client.admin.keyring'

# Create OSDs
ceph-deploy osd create --data /dev/sdb ceph1
ceph-deploy osd create --data /dev/sdb ceph2
ceph-deploy osd create --data /dev/sdb ceph3

# Install required packages
sudo yum install -y python-jwt python-routes
sudo yum install ceph-mgr-dashboard -y

# Configure MGR and Dashboard
ceph-deploy mgr create ceph1 ceph2 ceph3
ceph mgr module enable dashboard --force
sudo ceph dashboard create-self-signed-cert 

# Create dashboard user
cat <<EOF> /home/cephuser/my-cluster/The101200.txt
The101200
EOF
ceph dashboard ac-user-create cephadmin -i /home/cephuser/my-cluster/The101200.txt administrator

echo "Ceph setup completed."
