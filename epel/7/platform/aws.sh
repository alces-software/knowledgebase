
# Disable SELinux
sed -i 's/SELINUX=.*/SELINUX=disabled/g' /etc/selinux/config
setenforce 0

# Disable/stop cloud-init
systemctl stop cloud-init
systemctl disable cloud-init

# Allow creation of NIS home directory
authconfig --enablemkhomedir --update

# Preserve hostname
echo 'preserve_hostname: true' > /etc/cloud/cloud.cfg.d/hostname.cfg
