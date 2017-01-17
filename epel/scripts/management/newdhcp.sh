#!/bin/bash
#(c)2017 Alces Software Ltd. HPC Consulting Build Suite
#Job ID: <JOB>
#Cluster: <CLUSTER>

HOST=$1
MAC=$2

TAIL="<CLUSTERDOMAIN>"

IP=`gethostip -d ${HOST}${TAIL} 2>/dev/null`
HEXIP=`gethostip -x ${HOST}${TAIL} 2>/dev/null`
if [ -z "$IP" ]; then
  echo "Unable to determine IP for $HOST" >&2
  exit 1
fi

if [ -z "$MAC" ]; then
  echo "Unable to determine MAC" >&2
  exit 1
fi

cat << EOF >> /etc/dhcp/dhcpd.hosts
  host $HOST {
    hardware ethernet $MAC;
    option host-name "$HOST.<CLUSTERDOMAIN>";
    option routers 10.10.192.128;
    filename "/pxelinux.0";
    fixed-address $IP;
  }
EOF

service dhcpd restart
