#!/bin/bash 
#(c)2017 Alces Software Ltd. HPC Consulting Build Suite
#Job ID: <JOB>
#Cluster: <CLUSTER>

source /root/.deployment

yum -y install postfix mailx
install_file postfixmaster /etc/postfix/main.cf
install_file postfixrewrite /etc/postfix/master-rewrite-sender

systemctl enable postfix
systemctl restart postfix
