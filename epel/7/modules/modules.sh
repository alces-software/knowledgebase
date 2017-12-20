yum install -y environment-modules

MODULESDIR="<%= config.modules.directory %>/modulefiles"

<% if (config.modules.is_server rescue false) -%>
mkdir $MODULESDIR
echo '<%= config.modules.directory %>    <%= config.networks.pri.network %>/<%= config.networks.pri.netmask %>(rw,no_root_squash,sync)' >> /etc/exports
exportfs -a
<% end -%>

echo "$MODULESDIR" >> /usr/share/Modules/init/.modulespath
<% if (!config.modules.is_server rescue true) -%>
echo '<%= config.modules.server %>:<%= config.modules.directory %>  <%= config.modules.directory %>  nfs  defaults  0 0' >> /etc/fstab
<% end -%>
