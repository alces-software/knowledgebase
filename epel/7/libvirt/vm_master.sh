#!/bin/bash

CORE_DIR=/tmp/metalware/core

yum groupinstall -y virtualization-platform virtualization-tools
yum install -y virt-viewer virt-install

cat << EOF > /var/lib/firstrun/scripts/libvirt.bash
systemctl enable libvirtd
systemctl start libvirtd

mkdir /opt/vm
virsh pool-define-as local dir - - - - "/opt/vm/"
virsh pool-build local
virsh pool-start local
virsh pool-autostart local

firewall-cmd --add-port 16514/tcp --zone=<%= networks.pri.firewallpolicy %> --permanent
firewall-cmd --reload

systemctl restart libvirtd
EOF
