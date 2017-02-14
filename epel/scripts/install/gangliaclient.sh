#!/bin/bash 
#(c)2017 Alces Software Ltd. HPC Consulting Build Suite
#Job ID: <JOB>
#Cluster: <CLUSTER>

source /root/.deployment

yum-config-manager --enable epel

yum -y install ganglia-gmond
install_file gmond /etc/ganglia/gmond.conf
systemctl enable gmond
systemctl restart gmond
