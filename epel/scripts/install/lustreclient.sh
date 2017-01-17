#!/bin/bash
#(c)2017 Alces Software Ltd. HPC Consulting Build Suite
#Job ID: <JOB>
#Cluster: <CLUSTER>
yum -y install lustre-client lustre-client-modules kernel kernel-devel
cat << EOF > /etc/modprobe.d/lustre.conf
options lnet networks=o2ib0(ib0)
EOF
cat << EOF >> /etc/fstab
#Lustre
mds1@o2ib0:mds2@o2ib0:/nobackup       /nobackup    lustre  defaults,_netdev 0 0
EOF
mkdir -p /nobackup
chkconfig lnet on
