#!/bin/bash
#(c)2017 Alces Software Ltd. HPC Consulting Build Suite
#Job ID: <JOB>
#Cluster: <CLUSTER>

if [ -f /root/.alcesconf ]; then
  . /root/.alcesconf
fi

yum -y install git

mkdir -p /var/www/html/
cd /var/www/html
git clone https://github.com/alces-software/knowledgebase.git ${_ALCES_CLUSTER}

