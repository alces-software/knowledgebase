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

Deployment VM Setup
-------------------

OS Configuration
^^^^^^^^^^^^^^^^

- Create ``/opt/vm/deploy.xml`` for provisioning a VM called deploy (:download:`Available here <deploy.xml>`)

  - This template creates 3 interfaces on the VM (on the primary, management and external networks)

- Create base qcow2 image ``deploy.qcow2``::

    qemu-img create -f qcow2 deploy.qcow2 80G

- Create the VM::

    virsh define deploy.xml

- Start the VM::

    virsh start deploy

- Connect a VNC-like window to the VM to watch it booting and interact with the terminal::

    virt-viewer deploy

.. note:: Much like the host system, a minimal installation of CentOS 7 is recommended (as is ensuring that the system is up-to-date with ``yum -y update``)

- Set the hostname of the system (the fully-qualified domain name for this system has additionally added the cluster name)::

    echo 'deploy.testcluster.cluster.local' > /etc/hostname

- Setup the network interfaces

  - Eth0 is bridged onto the primary network - set a static IP for that network in ``/etc/sysconfig/network-scripts/ifcfg-eth0`` 
  - Eth1 is bridged onto the management network - set a static IP for that network in ``/etc/sysconfig/network-scripts/ifcfg-eth1`` 
  - Eth2 is bridged onto the external network - this will most likely use DHCP to obtain an IP address ``/etc/sysconfig/network-scripts/ifcfg-eth2`` 
  
  .. note:: Add ``ZONE=trusted`` to eth0 & eth1, ``ZONE=external`` to eth2 to ensure the correct firewall zones are used by the interfaces.

- Enable and start firewalld::

    systemctl enable firewalld
    systemctl start firewalld

- Add the interfaces to the relevant firewall zones::

    firewall-cmd --add-interface eth0 --zone trusted --permanent
    firewall-cmd --add-interface eth1 --zone trusted --permanent
    firewall-cmd --add-interface eth2 --zone external --permanent
  
- Disable network manager::

    systemctl disable NetworkManager
    
- Reboot the VM

- Once the VM is back up it should be able to ping both the primary and management interfaces on the master node. If the ping returns properly then metalware can be configured to enable deployment capabilities on the VM.

Metalware Install
^^^^^^^^^^^^^^^^^

- Run metalware installer::

    curl -sL http://git.io/metalware-installer | sudo alces_OS=el7 alces_SOURCE_BRANCH=release/2.0.0 /bin/bash

- Install dependencies for TFTP and DHCP:: 

    yum -y install dhcp fence-agents tftp xinetd tftp-server syslinux syslinux-tftpboot httpd php

- Enable the TFTP server::

    sed -ie "s/^.*disable.*$/\    disable = no/g" /etc/xinetd.d/tftp
    systemctl enable xinetd
    systemctl enable dnsmasq
    systemctl enable dhcpd

- Setup TFTP directory with boot files and default PXE file::

    PXE_BOOT=/var/lib/tftpboot/boot
    mkdir -p "$PXE_BOOT"
    curl http://mirror.ox.ac.uk/sites/mirror.centos.org/7/os/x86_64/images/pxeboot/initrd.img > "$PXE_BOOT/centos7-initrd.img"
    curl http://mirror.ox.ac.uk/sites/mirror.centos.org/7/os/x86_64/images/pxeboot/vmlinuz > "$PXE_BOOT/centos7-kernel"
    mkdir -p /var/lib/tftpboot/pxelinux.cfg/
    cat << EOF > /var/lib/tftpboot/pxelinux.cfg/default
    DEFAULT menu
    PROMPT 0
    MENU TITLE PXE Menu
    TIMEOUT 100
    TOTALTIMEOUT 1000
    ONTIMEOUT local

    LABEL local
         MENU LABEL (local)
         MENU DEFAULT
         LOCALBOOT 0
    EOF
 
- Reboot the VM

- Set metalware to use default repository::

    metal repo use https://github.com/alces-software/metalware-default.git

- Populate hostfile with slave nodes (the nodelist can be viewed with ``nodeattr -g nodes``)::

    metal hosts -g nodes

- Create an SSH RSA key that will be used for passwordless SSH to any clients configured by this deployment server::

    ssh-keygen

- Copy the content of ``/root/.ssh/id_rsa.pub`` to ``/var/lib/metalware/repo/config/domain.yml`` after the ``ssh_key`` key

Repository Mirror Server
------------------------

On Master Node
^^^^^^^^^^^^^^

- Create ``/opt/vm/repo.xml`` for deploying the repo VM (:download:`Available here <repo.xml>`)

- Create disk image for the repo VM::

    qemu-img create -f qcow2 repo.qcow2 150G

- Define the VM::

    virsh define repo.xml

On Deploy VM
^^^^^^^^^^^^

- Add the repo server to ``/opt/metalware/etc/genders``, an example entry is below::

    # SERVICES
    repo1 repo,services,cluster,domain

- Create a deployment file specifically for ``repo1`` at ``/var/lib/metalware/repo/config/repo1.yaml`` with the following content::

    Networks:
      pri:
        ip: 10.10.0.2

      mgt:
        defined: false

- Add the server to the hosts file::

    metal hosts repo1

.. note:: Currently the other interfaces will be setup despite ``defined: false`` in the configuration file

- Start PXE server listening for client requests::

    metal hunter -i eth0

- The deployment VM will print a line when the node has connected, when this happens enter the hostname for the system (this should be a hostname that exists in the nodelist mentioned earlier)

- Once the hostname has been added the previous metal command can be cancelled (with ctrl-c)

- Add dhcp host entry for repo1::

    metal dhcp -t default

- Start the build server::

    metal build repo1

- Boot the repo VM up and the PXE boot will automatically start the install

- The ``metal build`` will automatically exit when the client installation has completed

- The repo VM will now be up and can be logged in with passwordless SSH from the deployment VM

On Repo VM
^^^^^^^^^^

- Run the repos.sh script (this is performed within a screen session as the cloning of the repo takes quite a while)::

    screen -dmSL install ./repos.sh install

Using Local Yum Mirror Repo
---------------------------

- Update kickstart files

- What needs to be changed on client for yum installs to use local repo during installation?

Client Deployment Example
-------------------------

- Start the deployment VM listening for PXE requests::

    metal hunter -i eth0

- Boot up the client node

- The deployment VM will print a line when the node has connected, when this happens enter the hostname for the system (this should be a hostname that exists in the nodelist mentioned earlier)

- Once the hostname has been added the previous metal command can be cancelled (with ctrl-c)

- Generate DHCP entry for the node::

    metal dhcp -t default

- Start the deployment VM serving installation files to the node (replace slave01 with the hostname of the client node)::

    metal build slave01

- The client node can be rebooted and it will begin an automatic installation of CentOS 7

- The ``metal build`` will automatically exit when the client installation has completed

- Passwordless SSH should now work to the client node

Summary
-------

The master node is now configured and hosting a deployment VM which will be able to install other nodes in the HPC environment over the network.