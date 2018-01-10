yum -y install nfs-utils

<% if (config.nfsconfig.is_server rescue false) -%>
# Create export directories
<% config.nfsexports.each do | path, opts | -%>
mkdir -p <%= path %>
<% end -%>

# Increase nfsd thread count
sed -ie "s/^#\RPCNFSDCOUNT.*$/\RPCNFSDCOUNT=32/g" /etc/sysconfig/nfs

EXPORTOPTS="<%= config.networks.pri.network %>/<%= config.networks.pri.netmask %>(rw,no_root_squash,sync)"

EXPORTS=`cat << EOF
<% config.nfsexports.each do | path, opts | -%>
<%= path %>   <%= if defined?(opts.options) then opts.options else "#{config.networks.pri.network}/#{config.networks.pri.netmask}(rw,no_root_squash,sync)" end %>
<% end -%>
EOF`

echo "$EXPORTS" > /etc/exports

<% elsif (!config.nisconfig.is_server rescue true) -%>

MOUNTS=`cat << EOF
<% config.nfsmounts.each do | mount, path | -%>
<%= path.server %>:<%= path.export %>    <%= mount %>    nfs    <%= if defined?(path.options) then path.options else 'intr,rsize=32768,wsize=32768,vers=3,_netdev' end -%>    0 0
<% end -%>
EOF`

echo "$MOUNTS" >> /etc/fstab

<% config.nfsmounts.each do | mount, path | -%>
mkdir -p <%= path.target %>
<% end -%>

<% end -%>

systemctl enable nfs
systemctl restart nfs
