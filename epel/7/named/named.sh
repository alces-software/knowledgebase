<% if networks.pri.ip == alces.hostip -%>

# Setup named config file
cat << EOF > /etc/named/metalware.conf
<% networks.each do |zone, net| -%>
zone "<%= zone %>.<%= domain %>." {
    type master;
    file "<%= zone %>.<%= domain %>";
};

<% end -%>

<% networks.each do |zone, net| -%>
<% next if zone.to_s == 'bmc' -%>
<% split_net = net.network.split(/\./) -%>
zone "<%= split_net[1] %>.<%= split_net[0] %>.in-addr.arpa." {
    type master;
    file "<%= split_net[1] %>.<%= split_net[0] %>";
};

<% end -%>
EOF

# Setup zone forward files
<% networks.each do |zone, net| -%>
cat << EOF > /var/named/<%= zone %>.<%= domain %>
\$TTL 300
@                       IN      SOA     <%=alces.hostip%>. nobody.example.com. (
                                        <%= Time.now.to_i %>   ; Serial
                                        600         ; Refresh
                                        1800         ; Retry
                                        604800       ; Expire
                                        300          ; TTL
                                        )

                        IN      NS      <%= alces.hostip %>.
@       IN MX   <%= networks[zone].network.split(/\./).first %>  <%= networks[zone].hostname %>.

IN NS <%= alces.hostip %>.

<% alces.groups do |group| -%>
<% group.nodes do |node| -%>
<% node.networks.each do |name, network| -%>
<% if network.defined -%>
<% if name.to_s == zone.to_s -%>
<%= node.alces.nodename %> IN A <%= network.ip %>;
<% end -%>
<% end -%>
<% end -%>
<% end -%>
<% end -%>

EOF

<% end -%>

# Setup zone reverse files
<% networks.each do |zone, net| -%>
<% next if zone.to_s == 'bmc' -%>
<% split_net = net.network.split(/\./) -%>
cat << EOF > /var/named/<%= split_net[1] %>.<%= split_net[0] %>
\$TTL 300
@                       IN      SOA     <%=alces.hostip%>. nobody.example.com. (
                                        <%= Time.now.to_i %>   ; Serial
                                        600         ; Refresh
                                        1800         ; Retry
                                        604800       ; Expire
                                        300          ; TTL
                                        )

                        IN      NS      <%= alces.hostip %>.

<% alces.groups do |group| -%>
<% group.nodes do |node| -%>
<% node.networks.each do |name, network| -%>
<% if network.defined -%>
<% if network.network.to_s == net.network.to_s -%>
<% ip_split = network.ip.split(/\./) -%>
<%= ip_split[3] %>.<%= ip_split[2] %> IN PTR <%= node.alces.nodename %>.<%= name %>.<%= domain %>.;
<% end -%>
<% end -%>
<% end -%>
<% end -%>
<% end -%>

EOF

<% end -%>

<% end -%>

# Backup /etc/hosts (overwrite in future once testing works)
mv -f /etc/hosts /etc/hosts.bup
cat << EOF > /etc/hosts
127.0.0.1   localhost localhost.localdomain localhost4 localhost4.localdomain4
::1         localhost localhost.localdomain localhost6 localhost6.localdomain6

<%= alces.hostip %>  deploy.pri.<%= domain %> deploy.<%= domain %> deploy
EOF

# Backup /etc/resolv.conf (overwrite in future once testing works)
mv -f /etc/resolv.conf /etc/resolv.conf
cat << EOF > /etc/resolv.conf
search <% networks.each do |zone, net| -%><%= zone %>.<%=domain %> <% end %>
nameserver <%= alces.hostip %>
EOF

