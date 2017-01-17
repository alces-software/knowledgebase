#!/bin/bash
#(c)2017 Alces Software Ltd. HPC Consulting Build Suite
#Job ID: <JOB>
#Cluster: <CLUSTER>

yum -y install ypbind
NISDOMAIN='<CLUSTER>'
NISMASTER='10.10.200.128'
echo "domain $NISDOMAIN server $NISMASTER" >> /etc/yp.conf
echo "domain $NISDOMAIN server 10.10.200.130" >> /etc/yp.conf
nisdomainname $NISDOMAIN
echo "NISDOMAIN=$NISDOMAIN" >> /etc/sysconfig/network
sed -i -e 's/^passwd:.*/passwd:     files nis/g' \
-e 's/^shadow:.*/shadow:     files nis/g' \
-e 's/^group.*/group:      files nis/g' /etc/nsswitch.conf
systemctl enable ypbind
systemctl start ypbind

