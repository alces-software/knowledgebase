curl -sL http://git.io/metalware-installer | sudo alces_OS=el7 /bin/bash

yum -y install dhcp fence-agents tftp xinetd tftp-server syslinux syslinux-tftpboot httpd php

sed -ie "s/^.*disable.*$/\    disable = no/g" /etc/xinetd.d/tftp
systemctl enable xinetd
systemctl enable dnsmasq
systemctl enable dhcpd
systemctl enable httpd

PXE_BOOT=/var/lib/tftpboot/boot
mkdir -p "$PXE_BOOT"
curl http://mirror.ox.ac.uk/sites/mirror.centos.org/7/os/x86_64/images/pxeboot/initrd.img > "$PXE_BOOT/centos7-initrd.img"
curl http://mirror.ox.ac.uk/sites/mirror.centos.org/7/os/x86_64/images/pxeboot/vmlinuz > "$PXE_BOOT/centos7-kernel"
mkdir -p /var/lib/tftpboot/pxelinux.cfg/
cat << EOF > /var/lib/tftpboot/pxelinux.cfg/default
DEFAULT menu
PROMPT 0
MENU TITLE PXE Menu
TIMEOUT 100
TOTALTIMEOUT 1000
ONTIMEOUT local

LABEL local
     MENU LABEL (local)
     MENU DEFAULT
     LOCALBOOT 0
EOF

DOMAIN=pri.testcluster.cluster.local
DNSSERVERS=10.10.0.1
NTPSERVERS=10.10.0.1
BUILDSERVER=10.10.0.1
PRVNETWORK=10.10.0.0
PRVNETMASK=255.255.0.0
ROUTER=10.10.0.1
EXTERNALDNS=10.101.0.1
REPOPATH=repo

echo "$BUILDSERVER `hostname -f` `hostname -s`" >> /etc/hosts

cat << EOF > /etc/dhcp/dhcpd.conf
# dhcpd.conf
omapi-port 7911;

default-lease-time 43200;
max-lease-time 86400;
ddns-update-style none;
option domain-name "${DOMAIN}";
option domain-name-servers ${DNSSERVERS};
option ntp-servers ${NTPSERVERS};

allow booting;
allow bootp;

option fqdn.no-client-update    on;  # set the "O" and "S" flag bits
option fqdn.rcode2            255;
option pxegrub code 150 = text ;



# PXE Handoff.
next-server ${BUILDSERVER};
filename "pxelinux.0";

log-facility local7;
group {
  include "/etc/dhcp/dhcpd.hosts";
}
#################################
# private network
#################################
subnet ${PRVNETWORK} netmask ${PRVNETMASK} {
#  pool
#  {
#    range 10.10.200.100 10.10.200.200;
#  }

  option subnet-mask ${PRVNETMASK};
  option routers ${ROUTER};
}
EOF

cat << EOF > /etc/httpd/conf.d/deployment.conf
<Directory /var/lib/metalware/rendered/>
    Options Indexes MultiViews FollowSymlinks
    AllowOverride None
    Require all granted
    Order Allow,Deny
    Allow from $PRVNETWORK/$PRVNETMASK
    Allow from 127.0.0.1/8
</Directory>
Alias /metalware /var/lib/metalware/rendered/
EOF

mkdir -p /var/lib/metalware/rendered/exec/
cat << 'EOF' > /var/lib/metalware/rendered/exec/kscomplete.php
<?php
$cmd="touch /var/lib/metalware/cache/built-nodes/metalwarebooter." . $_GET['name'];
exec($cmd);
?>
EOF
systemctl restart httpd
systemctl restart xinetd

mkdir -p /root/.ssh; echo 'StrictHostKeyChecking no' >> /root/.ssh/config

yum -y install createrepo httpd yum-plugin-priorities yum-utils
systemctl enable httpd.service

cat << EOF > /etc/httpd/conf.d/installer.conf
<Directory /opt/alces/$REPOPATH/>
    Options Indexes MultiViews FollowSymlinks
    AllowOverride None
    Require all granted
    Order Allow,Deny
    Allow from $BUILDSERVER/255.255.0.0
</Directory>
Alias /repo /opt/alces/$REPOPATH

<Directory /opt/alces/installers/>
    Options Indexes MultiViews FollowSymlinks
    AllowOverride None
    Require all granted
    Order Allow,Deny
    Allow from $BUILDSERVER/255.255.0.0
</Directory>
Alias /installers /opt/alces/installers
EOF


# Setup directories
if [ ! -d /opt/alces ]; then
    mkdir -p /opt/alces
fi

cd /opt/alces

if [ ! -d installers ] ; then
    mkdir -p installers
fi

if [ ! -d $REPOPATH ] ; then
    mkdir -p $REPOPATH
fi

cd $REPOPATH

mkdir custom

createrepo custom

systemctl restart httpd.service

yum -y install bind bind-utils

cat << EOF > /etc/named.conf
options {
          listen-on port 53 { any; };
          directory       "/var/named";
          dump-file       "/var/named/data/cache_dump.db";
          statistics-file "/var/named/data/named_stats.txt";
          memstatistics-file "/var/named/data/named_mem_stats.txt";
          allow-query     { any; };
          recursion yes;


          dnssec-enable no;
          dnssec-validation no;
          dnssec-lookaside auto;

          forward first;
          forwarders {
              ${EXTERNALDNS};
          };

};

logging {
        channel default_debug {
                file "data/named.run";
                severity dynamic;
        };
};

include "/etc/named/metalware.conf";
EOF

systemctl disable dnsmasq
systemctl stop dnsmasq
systemctl enable named
systemctl restart named

echo "You need to reboot"
