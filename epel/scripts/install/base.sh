#!/bin/bash
#(c)2017 Alces Software Ltd. HPC Consulting Build Suite
#Job ID: <JOB>
#Cluster: <CLUSTER>

source /root/.deployment

if [ -z "${BASE_HOSTNAME}" ]; then
  BASE_HOSTNAME=${_ALCES_BASE_HOSTNAME}
fi
DOMAIN=${_ALCES_DOMAIN}

BUILDSERVER=$_ALCES_BUILDSERVER

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

install_file hosts /etc/hosts

rm -rf /etc/yum.repos.d/*.repo
install_file $_ALCES_YUMTEMPLATE /etc/yum.repos.d/cluster.repo
yum -y install ntp
install_file ntp /etc/ntp.conf
systemctl enable ntpd
systemctl restart ntpd
systemctl disable chronyd

mkdir -m 0700 /root/.ssh
install_file authorized_keys /root/.ssh/authorized_keys
chmod 600 /root/.ssh/authorized_keys

echo "StrictHostKeyChecking no" >> /root/.ssh/config

echo "HOSTNAME=${_ALCES_BASE_HOSTNAME}.prv.${DOMAIN}" >> /etc/sysconfig/network
echo "${_ALCES_BASE_HOSTNAME}.prv.${DOMAIN}" > /etc/hostname

yum -y install yum-plugin-priorities yum-utils

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

if ! [ -z "$MGTINTERFACE" ]; then
if ! [ -z "$MGTHOSTNAME" ]; then
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
fi

if ! [ -z "$IBINTERFACE" ]; then
if ! [ -z "$IBHOSTNAME" ]; then
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
fi

if ! [ -z "$BMCHOSTNAME" ]; then
  BMCIP=`getent hosts "$BMCHOSTNAME" | awk ' { print $1 }'`
  if ! [ -z "BMCIP" ]; then
    service ipmi start
    sleep 1
    IPMILANCHANNEL=1
    IPMIUSERID=2
    ipmitool lan set $IPMILANCHANNEL ipsrc static
    sleep 2
    ipmitool lan set $IPMILANCHANNEL ipaddr $BMCIP
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
fi

if ! [ "$_ALCES_PROFILE" = "MASTER" ]; then
cat << EOF > /etc/resolv.conf
search $DOMAIN
nameserver $BUILDSERVER
EOF
else
cat << EOF > /etc/resolv.conf
search $DOMAIN
nameserver $_ALCES_EXTERNALDNS
EOF
fi

#Branch for profile
if [ "${_ALCES_PROFILE}" == 'INFRA' ]; then
  yum -y install device-mapper-multipath sg3_utils
  yum -y groupinstall "Gnome Desktop"
  mpathconf
  mpathconf --enable
else
  echo "Unrecognised profile"    
fi

