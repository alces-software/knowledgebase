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
rootpw --iscrypted $6$sVWLjXgUfeZhT08d$3d/GlurC7Hcr5lHIuhUAPazCT/rIrbabLRwMCe3zUvaBTH/HZNU2RBHWuzQRVUNMCUybA8r1Z09/P/d5x9XU41

#LOCALIZATION
keyboard uk
lang en_GB
timezone  Europe/London

#REPOS
url --url=http://<MASTERIP>/<CLUSTER>/repos/centos/

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
part /boot --fstype ext4 --size=1024 --asprimary --ondisk $disk1
part pv.01 --size=1 --grow --asprimary --ondisk $disk1
volgroup rootvg pv.01
logvol  /  --fstype ext4 --vgname=rootvg  --size=8096 --name=root
logvol  /var --fstype ext4 --vgname=rootvg --size=8096 --name=var
logvol  /tmp --fstype ext4 --vgname=rootvg --size=2048 --name=tmp
logvol  swap  --fstype swap --vgname=rootvg  --size=32768  --name=swap1
logvol /scratch --fstype ext4 --vgname=rootvg --size=1 --grow --name=scratch
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

export BASE_HOSTNAME=`hostname -s | sed -e 's/e$//g'`
export PROFILE=SLAVE

export MASTERIP=<MASTERIP>

export INSTALLURL=http://${MASTERIP}/epel/scripts/install/

curl ${INSTALLURL}/base.sh | bash -x
curl ${INSTALLURL}/lustreclient.sh | bash -x
curl ${INSTALLURL}/nfsclient.sh | bash -x
curl ${INSTALLURL}/nisclient.sh | bash -x
curl ${INSTALLURL}/sgeclient.sh | bash -x

%end
