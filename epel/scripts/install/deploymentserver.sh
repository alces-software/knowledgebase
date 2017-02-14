#!/bin/bash
#(c)2017 Alces Software Ltd. HPC Consulting Build Suite
#Job ID: <JOB>
#Cluster: <CLUSTER>

source /root/.deployment

KS_URL=http://${_ALCES_BUILDSERVER}/epel/ks/

yum -y install dhcp fence-agents tftp xinetd tftp-server syslinux syslinux-tftpboot

sed -ie "s/^.*disable.*$/\        disable                 = no/g" /etc/xinetd.d/tftp
systemctl enable xinetd
systemctl restart xinetd

mkdir -p /var/lib/tftpboot/pxelinux.cfg

install_file pxedefault /var/lib/tftpboot/pxelinux.cfg/default
install_file pxecompute /var/lib/tftpboot/pxelinux.cfg/compute
install_file pxelogin /var/lib/tftpboot/pxelinux.cfg/login
install_file pxeinfra /var/lib/tftpboot/pxelinux.cfg/infra

mkdir -p /var/www/html/${_ALCES_CLUSTER}/ks
install_file compute.ks /var/www/html/${_ALCES_CLUSTER}/ks/compute.ks
install_file login.ks /var/www/html/${_ALCES_CLUSTER}/ks/login.ks
install_file infra.ks /var/www/html/${_ALCES_CLUSTER}/ks/infra.ks


mkdir -p /var/lib/tftpboot/boot/
curl http://mirror.ox.ac.uk/sites/mirror.centos.org/7/os/x86_64/images/pxeboot/initrd.img > /var/lib/tftpboot/boot/centos7-initrd.img
curl http://mirror.ox.ac.uk/sites/mirror.centos.org/7/os/x86_64/images/pxeboot/vmlinuz > /var/lib/tftpboot/boot/centos7-kernel

install_file dhcpd /etc/dhcp/dhcpd.conf
touch /etc/dhcp/dhcpd.hosts

systemctl enable dhcpd
systemctl restart dhcpd

systemctl enable dnsmasq
systemctl restart dnsmasq
