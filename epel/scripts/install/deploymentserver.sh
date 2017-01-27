#!/bin/bash
#(c)2017 Alces Software Ltd. HPC Consulting Build Suite
#Job ID: <JOB>
#Cluster: <CLUSTER>

if [ -f /root/.alcesconf ]; then
  . /root/.alcesconf
fi

FILES_URL=http://${_ALCES_BUILDSERVER}/epel/files/${_ALCES_CLUSTER}/
KS_URL=http://${_ALCES_BUILDSERVER}/epel/ks/

echo "Enter root password for crypting"
read PASSWD
export _ALCES_ROOTPASSWORDCRYPT=`openssl passwd -1 $PASSWD`

yum -y install dhcp fence-agents tftp xinetd tftp-server syslinux syslinux-tftpboot

sed -ie "s/^.*disable.*$/\        disable                 = no/g" /etc/xinetd.d/tftp
systemctl enable xinetd
systemctl restart xinetd

mkdir -p /var/lib/tftpboot/pxelinux.cfg

curl $FILES_URL/pxedefault | envsubst > /var/lib/tftpboot/pxelinux.cfg/default
curl $FILES_URL/pxecompute | envsubst > /var/lib/tftpboot/pxelinux.cfg/compute
curl $FILES_URL/pxelogin | envsubst > /var/lib/tftpboot/pxelinux.cfg/login

mkdir -p /var/www/html/${_ALCES_CLUSTER}/ks
curl $KS_URL/compute.ks | envsubst "$_ALCES_KEYS \$_ALCES_ROOTPASSWORDCRYPT" > /var/www/html/${_ALCES_CLUSTER}/ks/compute.ks
curl $KS_URL/login.ks | envsubst "$_ALCES_KEYS \$_ALCES_ROOTPASSWORDCRYPT" > /var/www/html/${_ALCES_CLUSTER}/ks/login.ks

mkdir -p /var/lib/tftpboot/boot/
curl http://mirror.ox.ac.uk/sites/mirror.centos.org/7/os/x86_64/images/pxeboot/initrd.img > /var/lib/tftpboot/boot/centos7-initrd.img
curl http://mirror.ox.ac.uk/sites/mirror.centos.org/7/os/x86_64/images/pxeboot/vmlinuz > /var/lib/tftpboot/boot/centos7-kernel

curl $FILES_URL/dhcpd | envsubst > /etc/dhcp/dhcpd.conf
touch /etc/dhcp/dhcpd.hosts

systemctl enable dhcpd
systemctl restart dhcpd

systemctl enable dnsmasq
systemctl restart dnsmasq
