.. _deployment-guidelines:

Recommendations for Software and Application Deployment
=======================================================


Master Node Setup
-----------------

- Install CentOS using kickstart file (original available from Julius)
- Install additional utilities::

    yum -y install yum-plugin-priorities yum-utils
    yum -y install net-tools bind-utils ipmitool

- It is recommended to update the packages on the system for any bug fixes and patches that may have been introduced to core packages::

    yum -y update

.. note:: If kickstarting OS installs on many nodes it is worth considering a local mirror repository for OS packages so that all nodes aren't trying to connect to the internet at the same time.

- If the system was deisable build interface

- Configure external network interface::

    TYPE=Ethernet
    BOOTPROTO=dhcp
    DEFROUTE=yes
    PEERDNS=no
    PEERROUTES=no
    IPV4_FAILURE_FATAL=no
    NAME=em2
    UUID=8c303d86-a403-4893-9c13-47def96def03
    DEVICE=em2
    ONBOOT=yes

- Disable and stop NetworkManager::

    systemctl disable NetworkManager
    systemctl stop NetworkManager

- Set the hostname::

    echo ‘master.cluster.local’ > /etc/hostname

- Configure bridge interface for primary network (`/etc/sysconfig/network-scripts/ifcfg-pri`)::

    DEVICE=pri
    ONBOOT=yes
    TYPE=Bridge
    stp=no
    BOOTPROTO=static
    IPADDR=10.10.0.11
    NETMASK=255.255.0.0
    ZONE=trusted
    PEERDNS=no

- Create mgt and ext mirror of above (use 10.11. for mgt)

- Setup GBe network ifcfg files (for management, primary and external ports)::

    TYPE=Ethernet
    BOOTPROTO=none
    NAME=p1p1
    DEVICE=p1p1
    ONBOOT=“yes”
    BRIDGE=pri

- Enable and start firewalld (for ext bridge masquerading)::

    systemctl enable firewalld
    systemctl start firewalld

- Add ext to external zone (the external zone is a zone configured as part of firewalld)::

    firewall-cmd --add-interface ext --zone external --permanent

- Add all the other network interfaces to the trusted zone::

    firewall-cmd --add-interface int --zone trusted --permanent

- Reboot the system 

- Install components for VM service::

    yum groupinstall -y virtualization-platform virtualization-tools 
    yum install -y python-virtinst virt-viewer

- Enable and start the virtualisation service::

    systemctl start libvirtd
    systemctl enable libvirtd

- Create VM pool::

    mkdir /opt/vm
    virsh pool-define-as local dir - - - - "/opt/vm/"
    virsh pool-build local
    virsh pool-start local
    virsh pool-autostart local

- Create /opt/vm/master.xml (see master.xml below)
- Create base image::

    scp julius.dmz:/opt/vm/centos7.0-symphonybase.qcow2 /opt/vm/
    cp centos7.0 master.qcow
    virsh define master.xml
    virsh start master
    virt-viewer master (to view booting)

**Master.xml**

.. code-block:: xml

    <domain type='kvm' id='2'>
      <name>master</name>
      <memory unit='KiB'>4194304</memory>
      <currentMemory unit='KiB'>4194304</currentMemory>
      <vcpu placement='static'>2</vcpu>
      <resource>
        <partition>/machine</partition>
      </resource>
      <os>
        <type arch='x86_64' machine='rhel6.4.0'>hvm</type>
      </os>
      <features>
        <acpi/>
        <apic/>
        <pae/>
      </features>
      <clock offset='utc'/>
      <on_poweroff>destroy</on_poweroff>
      <on_reboot>restart</on_reboot>
      <on_crash>restart</on_crash>
      <devices>
        <emulator>/usr/libexec/qemu-kvm</emulator>
        <disk type='file' device='disk'>
          <driver name='qemu' type='qcow2'/>
          <source file='/opt/vm/master.qcow2'/>
          <target dev='vda' bus='virtio'/>
          <boot order='2'/>
          <alias name='virtio-disk0'/>
        </disk>
        <controller type='usb' index='0'>
          <alias name='usb0'/>
        </controller>
        <controller type='pci' index='0' model='pci-root'>
          <alias name='pci.0'/>
        </controller>
        <interface type='bridge'>
          <source bridge='pri'/>
          <target dev='vnet0'/>
          <model type='virtio'/>
          <alias name='net0'/>
        </interface>
        <interface type='bridge'>
          <source bridge='mgt'/>
          <target dev='vnet1'/>
          <model type='virtio'/>
          <boot order='1'/>
          <alias name='net1'/>
        </interface>
        <interface type='bridge'>
          <source bridge='ext'/>
          <target dev='vnet2'/>
          <model type='virtio'/>
        </interface>
        <serial type='pty'>
          <source path='/dev/pts/0'/>
          <target port='0'/>
          <alias name='serial0'/>
        </serial>
        <console type='pty' tty='/dev/pts/0'>
          <source path='/dev/pts/0'/>
          <target type='serial' port='0'/>
          <alias name='serial0'/>
        </console>
        <input type='mouse' bus='ps2'/>
        <input type='keyboard' bus='ps2'/>
        <graphics type='vnc' port='5900' autoport='yes' listen='127.0.0.1'>
          <listen type='address' address='127.0.0.1'/>
        </graphics>
        <video>
          <model type='cirrus' vram='16384' heads='1'/>
          <alias name='video0'/>
          <address type='pci' domain='0x0000' bus='0x00' slot='0x02' function='0x0'/>
        </video>
        <memballoon model='virtio'>
          <alias name='balloon0'/>
          <address type='pci' domain='0x0000' bus='0x00' slot='0x08' function='0x0'/>
        </memballoon>
      </devices>
      <seclabel type='none' model='none'/>
    </domain>

