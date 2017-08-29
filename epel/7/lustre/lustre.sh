<% if lustreconfig.type == 'server' -%>
yum -y --enablerepo lustre-el7-server --enablerepo e2fsprogs-el7 update
yum -y --enablerepo lustre-el7-server --enablerepo e2fsprogs-el7 install lustre kmod-lustre-osd-ldiskfs

cat << EOF > /etc/modprobe.d/lustre.conf
options lnet networks=tcp0(<%= networks.pri.interface %>)
options ost oss_num_threads=96
options mdt mds_num_threads=96
EOF

<% elsif lustreconfig.type == 'client' -%>

yum -y --enablerepo lustre-el7-server --enablerepo e2fsprogs-el7 install lustre-client

cat << EOF > /etc/modprobe.d/lustre.conf
options lnet networks=tcp0(<%= networks.pri.interface %>)
EOF

<% end -%>
