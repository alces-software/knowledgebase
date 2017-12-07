yum groupinstall -y virtualization-platform virtualization-tools
yum install -y virt-viewer virt-install

sed -i 's/#LIBVIRTD_ARGS="--listen"/LIBVIRTD_ARGS="--listen"/g' /etc/sysconfig/libvirtd

cat << EOF > /var/lib/firstrun/scripts/libvirt.bash
systemctl enable libvirtd
systemctl start libvirtd

mkdir /opt/vm
virsh pool-define-as local dir - - - - "/opt/vm/"
virsh pool-build local
virsh pool-start local
virsh pool-autostart local

cp $CORE_DIR/cacert.pem /etc/pki/CA/cacert.pem
mkdir -p /etc/pki/libvirt/private
cp $CORE_DIR/<%= alces.nodename %>-key.pem /etc/pki/libvirt/private/serverkey.pem
cp $CORE_DIR/<%= alces.nodename %>-cert.pem /etc/pki/libvirt/servercert.pem

firewall-cmd --add-port 16514/tcp --zone=<%= networks.pri.firewallpolicy %> --permanent
firewall-cmd --reload

systemctl restart libvirtd
EOF
