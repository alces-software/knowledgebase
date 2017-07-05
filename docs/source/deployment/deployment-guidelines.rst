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

- Run the metalware install and TFTP server setup script::

    curl -sL https://raw.githubusercontent.com/alces-software/knowledgebase/master/epel/7/metalware/metalware.sh | sudo /bin/bash
 
- Reboot the VM

- Set metalware to use default repository::

    metal repo use https://github.com/alces-software/metalware-default.git

- Populate hostfile with slave nodes (the nodelist can be viewed with ``nodeattr -n nodes``)::

    metal hosts -g nodes

- Create an SSH RSA key that will be used for passwordless SSH to any clients configured by this deployment server::

    ssh-keygen

- Copy the content of ``/root/.ssh/id_rsa.pub`` to ``/var/lib/metalware/repo/config/domain.yml`` after the ``ssh_key`` key

- Set the IPMI/BMC admin password in ``/var/lib/metalware/repo/config/domain.yaml`` in the ``bmc:`` namespace::

    bmcpassword: 'Pa55Word'

- Uncomment the ``PASSWORD=`` line in ``/opt/metalware/etc/ipmi.conf`` and replace ``password`` with the IPMI password above

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

- Add the following to ``/var/lib/metalware/repo/config/domain.yaml`` (the reposerver IP should match the one specified in ``repo1.yaml``)::

    localmirror: true
    repoconfig:
      reposerver: 10.10.0.2
      repopath: repo
      repourl: http://<%= repoconfig.reposerver %>/<%= repoconfig.repopath %>
    upstreamrepos:
      centos:
        name: centos
        baseurl: http://mirror.ox.ac.uk/sites/mirror.centos.org/7/os/x86_64/
      centos-updates:
        name: centos-updates
        baseurl: http://mirror.ox.ac.uk/sites/mirror.centos.org/7/updates/x86_64/
      centos-extras:
        name: centos-extras
        baseurl: http://mirror.ox.ac.uk/sites/mirror.centos.org/7/extras/x86_64/
      epel:
        name: epel
        baseurl: http://anorien.csc.warwick.ac.uk/mirrors/epel/7/x86_64/
        enabled: 0
        priority: 11
    localrepos:
      centos:
        name: centos
        baseurl: <%= repoconfig.repourl %>/centos/
      centos-updates:
        name: centos-updates
        baseurl: <%= repoconfig.repourl %>/centos-updates/
      centos-extras:
        name: centos-extras
        baseurl: <%= repoconfig.repourl %>/centos-extras/
      custom:
        name: custom
        baseurl: <%= repoconfig.repourl %>/custom/
        priority: 1
      epel:
        name: epel
        baseurl: <%= repoconfig.repourl %>/epel/
        enabled: 0
        priority: 11

.. note:: Any repos added to ``domain.yaml`` must include a ``name`` and a ``baseurl`` element. Optionally the repo definitions can include ``description``, ``enabled``, ``skip_if_unavailable``, ``gpgcheck`` and ``priority`` to override the default values that are set when generating the repos.

- Additionally, add the following to the ``setup:`` namespace list in ``/var/lib/metalware/repo/config/domain.yaml``::

    - /opt/alces/install/scripts/repos.sh

- Modify ``/var/lib/metalware/repo/kickstart/default``

  - Old line::
  
      #url --url=http://${_ALCES_BUILDSERVER}/${_ALCES_CLUSTER}/repo/centos/
      url --url=http://mirror.ox.ac.uk/sites/mirror.centos.org/7/os/x86_64/
  
  - New line::
  
      <% if localmirror -%>
      url --url=<%= repoconfig.repourl %>/centos/
      <% else -%>
      curl --url=http://mirror.ox.ac.uk/sites/mirror.centos.org/7/os/x86_64/
      <% end -%>

- Download the repos.sh script to the above location::

    mkdir -p /opt/alces/install/scripts/
    cd /opt/alces/install/scripts/
    wget https://raw.githubusercontent.com/alces-software/knowledgebase/master/epel/7/repo/repos.sh

- Follow :ref:`client-deployment` to setup the compute nodes

- The repo VM will now be up and can be logged in with passwordless SSH from the deployment VM and will have a clone of the CentOS upstream repositories locally.

Compute Node Infiniband Setup
-----------------------------

- Create a configuration file specifically for the nodes group ``/var/lib/metalware/repo/config/nodes.yaml`` with the ib network setup::

    ib:
      defined: true
      ib_use_installer: false
      mellanoxinstaller: http://route/to/MLNX_OFED_LINUX-x86_64.tgz
      ip: 

.. note:: If you want to install the Mellanox driver (and not use the IB drivers from the CentOS repositories), set ``ib_use_installer`` to ``true`` and set ``mellanoxinstaller`` to the location of the mellanox OFED installer.

- Download the ``infiniband.sh`` script from the knowledgebase::

    mkdir -p /opt/alces/install/scripts/
    cd /opt/alces/install/scripts/
    wget https://raw.githubusercontent.com/alces-software/knowledgebase/master/epel/7/infiniband/infiniband.sh

- Add the script to the ``scripts:`` namespace list::

    - /opt/alces/install/scripts/infiniband.sh

- Follow :ref:`client-deployment` to setup the compute nodes

.. _client-deployment:

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

.. note:: If building multiple systems the genders group can be specified instead of the node hostname. For example, all compute nodes can be built with ``metal build -g nodes``.

- The client node can be rebooted and it will begin an automatic installation of CentOS 7

- The ``metal build`` will automatically exit when the client installation has completed

- Passwordless SSH should now work to the client node

Summary
-------

The master node is now configured and hosting a deployment VM which will be able to install other nodes in the HPC environment over the network.