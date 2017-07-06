yum -y install nfs-utils

<% if networks.pri.ip == netconfig.nfsserver -%>
# Create export directories
<% nfsmounts.each do | mount, path | -%>
mkdir -p <%= path %>
<% end -%>

# Increase nfsd thread count
sed -ie "s/^#\RPCNFSDCOUNT.*$/\RPCNFSDCOUNT=32/g" /etc/sysconfig/nfs

EXPORTS=`cat << EOF
<% nfsmounts.each do | mount, path | -%>
<%= path %>    <%= networks.pri.network %>/<%= networks.pri.netmask %>(rw,no_root_squash,sync)
<% end -%>
EOF`

echo "$EXPORTS" >> /etc/exports

<% else -%>

MOUNTS=`cat << EOF
<% nfsmounts.each do | mount, path | -%>
<%= netconfig.nfsserver %>:<%= path %>    <%= path %>    nfs    intr,rsize=32768,wsize=32768,_netdev    0 0
<% end -%>
EOF`

echo "$MOUNTS" >> /etc/fstab

<% nfsmounts.each do | mount, path | -%>
mkdir -p <%= path %>
<% end -%>

<% end -%>

systemctl enable nfs
systemctl restart nfs
