#!/bin/bash
#(c)2017 Alces Software Ltd. HPC Consulting Build Suite
#Job ID: <JOB>
#Cluster: <CLUSTER>

if ! [ -f "$CONFIG" ]; then
  echo "CAN'T FIND A CONFIG FILE" >&2
  exit 1
fi

source $CONFIG

yum -y install git vim emacs xauth xhost xdpyinfo xterm xclock tigervnc-server ntpdate wget vconfig bridge-utils patch tcl-devel gettext

mkdir -p /opt/metalware/deployment/

if [ -d ${_ALCES_CLUSTER} ]; then
  mv -v ${_ALCES_CLUSTER} ${_ALCES_CLUSTER}-`date +%F_%T`
fi
git clone https://github.com/alces-software/knowledgebase.git /opt/metalware/deployment/${_ALCES_CLUSTER}

KBPATH=/opt/metalware/deployment/${_ALCES_CLUSTER}/epel/

cp -v $CONFIG ${KBPATH}/conf/${_ALCES_CLUSTER}
ln -snf ${KBPATH}/conf/${_ALCES_CLUSTER} ${KBPATH}/conf/config
ln -snf ${KBPATH}/conf/${_ALCES_CLUSTER} /root/.deployment

ln -snf /opt/metalware/deployment/${_ALCES_CLUSTER} /opt/metalware/deployment/local
