yum -y --enablerepo epel install nagios-nrpe nagios-plugins nagios-plugins-{load,ping,disk,http,procs,users,ssh,swap,procs}
<% if nagios.is_server then -%>
yum -y --enablerepo epel install nagios

# setup config file
sed -i -e 's/bare_update_check.*/bare_update_check=1/g' \
-e 's/enable_notifications.*/enable_notifications=0/g' \
-e 's/date_format.*/date_format=euro/g' \
-e 's/enable_environment_macros.*/enable_environment_macros=1/g' /etc/nagios/nagios.cfg

# setup hosts
HOSTS=`cat << EOF
<% alces.genders.domain.each do |node| %>
define host{
    use                     linux-server
    host_name               <%= node %>
    alias                   <%= node %>
    }
<% end %>
define hostgroup{
    hostgroup_name          domain-servers
    alias                   Domain Servers
    members                 <% alces.genders.domain.each do |node| %><%= node %>,<% end %>
    }
define service{
    use                     local-service
    hostgroup_name          domain-servers
    service_description     PING
    check_command           check_ping!100.0,20%!500.0,60%
    }
define service{
    use                     local-service
    hostgroup_name          domain-servers
    service_description     Root Partition
    check_command           check_local_disk!20%!10%!/
    }
define service{
    use                     local-service
    hostgroup_name          domain-servers
    service_description     Current Users
    check_command           check_local_users!20!50
    }
define service{
    use                     local-service
    hostgroup_name          domain-servers
    service_description     Total Processes
    check_command           check_local_procs!250!400!RSZDT
    }
define service{
    use                     local-service
    hostgroup_name          domain-servers
    service_description     Current Load
    check_command           check_local_load!5.0,4.0,3.0!10.0,6.0,4.0
    }
define service{
    use                     local-service
    hostgroup_name          domain-servers
    service_description     Swap Usage
    check_command           check_local_swap!20!10
    }
define service{
    use                     local-service
    hostgroup_name          domain-servers
    service_description     SSH
    check_command           check_ssh
    notifications_enabled   0
    }
define service{
    use                     local-service
    hostgroup_name          domain-servers
    service_description     HTTP
    check_command           check_http
    notifications_enabled   0
    }

EOF`

echo "$HOSTS" > /etc/nagios/conf.d/domain.cfg

systemctl enable nagios
systemctl restart httpd nagios
<% end %>

systemctl enable nrpe
systemctl restart nrpe
