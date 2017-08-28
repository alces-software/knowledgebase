<% if nvidia -%>
sed -i "s/GRUB_CMDLINE_LINUX=\"\(.*\)\"/GRUB_CMDLINE_LINUX=\"\1 rdblacklist=nouveau blacklist=nouveau\"/" /etc/default/grub
grub2-mkconfig > /etc/grub2.cfg
mkinitrd --force /boot/initramfs-`uname -r`.img `uname -r`
echo "blacklist nouveau" >> /etc/modprobe.d/blacklist.conf

rmmod -v nouveau

yum -y groupinstall "Development Tools"

mkdir -p /var/lib/firstrun/scripts/
cat << EOF > /var/lib/firstrun/scripts/nvidia.bash
URL=http://<%= alces.hostip %>/installers/
curl \$URL/nvidia.run > /tmp/nvidia.run
sh /tmp/nvidia.run -a -q -s --kernel-source-path /usr/src/kernels/*
EOF
<% end -%>
