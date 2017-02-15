#!/bin/bash
#(c)2017 Alces Software Ltd. HPC Consulting Build Suite
#Job ID: <JOB>
#Cluster: <CLUSTER>

. /root/.deployment

yum -y install httpd

install_file httpddeployment /etc/httpd/conf.d/deployment.conf

service httpd start
systemctl enable httpd

