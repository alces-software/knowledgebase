#!/bin/bash
#(c)2017 Alces Software Ltd. HPC Consulting Build Suite
#Job ID: <JOB>
#Cluster: <CLUSTER>

HOST=$1

. /root/.deployment

TAIL=".prv.${_ALCES_DOMAIN}"

echo "Resolving ${HOST}${TAIL}"

HEXIP=`gethostip -x ${HOST}${TAIL} 2>/dev/null`
if [ -z "$HEXIP" ]; then
  echo "Unable to determine IP for $HOST" >&2
  exit 1
fi

(cd /var/lib/tftpboot/pxelinux.cfg/ && rm -v `gethostip -x ${HOST}${TAIL}`)
