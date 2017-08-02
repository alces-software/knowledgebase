.. _02-deployment:

Deploymeny VM Setup
===================

On Master Node
--------------

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

On Deploy VM
------------

OS Setup
^^^^^^^^

- Set the hostname of the system (the fully-qualified domain name for this system has additionally added the cluster name)::

    echo 'deploy.testcluster.cluster.local' > /etc/hostname

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

.. note:: If you wish to install an OS other than CentOS 7 then see the :ref:`Configure Alternative Kickstart Profile <deployment-kickstart>` instructions.

Platform Scripts
^^^^^^^^^^^^^^^^

Deploying on different hardware and platforms may require additional stages to be run on systems when being deployed. This is handled by an additional scripts key ``platform:`` in ``/var/lib/metalware/repo/config/domain.yaml``.

There is currently a script for configuring the AWS EL7 platform available on github which can be downloaded to the scripts area::

    mkdir -p /opt/alces/install/scripts/
    cd /opt/alces/install/scripts/
    wget https://raw.githubusercontent.com/alces-software/knowledgebase/master/epel/7/platform/aws.sh
