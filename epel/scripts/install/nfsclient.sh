#!/bin/bash 
#(c)2017 Alces Software Ltd. HPC Consulting Build Suite
#Job ID: <JOB>
#Cluster: <CLUSTER>

yum -y install nfs-utils
cat << EOF >> /etc/fstab
#NFS
head1:/users	/users  nfs     intr,rsize=32768,wsize=32768,_netdev 0 0
head1:/opt/sge  /opt/sge nfs	intr,rsize=32768,wsize=32768,_netdev 0 0
head2:/data	/data	nfs	intr,rsize=32768,wsize=32768,_netdev 0 0
EOF
mkdir -p /data
mkdir -p /users
mkdir -p /opt/sge
