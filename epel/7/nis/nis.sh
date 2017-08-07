<% if nisconfig.is_server -%>

yum install -y ypserv yp-tools
<% if !nisconfig.users_dir.nil? -%>
# Modify default user home directory
sed -i -e 's|^HOME=.*$|HOME=<%= nisconfig.users_dir %>|g' /etc/default/useradd
<% end -%>

echo "domain <%= nisconfig.nisdomain %> server 127.0.0.1" > /etc/yp.conf
nisdomainname <%= nisconfig.nisdomain %>
echo "NISDOMAIN=<%= nisconfig.nisdomain %>" > /etc/sysconfig/network

cat << EOF > /var/yp/sercurenets
host 127.0.0.1
<%= networks.pri.netmask %> <%= networks.pri.network %>
EOF

sed -e 's/^all.*$/all:  passwd group hosts rpc services netid protocols mail shadow \\/g' -e 's/^MERGE_PASSWD.*$/MERGE_PASSWD=false/g' -i /var/yp/Makefile
echo -e "shadow\t\tshadow.byname" >> /var/yp/nicknames
systemctl enable ypserv
systemctl enable yppasswdd
systemctl restart ypserv
systemctl restart yppasswdd

make -C /var/yp

<% else -%>

yum -y install ypbind
echo "domain <%= nisconfig.nisdomain %> server <%= nisconfig.nisserver %>" > /etc/yp.conf
nisdomainname <%= nisconfig.nisdomain %>
echo "NISDOMAIN=<%= nisconfig.nisdomain %>" > /etc/sysconfig/network

sed -i -e 's/^passwd:.*/passwd:     files nis/g' \
-e 's/^shadow:.*/shadow:     files nis/g' \
-e 's/^group.*/group:      files nis/g' /etc/nsswitch.conf
systemctl enable ypbind
systemctl start ypbind

authconfig --enablemkhomedir --update

<% end -%>
