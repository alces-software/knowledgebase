yum -y install nfs-utils

<% if nfsconfig.is_server -%>
# Create export directories
<% nfsexports.each do | path, opts | -%>
mkdir -p <%= path %>
<% end -%>

# Increase nfsd thread count
sed -ie "s/^#\RPCNFSDCOUNT.*$/\RPCNFSDCOUNT=32/g" /etc/sysconfig/nfs

EXPORTOPTS="<%= networks.pri.network %>/<%= networks.pri.netmask %>(rw,no_root_squash,sync)"

EXPORTS=`cat << EOF
<% nfsexports.each do | path, opts | -%>
<%= path %>   <%= if defined?(opts.options) then opts.options else "#{networks.pri.network}/#{networks.pri.netmask}(rw,no_root_squash,sync)" end %>
<% end -%>
EOF`

echo "$EXPORTS" > /etc/exports

<% else -%>

MOUNTS=`cat << EOF
<% nfsmounts.each do | mount, path | -%>
<%= path.server %>:<%= path.export %>    <%= mount %>    nfs    <%= if defined?(path.options) then path.options else 'intr,rsize=32768,wsize=32768,_netdev' end -%>    0 0
<% end -%>
EOF`

echo "$MOUNTS" >> /etc/fstab

<% nfsmounts.each do | mount, path | -%>
mkdir -p <%= path.target %>
<% end -%>

<% end -%>

systemctl enable nfs
systemctl restart nfs
