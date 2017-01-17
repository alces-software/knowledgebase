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
logvol  /  --fstype ext4 --vgname=rootvg  --size=16384 --name=root
logvol  /var --fstype ext4 --vgname=rootvg --size=16384 --name=var
logvol  /tmp --fstype ext4 --vgname=rootvg --size=8096 --name=tmp
logvol  swap  --fstype swap --vgname=rootvg  --size=32768  --name=swap1
logvol /scratch --fstype ext4 --vgname=rootvg --size=262144 --name=scratch
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

curl http://<MASTERIP>/<CLUSTER>/scripts/base.sh | bash -x
curl http://<MASTERIP>/<CLUSTER>/scripts/lustreclient.sh | bash -x
curl http://<MASTERIP>/<CLUSTER>/scripts/nfsclient.sh | bash -x
curl http://<MASTERIP>/<CLUSTER>/scripts/nisclient.sh | bash -x

if (lsmod | grep -q mlx4_core); then
  #install infiniband extras
  yum -e 0 -y -x compat-openmpi -x compat-openmpi-psm install @infiniband infiniband-diags
  #Force set all ports to infiniband type (not ethernet)
  cat << "EOF" > /etc/modprobe.d/alces-mlx4.conf
options mlx4_core log_mtts_per_seg=4 port_type_array=1,1
EOF
  if ( [ -e /usr/bin/systemctl ] ); then
    systemctl enable rdma
  else
    chkconfig rdma on
  fi
  #Name host on fabric
  echo "for dev in `ls -d /sys/class/infiniband/mlx4_*` ; do echo `hostname -s` > $dev/node_desc; done" >> /etc/rc.local
  #Set card modes to IB
  lspci | grep "Network controller: Mellanox Technologies" | cut -d ' ' -f 1 | while read l; do echo $l ib ib >> /etc/rdma/mlx4.conf; done
  #auto load the modules
  cat << EOF > /etc/modules-load.d/alces-mlx4.conf
mlx4_core
mlx4_ib
EOF
fi

#QLogic/Intel infiniband tweaks
if (lsmod | grep -q ib_qib); then
  #install infiniband pkgs
  yum -e 0 -y -x compat-openmpi -x compat-openmpi-psm install @infiniband infinipath-psm-devel infinipath-psm kernel-devel infiniband-diags
  if ( [ -e /usr/bin/systemctl ] ); then
    systemctl enable rdma
  else
    chkconfig rdma on
  fi
  #Name host on fabric
  echo "for dev in `ls -d /sys/class/infiniband/qib*` ; do echo `hostname -s` > $dev/node_desc; done" >> /etc/rc.local
fi

cat << EOF > /etc/security/limits.d/99-alcesinfiniband.conf
#RDMA needs to work with pinned memory, i.e. memory which cannot be swapped out by the kernel.
#By default, every process that is running as a non-root user is allowed to pin a low amount of memory (64KB).
#In order to work properly as a non-root user, it is highly recommended to increase the size of memory which
#can be locked
* soft memlock unlimited
* hard memlock unlimited
EOF
#Don't stop ib drivers if lustre module is loaded (causes hang on shutdown)
if [ -f /etc/init.d/rdma ]; then
yum -e 0 -y install patch
patch -p0 << 'EOD'
--- /etc/init.d/rdma    2015-03-04 15:19:11.691026292 +0000
+++ /etc/init.d/rdma.lustrepatch        2015-03-04 15:18:15.069852927 +0000
@@ -316,6 +316,14 @@
        return 1
     fi

+    if is_module ko2iblnd; then
+      echo "Lustre modules are still enabled."
+      if ( mount | grep -q "type lustre" ); then
+        echo "Lustre is still mounted - attempting unmount."
+        echo "Please stop lustre and remove modules before stopping the rdma service."
+        /bin/umount -a -f -t lustre
+      fi
+      /usr/sbin/lustre_rmmod
+      sleep 20
+      return 0
+    fi
+
     if ! is_module ib_core; then
        # Nothing to do, make sure lock file is gone and return
        rm -f /var/lock/subsys/rdma
EOD
fi

systemctl disable firewalld

%end
