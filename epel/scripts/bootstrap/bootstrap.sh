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
if [ -d ${_ALCES_CLUSTER} ]; then
  mv -v ${_ALCES_CLUSTER} ${_ALCES_CLUSTER}-`date +%F_%T`
fi
git clone https://github.com/alces-software/knowledgebase.git ${_ALCES_CLUSTER}
ln -snf ${_ALCES_CLUSTER}/epel epel


KBPATH=/var/www/html/${_ALCES_CLUSTER}/epel/

cp -v /root/.alcesconf ${KBPATH}/conf/${_ALCES_CLUSTER}
ln -snf ${KBPATH}/conf/${_ALCES_CLUSTER} ${KBPATH}/conf/config
