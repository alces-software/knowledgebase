DOMAIN=<%= networks.pri.hostname %>
DNSSERVERS=<%= build.build_pri_ip %>
NTPSERVERS=<%= build.build_pri_ip %>
BUILDSERVER=<%= build.build_pri_ip %>
PRVNETWORK=<%= networks.pri.network %>
PRVNETMASK=<%= networks.pri.netmask %>
ROUTER=<%= build.build_pri_ip %>
EXTERNALDNS=<%= externaldns %>
REPOPATH=<%= build.repo_path %>
PXE_BOOT=<%= build.pxeboot_path %>


# Network and hostname
echo "<%= build.controller_hostname %>.<%= domain %>" > /etc/hostname

cat << EOF > /etc/sysconfig/network-scripts/ifcfg-<%= networks.pri.interface %>
TYPE=Ethernet
DEVICE=<%= networks.pri.interface %>
ONBOOT=yes
BOOTPROTO=static
DEFROUTE=yes
IPADDR=<%= build.build_pri_ip%>
NETWORK=<%= networks.pri.network %>
NETMASK=<%= networks.pri.netmask %>
ZONE=<%= networks.pri.firewallpolicy %>
EOF

cat << EOF > /etc/sysconfig/network-scripts/ifcfg-<%= networks.mgt.interface %>
TYPE=Ethernet
DEVICE=<%= networks.mgt.interface %>
ONBOOT=yes
BOOTPROTO=static
IPADDR=<%= build.build_mgt_ip%>
NETWORK=<%= networks.mgt.network %>
NETMASK=<%= networks.mgt.netmask %>
ZONE=<%= networks.mgt.firewallpolicy %>
EOF

cat << EOF > /etc/sysconfig/network-scripts/ifcfg-<%= firewall.external.interface %>
TYPE=Ethernet
DEVICE=<%= firewall.external.interface %>
ONBOOT=yes
BOOTPROTO=dhcp
DNS1=127.0.0.1
DOMAIN="<%= search_domains %>"
ZONE=external
EOF

systemctl enable firewalld
systemctl start firewalld

<% firewall.each do |zone, info| -%>
# Create zone
firewall-cmd --info-zone=<%= zone %>
if [ $? != 0 ] ; then
    firewall-cmd --new-zone <%= zone %> --permanent
fi
# Add services
<%     info.services.split(' ').each do |service| -%>
firewall-cmd --add-service <%= service %> --zone <%= zone %>
<%     end -%>

<% end -%>
firewall-cmd --reload

# Add interfaces to zones
<% networks.each do |network, info| -%>
<%     if info.defined -%>
firewall-cmd --add-interface <%= info.interface %> --zone <%= info.firewallpolicy %> --permanent
<%     end -%>
<% end -%>
firewall-cmd --add-interface <%= firewall.external.interface %> --zone external --permanent

systemctl disable NetworkManager

# Network services
yum -y install dhcp fence-agents tftp xinetd tftp-server syslinux syslinux-tftpboot httpd php

sed -ie "s/^.*disable.*$/\    disable = no/g" /etc/xinetd.d/tftp
systemctl enable xinetd
systemctl enable dnsmasq
systemctl enable dhcpd
systemctl enable httpd

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
