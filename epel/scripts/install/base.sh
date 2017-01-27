#!/bin/bash
#(c)2017 Alces Software Ltd. HPC Consulting Build Suite
#Job ID: <JOB>
#Cluster: <CLUSTER>

if [ -f /root/.alcesconf ]; then
  . /root/.alcesconf
fi

if [ -z "${BASE_HOSTNAME}" ]; then
  BASE_HOSTNAME=${_ALCES_BASE_HOSTNAME}
fi
DOMAIN=${_ALCES_DOMAIN}

BUILDSERVER=$_ALCES_BUILDSERVER

FILES_URL=http://${BUILDSERVER}/epel/files/${_ALCES_CLUSTER}/

PRVINTERFACE=${_ALCES_PRVINTERFACE}
MGTINTERFACE=${_ALCES_MGTINTERFACE}
IBINTERFACE=${_ALCES_IBINTERFACE}

PRVNETMASK=${_ALCES_PRVNETMASK}
MGTNETMASK=255.255.0.0
BMCNETMASK=255.255.0.0
IBNETMASK=255.255.0.0

PRVGATEWAY=10.10.0.11
BMCGATEWAY=10.11.0.11

PRVHOSTNAME=${_ALCES_BASE_HOSTNAME}.prv
MGTHOSTNAME=${_ALCES_BASE_HOSTNAME}.mgt
IBHOSTNAME=${_ALCES_BASE_HOSTNAME}.ib
BMCHOSTNAME=${_ALCES_BASE_HOSTNAME}.bmc

BMCPASSWORD=${_ALCES_BMC_PASSWORD}

systemctl disable NetworkManager
service NetworkManager stop

curl $FILES_URL/hosts | envsubst > /etc/hosts

rm -rf /etc/yum.repos.d/*.repo
curl $FILES_URL/yum.local | envsubst > /etc/yum.repos.d/cluster.repo

yum -y install ntp
curl $FILES_URL/ntp | envsubst > /etc/ntp.conf
systemctl enable ntpd
systemctl restart ntpd

curl $FILES_URL/postfix | envsubst > /etc/postfix/main.cf

mkdir -m 0700 /root/.ssh
curl $FILES_URL/authorized_keys | envsubst > /root/.ssh/authorized_keys
chmod 600 /root/.ssh/authorized_keys

echo "StrictHostKeyChecking no" >> /root/.ssh/config

echo "HOSTNAME=${_ALCES_BASE_HOSTNAME}.prv.${DOMAIN}" >> /etc/sysconfig/network
echo "${_ALCES_BASE_HOSTNAME}.prv.${DOMAIN}" > /etc/hostname

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
NETMASK=$PRVNETMASK
ZONE=trusted
GATEWAY=$PRVGATEWAY
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
NETMASK=$MGTNETMASK
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
NETMASK=$IBNETMASK
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
  ipmitool lan set $IPMILANCHANNEL netmask $BMCNETMASK
  sleep 2
  ipmitool lan set $IPMILANCHANNEL defgw ipaddr $BMCGATEWAY
  sleep 2
  ipmitool user set name $IPMIUSERID admin
  sleep 2
  ipmitool user set password $IPMIUSERID $BMCPASSWORD
  sleep 2
  ipmitool lan print $IPMILANCHANNEL
  ipmitool user list 2
  ipmitool mc reset cold
fi

cat << EOF > /etc/resolv.conf
search $DOMAIN
nameserver $BUILDSERVER
EOF

#Branch for profile
if [ "${_ALCES_PROFILE}" -eq 'INFRA' ]; then
  yum -y install device-mapper-multipath sg3_utils
  yum -y groupinstall "Gnome Desktop"
  mpathconf
  mpathconf --enable
else
  echo "Unrecognised profile"    
fi

