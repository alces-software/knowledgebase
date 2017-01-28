#!/bin/bash 
#(c)2017 Alces Software Ltd. HPC Consulting Build Suite
#Job ID: <JOB>
#Cluster: <CLUSTER>

if [ -f /root/.alcesconf ]; then
  . /root/.alcesconf
fi

FILES_URL=http://${_ALCES_BUILDSERVER}/epel/files/${_ALCES_CLUSTER}/

yum-config-manager --enable epel

yum -y install ganglia-gmond

curl $FILES_URL/gmond | envsubst "$_ALCES_KEYS" > /etc/ganglia/gmond.conf
systemctl enable gmond
systemctl restart gmond
