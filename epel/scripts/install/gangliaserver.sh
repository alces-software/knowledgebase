#!/bin/bash 
#(c)2017 Alces Software Ltd. HPC Consulting Build Suite
#Job ID: <JOB>
#Cluster: <CLUSTER>

if [ -f /root/.alcesconf ]; then
  . /root/.alcesconf
fi

FILES_URL=http://${_ALCES_BUILDSERVER}/epel/files/${_ALCES_CLUSTER}/

yum -y install ganglia ganglia-web ganglia-gmetad ganglia-gmond
sed -ie 's/^\s*Require.*$/  Require all granted/g' /etc/httpd/conf.d/ganglia.conf
service httpd restart

curl $FILES_URL/gmetad | envsubst > /etc/ganglia/gmetad.conf
systemctl enable gmetad
systemctl start gmetad
