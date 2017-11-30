#!/bin/bash

# Variables
REALM="<%= networks.pri.domain.upcase %>.<%= domain.upcase %>"
SERVICES="ldap ldaps kerberos kpasswd <%= firewall.internal.services %>"
CONTROLLER_HOSTNAME="controller"
CONTROLLER_IP="10.10.0.1"
CONTROLLER_IP_REVERSE="1.0"

# Install packages
yum -y install ipa-server bind bind-dyndb-ldap ipa-server-dns

# Firewall setup
for service in $SERVICES ; do
    firewall-cmd --add-service $service --zone <%= networks.pri.firewallpolicy %> --permanent
done

firewall-cmd --reload

echo -n "Secure Admin Password:"
read PASSWORD

# Server setup
ipa-server-install -a $PASSWORD --hostname <%= networks.pri.hostname %> --ip-address=<%= networks.pri.ip %> -r "$REALM" -p $PASSWORD -n "<%= networks.pri.domain %>.<%= domain %>" --no-ntp --setup-dns --forwarder='<%= internaldns %>' --reverse-zone='<%= networks.pri.named_rev_zone %>.in-addr.arpa.' --ssh-trust-dns --unattended

# Auth
kinit admin

# Add controller DNS entry
ipa dnsrecord-add <%= networks.pri.domain %>.<%= domain %> $CONTROLLER_HOSTNAME --a-ip-address=$CONTROLLER_IP
ipa dnsrecord-add <%= networks.pri.named_rev_zone %>.in-addr.arpa. $CONTROLLER_IP_REVERSE --ptr-hostname $CONTROLLER_HOSTNAME.<%= networks.pri.domain %>.<%= domain %>

# Add mail entry
ipa dnsrecord-add <%= networks.pri.domain %>.<%= domain %> @ --mx-preference=0 --mx-exchanger=$CONTROLLER_HOSTNAME

# Add user config (home dir, shell, groups)
ipa config-mod --defaultshell /bin/bash
ipa config-mod --homedirectory <%= ipaconfig.userdir %>
ipa group-add ClusterUsers --desc="Generic Cluster Users"
ipa group-add AdminUsers --desc="Admin Cluster Users"
ipa config-mod --defaultgroup ClusterUsers
ipa pwpolicy-mod --maxlife=999

# Host groups
ipa hostgroup-add usernodes --desc "All nodes allowing standard user access"
ipa hostgroup-add adminnodes --desc "All nodes allowing only admin user access"

# Add alces user
ipa user-add alces-cluster --first Alces --last Software --random
ipa group-add-member AdminUsers --users alces-cluster
echo "ALCES USER PASSWORD"
ipa user-mod alces-cluster --password # Sets user password through prompts

# Access rules
ipa hbacrule-disable allow_all
ipa hbacrule-add adminaccess --desc "Allow admin access to admin hosts"
ipa hbacrule-add useraccess --desc "Allow user access to user hosts"
ipa hbacrule-add-service adminaccess --hbacsvcs sshd
ipa hbacrule-add-service useraccess --hbacsvcs sshd
ipa hbacrule-add-user adminaccess --groups AdminUsers
ipa hbacrule-add-user useraccess --groups ClusterUsers
ipa hbacrule-add-host adminaccess --hostgroups adminnodes
ipa hbacrule-add-host useraccess --hostgroups usernodes

# Sudo rules
ipa sudorule-add --cmdcat=all All
ipa sudorule-add-user --groups=adminusers All
ipa sudorule-mod All --hostcat='all'
ipa sudorule-add-option All --sudooption '!authenticate'

#Site stuff
ipa user-add siteadmin --first Site --last Admin --random
ipa group-add siteadmins --desc="Site admin users (power users)"
ipa hostgroup-add sitenodes --desc "All nodes allowing site admin access"
ipa group-add-member siteadmins --users siteadmin
ipa hbacrule-add siteaccess --desc "Allow siteadmins access to site hosts"
ipa hbacrule-add-service siteaccess --hbacsvcs sshd
ipa hbacrule-add-user adminaccess --groups siteadmins
ipa hbacrule-add-host adminaccess --hostgroups sitenodes

ipa sudorule-add --cmdcat=all Site
ipa sudorule-add-user --groups=siteadmins Site
ipa sudorule-mod Site --hostcat=''
ipa sudorule-add-option Site --sudooption '!authenticate'
ipa sudorule-add-host Site --hostgroups=sitenodes

# Add all hosts to IPA (disables and resets password as precaution)
<% alces.groups do |group| -%>
<%     group.nodes do |node| -%>
ipa host-add <%= node.networks.pri.hostname %> --password="<%= node.ipaconfig.insecurepassword %>" --ip-address=<%= node.networks.pri.ip %>
ipa host-disable <%= node.alces.nodename %>
ipa host-mod <%= node.alces.nodename %> --password="<%= node.ipaconfig.                 insecurepassword %>"
<%     end -%>
<% end -%>

# Update name resolution
cat << EOF > /etc/resolv.conf
search <%= search_domains %>
nameserver <%= networks.pri.ip %>
EOF

# Reboot
echo "It is recommended to reboot the system now that IPA has been configured"
