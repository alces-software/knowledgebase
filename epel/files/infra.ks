#!/bin/bash
#(c)2017 Alces Software Ltd. HPC Consulting Build Suite
#Job ID: <JOB>
#Cluster: <CLUSTER>

#MISC
text
reboot
skipx
install

#SECURITY
firewall --enabled
firstboot --disable
selinux --disabled

#AUTH
auth  --useshadow  --enablemd5
rootpw --iscrypted "${_ALCES_ROOTPASSWORDCRYPT}" 

#LOCALIZATION
keyboard uk
lang en_GB
timezone  Europe/London

#REPOS
#url --url=http://${_ALCES_BUILDSERVER}/${_ALCES_CLUSTER}/repo/centos/
url --url=http://mirror.ox.ac.uk/sites/mirror.centos.org/7/os/x86_64/

#DISK
%include /tmp/disk.part

#PRESCRIPT
%pre
set -x -v
exec 1>/tmp/ks-pre.log 2>&1

DISKFILE=/tmp/disk.part
disk1="sda"
bootloaderappend="console=tty0 console=ttyS1,115200n8"
cat > $DISKFILE << EOF
zerombr
bootloader --location=mbr --driveorder=$disk1 --append="$bootloaderappend"
clearpart --all --initlabel

#Disk partitioning information
part /boot --fstype ext4 --size=4096 --asprimary --ondisk $disk1
part pv.01 --size=1 --grow --asprimary --ondisk $disk1
volgroup system pv.01
logvol  /  --fstype ext4 --vgname=system  --size=32786 --name=root
logvol  /var --fstype ext4 --vgname=system --size=32768 --name=var --grow
logvol  /tmp --fstype ext4 --vgname=system --size=16384 --name=tmp
logvol  swap  --fstype swap --vgname=system  --size=16384  --name=swap1
EOF
%end

#PACKAGES
%packages --ignoremissing

vim
emacs
xauth
xhost
xdpyinfo
xterm
xclock
tigervnc-server
ntpdate
#Required for cobbler completion
#For cobbler postscripts
wget
vconfig
bridge-utils
patch
tcl-devel
gettext

%end

#POSTSCRIPTS
%post --nochroot
set -x -v
exec 1>/mnt/sysimage/root/ks-post-nochroot.log 2>&1

ntpdate 0.centos.pool.ntp.org

%end
%post
set -x -v
exec 1>/root/ks-post.log 2>&1

export MASTERIP=${_ALCES_BUILDSERVER}

export SCRIPTURL=http://${MASTERIP}/epel/scripts/

curl http://${MASTERIP}/epel/conf/config > /root/.alcesconf
curl ${SCRIPTURL}/install/base.sh | bash -x
curl ${SCRIPTURL}/install/infiniband.sh | bash -x
curl ${SCRIPTURL}/install/nisclient.sh | bash -x
curl ${SCRIPTURL}/install/nfsclient.sh | bash -x
curl ${SCRIPTURL}/install/gangliaclient.sh | bash -x
curl ${SCRIPTURL}/install/postfixclient.sh | bash -x


%end
