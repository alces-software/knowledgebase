#!/bin/bash
#(c)2017 Alces Software Ltd. HPC Consulting Build Suite
#Job ID: <JOB>
#Cluster: <CLUSTER>

source /root/.deployment

yum -y install ypbind
NISDOMAIN="${_ALCES_CLUSTER}"
NISMASTER="${_ALCES_BUILDSERVER}"
echo "domain $NISDOMAIN server $NISMASTER" > /etc/yp.conf
nisdomainname $NISDOMAIN
echo "NISDOMAIN=$NISDOMAIN" >> /etc/sysconfig/network
sed -i -e 's/^passwd:.*/passwd:     files nis/g' \
-e 's/^shadow:.*/shadow:     files nis/g' \
-e 's/^group.*/group:      files nis/g' /etc/nsswitch.conf
systemctl enable ypbind
systemctl start ypbind
