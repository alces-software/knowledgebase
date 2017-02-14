#!/bin/bash 
#(c)2017 Alces Software Ltd. HPC Consulting Build Suite
#Job ID: <JOB>
#Cluster: <CLUSTER>

source /root/.deployment

yum -y install postfix mailx
install_file postfixclient /etc/postfix/main.cf

systemctl enable postfix
systemctl restart postfix
