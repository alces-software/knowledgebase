
# Disable SELinux
sed -i 's/SELINUX=.*/SELINUX=disabled/g' /etc/selinux/config
setenforce 0

# Disable/stop cloud-init
systemctl stop cloud-init
systemctl disable cloud-init

# Preserve hostname
echo 'preserve_hostname: true' > /etc/cloud/cloud.cfg.d/hostname.cfg
