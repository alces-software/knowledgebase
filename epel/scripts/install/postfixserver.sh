#!/bin/bash 
#(c)2017 Alces Software Ltd. HPC Consulting Build Suite
#Job ID: <JOB>
#Cluster: <CLUSTER>

if [ -f /root/.alcesconf ]; then
  . /root/.alcesconf
fi

FILES_URL=http://${_ALCES_BUILDSERVER}/epel/files/${_ALCES_CLUSTER}/

yum -y install postfix mailx
curl $FILES_URL/postfixmaster | envsubst "$_ALCES_KEYS" > /etc/postfix/main.cf

systemctl enable postfix
systemctl restart postfix
