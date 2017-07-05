<% if nvidia -%>
sed -i "s/GRUB_CMDLINE_LINUX=\"\(.*\)\"/GRUB_CMDLINE_LINUX=\"\1 rdblacklist=nouveau blacklist=nouveau\"/" /etc/sysconfig/grub
grub2-mkconfig > /etc/grub2.cfg
mkinitrd --force /boot/initramfs-`uname -r`.img `uname -r`
echo "blacklist nouveau" >> /etc/modprobe.d/blacklist.conf

rmmod -v nouveau

URL="http://<%=repoconfig.reposerver%>/installers"

curl $URL/nvidia.run > /tmp/nvidia.run

yum -y groupinstall "Development Tools"
sh /tmp/nvidia.run -a -q -s
<% end -%>
