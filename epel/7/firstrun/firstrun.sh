mkdir -p /var/lib/firstrun/
mkdir -p /var/log/firstrun/

cat << EOF > /var/lib/firstrun/bin/firstrun
#!/bin/bash
function fr {
  echo "-------------------------------------------------------------------------------"
  echo "Symphony deployment Suite - Copyright (c) 2008-2017 Alces Software Ltd"
  echo "-------------------------------------------------------------------------------"
  echo "Running Firstrun scripts.."
  if [ -f /var/lib/firstrun/RUN ]; then
    for script in \`find /var/lib/firstrun/scripts -type f -iname *.bash\`; do 
      echo "Running \\$script.." >> /root/symphony-firstrun.log 2>&1
      /bin/bash \\$script >> /root/symphony-firstrun.log 2>&1
    done
    rm -f /var/lib/firstrun/RUN
  fi
  echo "Done!"
  echo "-------------------------------------------------------------------------------"
}
trap fr EXIT
EOF

cat << EOF > /var/lib/firstrun/bin/firstrun-stop
#!/bin/bash
/bin/systemctl disable symphony-firstrun.service
if [ -f /firstrun.reboot ]; then
  echo -n "Reboot flag set.. Rebooting.."
  rm -f /firstrun.rebooot
  shutdown -r now
fi
EOF

cat << EOF >> /etc/systemd/system/firstrun.service
[Unit]
Description=FirstRun service
After=network.target remote-fs.target
Before=display-manager.service getty@tty1.service

[Service]
ExecStart=/bin/bash /var/lib/firstrun/bin/firstrun
Type=oneshot
ExecStartPost=/bin/bash /var/lib/firstrun/bin/firstrun-stop
SysVStartPriority=99
TimeoutSec=0
RemainAfterExit=yes

[Install]
WantedBy=multi-user.target
EOF

chmod 664 /etc/systemd/system/firstrun.service
systemctl daemon-reload
systemctl enable firstrun.service
