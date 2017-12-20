<% if config.networks.pri.ip == domain.hostip -%>

# Setup named config file
cat << EOF > /etc/named/metalware.conf
<% config.networks.each do |zone, net| -%>
zone "<%= zone %>.<%= config.domain %>." {
    type master;
    file "<%= zone %>.<%= config.domain %>";
};

<% end -%>

<% config.networks.each do |zone, net| -%>
<% next if zone.to_s == 'bmc' -%>
<% split_net = net.network.split(/\./) -%>
zone "<%= split_net[1] %>.<%= split_net[0] %>.in-addr.arpa." {
    type master;
    file "<%= split_net[1] %>.<%= split_net[0] %>";
};

<% end -%>
EOF

chmod 644 /etc/named/metalware.conf

# Setup zone forward files
<% config.networks.each do |zone, net| -%>
cat << EOF > /var/named/<%= zone %>.<%= config.domain %>
\$TTL 300
@                       IN      SOA     <%=domain.hostip%>. nobody.example.com. (
                                        <%= Time.now.to_i %>   ; Serial
                                        600         ; Refresh
                                        1800         ; Retry
                                        604800       ; Expire
                                        300          ; TTL
                                        )

                        IN      NS      <%= domain.hostip %>.
@       IN MX   <%= config.networks[zone].network.split(/\./).first %>  <%= config.networks[zone].hostname %>.

IN NS <%= domain.hostip %>.

<% groups.each do |group| -%>
<% group.nodes.each do |node| -%>
<% node.networks.each do |name, network| -%>
<% if (network.defined rescue false) -%>
<% if name.to_s == zone.to_s -%>
<%= node.node.name %> IN A <%= network.ip %>;
<% end -%>
<% end -%>
<% end -%>
<% end -%>
<% end -%>

EOF

<% end -%>

# Setup zone reverse files
<% config.networks.each do |zone, net| -%>
<% next if zone.to_s == 'bmc' -%>
<% split_net = net.network.split(/\./) -%>
cat << EOF > /var/named/<%= split_net[1] %>.<%= split_net[0] %>
\$TTL 300
@                       IN      SOA     <%=domain.hostip%>. nobody.example.com. (
                                        <%= Time.now.to_i %>   ; Serial
                                        600         ; Refresh
                                        1800         ; Retry
                                        604800       ; Expire
                                        300          ; TTL
                                        )

                        IN      NS      <%= domain.hostip %>.

<% groups.each do |group| -%>
<% group.nodes.each do |node| -%>
<% node.networks.each do |name, network| -%>
<% if (network.defined rescue false) -%>
<% if network.network.to_s == net.network.to_s -%>
<% ip_split = network.ip.split(/\./) -%>
<%= ip_split[3] %>.<%= ip_split[2] %> IN PTR <%= node.node.name %>.<%= name %>.<%= config.domain %>.;
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

<%= domain.hostip %>  deploy.pri.<%= config.domain %> deploy.<%= config.domain %> deploy
EOF

# Backup /etc/resolv.conf (overwrite in future once testing works)
mv -f /etc/resolv.conf /etc/resolv.conf
cat << EOF > /etc/resolv.conf
search <% config.networks.each do |zone, net| -%><%= zone %>.<%= config.domain %> <% end %>
nameserver <%= domain.hostip %>
EOF

