yum install -y environment-modules

<% if modules.is_server -%>
mkdir <%= modules.directory %>
echo '<%= modules.directory %>    <%= networks.pri.network %>/<%= networks.pri.netmask %>(rw,no_root_squash,sync)'
exportfs -a
<% end -%>

echo '<%= modules.directory %>' >> /usr/share/Modules/init/.modulespath
echo '<%= modules.server %>:<%= modules.directory %>  <%= modules.directory %>  nfs  defaults  0 0' >> /etc/fstab
