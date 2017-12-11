yum install -y rsyslog

<% if config.networks.pri.ip == domain.hostip -%>
cat << EOF > /etc/rsyslog.d/metalware.conf
\$template remoteMessage, "/var/log/slave/%FROMHOST%/messages.log"
:fromhost-ip, !isequal, "127.0.0.1" ?remoteMessage
& ~
EOF

sed -i -e "s/^#\$ModLoad imudp.*$/\$ModLoad imudp/g" /etc/rsyslog.conf
sed -i -e "s/^#\$UDPServerRun 514.*$/\$UDPServerRun 514/g" /etc/rsyslog.conf
sed -i -e "s/^#\$ModLoad imtcp.*$/\$ModLoad imtcp/g" /etc/rsyslog.conf
sed -i -e "s/^#\$InputTCPServerRun 514.*$/\$InputTCPServerRun 514/g" /etc/rsyslog.conf

cat << EOF > /etc/logrotate.d/rsyslog-remote
/var/log/slave/*/*.log {
    sharedscripts
    compress
    rotate 2
    postrotate
        /bin/kill -HUP \`cat /var/run/syslogd.pid 2> /dev/null\` 2> /dev/null || true
        /bin/kill -HUP \`cat /var/run/rsyslogd.pid 2> /dev/null\` 2> /dev/null || true
    endscript
}
EOF
<% else -%>
echo '*.* @<%= domain.hostip %>:514' >> /etc/rsyslog.conf
<% end -%>

systemctl enable rsyslog
systemctl restart rsyslog
