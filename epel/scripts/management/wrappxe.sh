#!/bin/bash
#(c)2017 Alces Software Ltd. HPC Consulting Build Suite
#Job ID: <JOB>
#Cluster: <CLUSTER>

HOST=$1
PROFILE=$2
OTHERTAGS=$3

. /root/.deployment

BASE_HOSTNAME=$HOST
TAIL=".prv.${_ALCES_DOMAIN}"

echo -n "Resolving ${HOST}${TAIL}.."

HEXIP=`gethostip -x ${HOST}${TAIL} 2>/dev/null`
IP=`gethostip -d ${HOST}${TAIL} 2>/dev/null`
echo "$HEXIP:$IP"

if [ -z "$HEXIP" ]; then
  echo "Unable to determine IP for $HOST" >&2
  exit 1
fi

if [ -z "$PROFILE" ]; then
  echo "Unable to determine PROFILE" >&2
  exit 1
fi

export ALCESTAGS="_ALCES_BASE_HOSTNAME=$BASE_HOSTNAME $OTHERTAGS"

echo "Installing PXE entry.."
(cd /var/lib/tftpboot/pxelinux.cfg/ && cat $PROFILE | envsubst '$ALCESTAGS' > `gethostip -x ${HOST}${TAIL}`)

echo "Waiting for machine to download kickstart.."
tail -f -n 0 /var/log/httpd/access_log | sed -e "/^$IP.*GET \/.*\/ks\/$PROFILE.ks.*$/ q" &>/dev/null

echo "Removing PXE entry.."
(cd /var/lib/tftpboot/pxelinux.cfg/ && rm -v `gethostip -x ${HOST}${TAIL}`)
