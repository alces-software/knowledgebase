.. _deployment-guidelines:

Recommendations for Software and Application Deployment
=======================================================

In this section the recommended CentOS 7 configuration for the master node system (as a virtualisation host for other services) is described. 

Master Node Setup
-----------------

- Run a minimal CentOS installation on the system (this can be performed manually or via an automated install service if you have one setup)
- It is recommended to update the packages on the system for any bug fixes and patches that may have been introduced to core packages::

    yum -y update

.. note:: If kickstarting OS installs on many nodes it is worth considering a local mirror repository for the OS image and packages so that all nodes aren't trying to connect to the internet at the same time.

- Disable and stop NetworkManager::

    systemctl disable NetworkManager
    systemctl stop NetworkManager

- Set the hostname::

    echo ‘master.cluster.local’ > /etc/hostname

- Configure bridge interface for primary network (``/etc/sysconfig/network-scripts/ifcfg-pri``)::

    DEVICE=pri
    ONBOOT=yes
    TYPE=Bridge
    stp=no
    BOOTPROTO=static
    IPADDR=10.10.0.11
    NETMASK=255.255.0.0
    ZONE=trusted
    PEERDNS=no

.. note:: Replace ``DEVICE``, ``IPADDR`` and ``NETMASK`` with the appropriate values for your system

- Create bridge interfaces for all other networks (e.g. management [``mgt``] and external [``ext``])

- Setup config file for network interfaces (do this for all interfaces sitting on the bridges configured above)::

    TYPE=Ethernet
    BOOTPROTO=none
    NAME=p1p1
    DEVICE=p1p1
    ONBOOT=“yes”
    BRIDGE=pri

.. note:: In the above example, the interface ``p1p1`` is connected to the primary network but instead of giving that an IP it is set to use the ``pri`` bridge

- Enable and start firewalld (for masquerading IPs to the external interface and improving the general network security)::

    systemctl enable firewalld
    systemctl start firewalld

- Add ``ext`` bridge to external zone (the external zone is a zone configured as part of firewalld)::

    firewall-cmd --add-interface ext --zone external --permanent

- Add all the other network interfaces to the trusted zone (replace ``pri`` with the other network names, excluding ``ext``)::

    firewall-cmd --add-interface pri --zone trusted --permanent

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

- Create ``/opt/vm/master.xml`` for provisioning a VM called master (:download:`Available here <master.xml>`)

  - This template creates 3 interfaces on the VM (on the primary, management and external networks)

- Create base qcow2 image ``master.qcow2``
- Create the VM::

    virsh define master.xml

- Start the VM::

    virsh start master

- Connect a VNC-like window to the VM to watch it booting and interact with the terminal::

    virt-viewer master

