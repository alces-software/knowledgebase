#!/bin/bash 
#(c)2017 Alces Software Ltd. HPC Consulting Build Suite
#Job ID: <JOB>
#Cluster: <CLUSTER>

source /root/.deployment

#Use /users for new users
sed -i -e 's|^HOME=.*$|HOME=/users|g' /etc/default/useradd

yum -y install nfs-utils
cat << EOF > /etc/exports
/users     ${_ALCES_PRVNETWORK}/${_ALCES_PRVNETMASK}(rw,no_root_squash,sync)
/data	   ${_ALCES_PRVNETWORK}/${_ALCES_PRVNETMASK}(rw,no_root_squash,sync)
EOF
mkdir -p /data
mkdir -p /users

#Increase nfsd thread count
sed -ie "s/^#\RPCNFSDCOUNT.*$/\RPCNFSDCOUNT=32/g" /etc/sysconfig/nfs

systemctl enable nfs
systemctl start nfs
