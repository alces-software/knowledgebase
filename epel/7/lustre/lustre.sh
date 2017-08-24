<% if lustreconfig.type == 'server' -%>
yum-config-manager --enable lustre-el7-server --enable e2fsprogs-el7

yum -y update
yum -y install lustre kmod-lustre-osd-ldiskfs

cat << EOF > /etc/modprobe.d/lustre.conf
options lnet networks=tcp0(<%= networks.pri.interface %>)
options ost oss_num_threads=96
options mdt mds_num_threads=96
EOF

yum-config-manager --disable lustre-el7-server --disable e2fsprogs-el7

<% elsif lustreconfig.type == 'client' -%>

yum-config-manager --enable lustre-el7-client --enable e2fsprogs-el7

yum -y install lustre-client

cat << EOF > /etc/modprobe.d/lustre.conf
options lnet networks=tcp0(<%= networks.pri.interface %>)
EOF

yum-config-manager --disable lustre-el7-client --disable e2fsprogs-el7

<% end -%>
