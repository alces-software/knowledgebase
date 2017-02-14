#!/bin/bash 
#(c)2017 Alces Software Ltd. HPC Consulting Build Suite
#Job ID: <JOB>
#Cluster: <CLUSTER>

source /root/.deployment

yum -y install postfix mailx
installfile postfixmaster /etc/postfix/main.cf
installfile postfixrewrite /etc/postfix/master-rewrite-sender

systemctl enable postfix
systemctl restart postfix
