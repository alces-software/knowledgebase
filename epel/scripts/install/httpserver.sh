#!/bin/bash
#(c)2017 Alces Software Ltd. HPC Consulting Build Suite
#Job ID: <JOB>
#Cluster: <CLUSTER>

. /root/.deployment

yum -y install httpd
service httpd start
systemctl enable httpd

