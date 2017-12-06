#!/bin/bash
<% if ipaconfig.serverip != networks.pri.ip.to_s -%>

# Variables
REALM="<%= networks.pri.domain.upcase %>.<%= domain.upcase %>"

# Update resolv.conf
cat << EOF > /etc/resolv.conf
search <%= search_domains %>
nameserver <%= ipaconfig.serverip %>
EOF

# Install packages
yum -y install ipa-client ipa-admintools

# Enroll host (using firstrun script)
cat << EOF > /var/lib/firstrun/scripts/ipaenroll.bash
ipa-client-install --no-ntp --mkhomedir --no-ssh --no-sshd --force-join --realm="$REALM" --server="<%= ipaconfig.servername %>.<%= networks.pri.domain %>.<%= domain %>" -w "<%= ipaconfig.insecurepassword %>" --domain="<%= networks.pri.domain %>.<%=domain %>" --unattended --hostname='<%= networks.pri.hostname %>'
EOF
<% end -%>
