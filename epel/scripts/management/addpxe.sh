#!/bin/bash
#(c)2017 Alces Software Ltd. HPC Consulting Build Suite
#Job ID: <JOB>
#Cluster: <CLUSTER>

HOST=$1
PROFILE=$2

. /root/.alcesconf

export BASE_HOSTNAME=$HOST

TAIL=".prv.${_ALCES_DOMAIN}"

echo -n "Resolving ${HOST}${TAIL}.."

HEXIP=`gethostip -x ${HOST}${TAIL} 2>/dev/null`
echo "$HEXIP"

if [ -z "$HEXIP" ]; then
  echo "Unable to determine IP for $HOST" >&2
  exit 1
fi

if [ -z "$PROFILE" ]; then
  echo "Unable to determine PROFILE" >&2
  exit 1
fi

(cd /var/lib/tftpboot/pxelinux.cfg/ && cat $PROFILE | envsubst 'BASE_HOSTNAME' > `gethostip -x ${HOST}${TAIL}`)
