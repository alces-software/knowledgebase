yum install -y environment-modules

MODULESDIR="<%= modules.directory %>/modulefiles"

<% if modules.is_server -%>
mkdir $MODULESDIR
echo '<%= modules.directory %>    <%= networks.pri.network %>/<%= networks.pri.netmask %>(rw,no_root_squash,sync)'
exportfs -a
<% end -%>

echo "$MODULESDIR" >> /usr/share/Modules/init/.modulespath
<% if ! modules.is_server -%>
echo '<%= modules.server %>:<%= modules.directory %>  <%= modules.directory %>  nfs  defaults  0 0' >> /etc/fstab
<% end -%>
