#!/bin/bash 
#(c)2017 Alces Software Ltd. HPC Consulting Build Suite
#Job ID: <JOB>
#Cluster: <CLUSTER>

source /root/.deployment

yum-config-manager --enable epel

yum -y install ganglia ganglia-web ganglia-gmetad ganglia-gmond
sed -i -e 's/^\s*Require.*$/  Require all granted/g' /etc/httpd/conf.d/ganglia.conf
service httpd restart

install_file gmetad /etc/ganglia/gmetad.conf
systemctl enable gmetad
systemctl restart gmetad

install_file gmond /etc/ganglia/gmond.conf
systemctl enable gmond
systemctl restart gmond
