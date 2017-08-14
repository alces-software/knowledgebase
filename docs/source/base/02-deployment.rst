.. _02-deployment:

Controller VM Setup
===================

On Master Node
--------------

- Create ``/opt/vm/controller.xml`` for provisioning a VM called controller (:download:`Available here <controller.xml>`)

  - This template creates 3 interfaces on the VM (on the primary, management and external networks)

- Create base qcow2 image ``controller.qcow2``::

    qemu-img create -f qcow2 controller.qcow2 80G

- Create the VM::

    virsh define controller.xml

- Start the VM::

    virsh start controller

- Connect a VNC-like window to the VM to watch it booting and interact with the terminal::

    virt-viewer controller

.. note:: Much like the host system, a minimal installation of CentOS 7 is recommended (as is ensuring that the system is up-to-date with ``yum -y update``)

On Controller VM
----------------

OS Setup
^^^^^^^^

- Set the hostname of the system (the fully-qualified domain name for this system has additionally added the cluster name)::

    echo 'controller.testcluster.cluster.local' > /etc/hostname

- Setup the network interfaces (if setting a static IP then ensure to set ``IPADDR``, ``NETMASK`` and ``NETWORK`` for the interface)

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

.. _deploy-metalware:

Metalware Install
^^^^^^^^^^^^^^^^^

- Install metalware (to install a different branch, append ``alces_SOURCE_BRANCH=develop`` before ``/bin/bash`` in order to install the ``develop`` branch)::

    curl -sL http://git.io/metalware-installer | sudo alces_OS=el7 /bin/bash

- Run the metalware setup script (there are variables within this script that may need updating if your network setup differs from the examples used in this documentation - it is recommended to download this script before running it to check the variables are correct)::

    curl -sL https://raw.githubusercontent.com/alces-software/knowledgebase/master/epel/7/metalware/metalware.sh | sudo /bin/bash
 
- Reboot the VM

- Set metalware to use default repository::

    metal repo use https://github.com/alces-software/metalware-default.git

- Configure the domain settings (this will prompt for various details regarding the domain setup, such as, root password, SSH RSA key [which can be created with ``ssh-keygen``] and default network parameters)::

    metal configure domain

- Set the IPMI/BMC admin password in ``/var/lib/metalware/repo/config/domain.yaml`` in the ``bmc:`` namespace::

    bmcpassword: 'Pa55Word'

- Uncomment the ``PASSWORD=`` line in ``/opt/metalware/etc/ipmi.conf`` and replace ``password`` with the IPMI password above

.. note:: If you wish to install an OS other than CentOS 7 then see the :ref:`Configure Alternative Kickstart Profile <deployment-kickstart>` instructions.

Platform Scripts
^^^^^^^^^^^^^^^^

Deploying on different hardware and platforms may require additional stages to be run on systems when being deployed. This is handled by an additional scripts key ``platform:`` in ``/var/lib/metalware/repo/config/domain.yaml``.

There is currently a script for configuring the AWS EL7 platform available on github which can be downloaded to the scripts area::

    mkdir -p /opt/alces/install/scripts/
    cd /opt/alces/install/scripts/
    wget https://raw.githubusercontent.com/alces-software/knowledgebase/master/epel/7/platform/aws.sh
