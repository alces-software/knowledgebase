#!/bin/bash 
#(c)2017 Alces Software Ltd. HPC Consulting Build Suite
#Job ID: <JOB>
#Cluster: <CLUSTER>

source /root/.deployment

yum install -y ypserv yp-tools

#Use /users for new users
sed -i -e 's|^HOME=.*$|HOME=/users|g' /etc/default/useradd

NISDOMAIN="${_ALCES_CLUSTER}"
echo "domain $NISDOMAIN server 127.0.0.1" > /etc/yp.conf
nisdomainname $NISDOMAIN
echo "NISDOMAIN=$NISDOMAIN" >> /etc/sysconfig/network
PRVNETMASK="${_ALCES_PRVNETMASK}"
PRVNETWORK="${_ALCES_PRVNETWORK}"
cat << EOF > /var/yp/securenets
host 127.0.0.1
$PRVNETMASK $PRVNETWORK
EOF
#Enable shadow passwords
sed -e 's/^all.*$/all:  passwd group hosts rpc services netid protocols mail shadow \\/g' -e 's/^MERGE_PASSWD.*$/MERGE_PASSWD=false/g' -i /var/yp/Makefile
echo -e "shadow\t\tshadow.byname" >> /var/yp/nicknames
systemctl enable ypserv
systemctl enable yppasswdd
systemctl restart ypserv
systemctl restart yppasswdd

make -C /var/yp
