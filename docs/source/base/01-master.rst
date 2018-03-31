.. _01-master:

Master Node Setup
=================

Manual Setup
------------

- Run a minimal CentOS installation on the system; this can be performed manually or via an automated install service if you have one already setup
- It is recommended to update the packages on the system for any bug fixes and patches that may have been introduced to core packages::

    yum -y update

.. note:: If using kickstart OS installation on many nodes it is worth considering a :ref:`local mirror repository <deploy-repo>` for the OS image and packages so that all nodes receive an equivalent software installation, and aren't trying to connect to the internet at the same time.

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

.. note:: The external interface may require getting it's network settings over DHCP; if so then set ``BOOTPROTO`` to ``dhcp`` instead of static and remove the ``IPADDR`` lines.

- Setup config file for network interfaces (do this for all interfaces sitting on the bridges configured above)::

    TYPE=Ethernet
    BOOTPROTO=none
    NAME=p1p1
    DEVICE=p1p1
    ONBOOT=“yes”
    BRIDGE=pri

.. note:: In the above example, the interface ``p1p1`` is connected to the primary network but instead of giving that an IP it is set to use the ``pri`` bridge

- Enable and start firewalld to allow masquerading client machines via the external interface and to improve general network security::

    systemctl enable firewalld
    systemctl start firewalld

- Add ``ext`` bridge to external zone; the external zone is a zone configured as part of firewalld::

    firewall-cmd --add-interface ext --zone external --permanent

- Add all the other network interfaces to the trusted zone; replace ``pri`` with the other network names, excluding ``ext``::

    firewall-cmd --add-interface pri --zone trusted --permanent

- Reboot the system 

- Install components for VM service::

    yum groupinstall -y virtualization-platform virtualization-tools 
    yum install -y virt-viewer virt-install

- Enable and start the virtualisation service::

    systemctl start libvirtd
    systemctl enable libvirtd

- Create VM pool::

    mkdir /opt/vm
    virsh pool-define-as local dir - - - - "/opt/vm/"
    virsh pool-build local
    virsh pool-start local
    virsh pool-autostart local

Automated Setup
---------------

If using metalware, a controller can be used to deploy it's own master. By setting up the controller on a separate machine to the master, the master can then be defined and hunted (see :ref:`Deployment Example <deployment-kickstart>` for hunting instructions). The following will add the build config and scripts to configure a functional master (much like the above).

.. note:: In the following guide the group is called ``masters`` and the master node is ``master1``

- Configure certificate authority for libvirt from the controller as described in :ref:`VM Deployment from the Controller <vm-deployment>`

- Create a deployment file for the master node (``/var/lib/metalware/repo/config/master1.yaml``) containing the following (the network setup configures network bridges and the external interface)::

    files:
      setup:
        - /opt/alces/install/scripts/10-vm_master.sh
      core:
        - /opt/alces/ca_setup/master1-key.pem
        - /opt/alces/ca_setup/master1-cert.pem
    networks:
      pri:
        interface: pri
        type: Bridge
        slave_interfaces: em1
      mgt:
        interface: mgt
        type: Bridge
        slave_interfaces: em2
      ext:
        defined: true
        domain: ext
        ip: 10.101.100.99
        network: 10.101.0.0
        netmask: 255.255.0.0
        gateway: 10.101.0.1
        short_hostname: <%= node.name %>.<%= config.networks.ext.domain %>
        interface: ext
        firewallpolicy: external
        slave_interfaces: p1p4

.. note:: If additional scripts are defined in the domain level ``setup`` and ``core`` lists then be sure to include them in the master1 file

- Additionally, download the VM master script to ``/opt/alces/install/scripts/10-vm_master.sh``::

    mkdir -p /opt/alces/install/scripts/
    cd /opt/alces/install/scripts/
    wget -O 10-vm_master.sh https://raw.githubusercontent.com/alces-software/knowledgebase/master/epel/7/libvirt/vm_master.sh
