#!/bin/bash
#(c)2017 Alces Software Ltd. HPC Consulting Build Suite
#Job ID: <JOB>
#Cluster: <CLUSTER>

if [ -z $BASE_HOSTNAME ]; then
  echo 'export hostname as $BASE_HOSTNAME' >&2
  exit 1
fi

if [ -z $PROFILE ]; then
  echo 'export role as $PROFILE, eg INFRA,COMPUTE' >&2
  exit 1
fi

BUILDSERVER=<MASTERIP>

FILES_URL=http://$BUILDSERVER/<CLUSTER>/files/

PRVINTERFACE=em1
MGTINTERFACE=""
IBINTERFACE=ib0

PRVHOSTNAME=${BASE_HOSTNAME}.prv
MGTHOSTNAME=${BASE_HOSTNAME}.mgt
IBHOSTNAME=${BASE_HOSTNAME}.ib
BMCHOSTNAME=${BASE_HOSTNAME}.bmc

systemctl disable NetworkManager
service NetworkManager stop

curl $FILES_URL/hosts > /etc/hosts

rm -rf /etc/yum.repos.d/*.repo
curl $FILES_URL/yum > /etc/yum.repos.d/cluster.repo

curl $FILES_URL/ntp > /etc/ntp.conf

curl $FILES_URL/postfix > /etc/postfix/main.cf

mkdir -m 0700 /root/.ssh
curl $FILES_URL/authorized_keys > /root/.ssh/authorized_keys
chmod 600 /root/.ssh/authorized_keys

echo "StrictHostKeyChecking no" >> /root/.ssh/config

echo "HOSTNAME=${BASE_HOSTNAME}.<CLUSTERDOMAIN>" >> /etc/sysconfig/network
echo "${BASE_HOSTNAME}.<CLUSTERDOMAIN>" > /etc/hostname

yum -y install yum-plugin-priorities

yum -y install net-tools bind-utils ipmitool

yum -y update 

systemctl disable firewalld

if ! [ -z $PRVHOSTNAME ]; then
cat << EOF > /etc/sysconfig/network-scripts/ifcfg-$PRVINTERFACE
TYPE=Ethernet
BOOTPROTO=none
DEFROUTE=yes
PEERDNS=no
PEERROUTES=no
IPV4_FAILURE_FATAL=no
IPV6INIT=no
IPV6_AUTOCONF=yes
IPV6_DEFROUTE=yes
IPV6_PEERDNS=yes
IPV6_PEERROUTES=yes
IPV6_FAILURE_FATAL=no
NAME=$PRVINTERFACE
DEVICE=$PRVINTERFACE
ONBOOT=yes
IPADDR=`getent hosts $PRVHOSTNAME | awk ' { print $1 }'`
NETMASK=255.255.248.0
ZONE=trusted
GATEWAY=10.10.192.128
EOF
fi

if ! [ -z $MGTHOSTNAME ]; then
cat << EOF > /etc/sysconfig/network-scripts/ifcfg-$MGTINTERFACE
TYPE=Ethernet
BOOTPROTO=none
DEFROUTE=no
PEERDNS=no
PEERROUTES=no
IPV4_FAILURE_FATAL=no
IPV6INIT=no
IPV6_AUTOCONF=yes
IPV6_DEFROUTE=yes
IPV6_PEERDNS=yes
IPV6_PEERROUTES=yes
IPV6_FAILURE_FATAL=no
NAME=$MGTINTERFACE
DEVICE=$MGTINTERFACE
ONBOOT=yes
IPADDR=`getent hosts $MGTHOSTNAME | awk ' { print $1 }'`
NETMASK=255.255.248.0
ZONE=trusted
EOF
fi

if ! [ -z $IBHOSTNAME ]; then
cat << EOF > /etc/sysconfig/network-scripts/ifcfg-$IBINTERFACE
TYPE=Ethernet
BOOTPROTO=none
DEFROUTE=no
PEERDNS=no
PEERROUTES=no
IPV4_FAILURE_FATAL=no
IPV6INIT=no
IPV6_AUTOCONF=yes
IPV6_DEFROUTE=yes
IPV6_PEERDNS=yes
IPV6_PEERROUTES=yes
IPV6_FAILURE_FATAL=no
NAME=$IBINTERFACE
DEVICE=$IBINTERFACE
ONBOOT=yes
IPADDR=`getent hosts $IBHOSTNAME | awk ' { print $1 }'`
NETMASK=255.255.248.0
ZONE=trusted
EOF
fi

if ! [ -z $BMCHOSTNAME ]; then
  service ipmi start
  sleep 1
  IPMILANCHANNEL=1
  IPMIUSERID=2
  ipmitool lan set $IPMILANCHANNEL ipsrc static
  sleep 2
  ipmitool lan set $IPMILANCHANNEL ipaddr `getent hosts $BMCHOSTNAME | awk ' { print $1 }'`
  sleep 2
  ipmitool lan set $IPMILANCHANNEL netmask 255.255.248.0
  sleep 2
  ipmitool lan set $IPMILANCHANNEL defgw ipaddr 10.10.208.1
  sleep 2
  ipmitool user set name $IPMIUSERID admin
  sleep 2
  ipmitool user set password $IPMIUSERID Rercyig7
  sleep 2
  ipmitool lan print $IPMILANCHANNEL
  ipmitool user list 2
  ipmitool mc reset cold
fi

cat << EOF > /etc/resolv.conf
search <CLUSTERDOMAIN> 
nameserver <MASTERIP>
EOF

#Branch for profile
if [ $PROFILE -eq 'INFRA' ]; then
  yum -y install device-mapper-multipath sg3_utils
  yum -y groupinstall "Gnome Desktop"
  mpathconf
  mpathconf --enable
else
    
fi

