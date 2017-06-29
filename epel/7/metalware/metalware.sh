curl -sL http://git.io/metalware-installer | sudo alces_OS=el7 /bin/bash

yum -y install dhcp fence-agents tftp xinetd tftp-server syslinux syslinux-tftpboot httpd php

sed -ie "s/^.*disable.*$/\    disable = no/g" /etc/xinetd.d/tftp
systemctl enable xinetd
systemctl enable dnsmasq
systemctl enable dhcpd

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

systemctl restart xinetd