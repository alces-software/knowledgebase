.. _storage-guidelines:

Recommendations for Storage Solution
====================================

Storage Hardware
----------------

For recommended storage hardware technologies, see https://github.com/alces-software/knowledgebase/wiki#storage

Changing Disk Formatting for a Node/Group
-----------------------------------------

In the metalware domain configuration files, the ``disksetup`` namespace configures the kickstart commands for disk formatting. A couple of example configurations are below.

Default disk configuration::

    disksetup: |
      zerombr
      bootloader --location=mbr --driveorder=sda --append="$bootloaderappend"
      clearpart --all --initlabel

      #Disk partitioning information
      part /boot --fstype ext4 --size=4096 --asprimary --ondisk sda
      part pv.01 --size=1 --grow --asprimary --ondisk sda
      volgroup system pv.01
      logvol  /  --fstype ext4 --vgname=system  --size=16384 --name=root
      logvol  /var --fstype ext4 --vgname=system --size=16384 --name=var
      logvol  /tmp --fstype ext4 --vgname=system --size=1 --grow --name=tmp
      logvol  swap  --fstype swap --vgname=system  --size=8096  --name=swap1

Software RAID configuration::

    disksetup: |
      zerombr

      bootloader --location=mbr --driveorder=sda --append="$bootloaderappend"
      clearpart --all --initlabel

      #Disk partitioning information
      part /boot --fstype ext4 --size=1024 --asprimary --ondisk sda
      part /boot2 --fstype ext4 --size=1024 --asprimary --ondisk sdb

      part raid.01 --size 60000 --ondisk sda --asprimary
      part raid.02 --size 60000 --ondisk sdb --asprimary

      raid pv.01 --level=1 --fstype=ext4 --device=md0 raid.01 raid.02
      volgroup system pv.01
      logvol  /  --fstype ext4 --vgname=system  --size=1  --name=root --grow
      logvol  /var  --fstype ext4 --vgname=system  --size=16384  --name=var
      logvol  swap  --fstype swap --vgname=system  --size=16384  --name=swap1

      part raid.03 --size=1 --ondisk sda --asprimary --grow
      part raid.04 --size=1 --ondisk sdb --asprimary --grow

      raid /tmp --fstype ext4 --fstype=ext4 --device=md1 --level=0 raid.03 raid.04

To override the default disk configuration, create a config file with the node/group name in ``/var/lib/metalware/repo/config/`` and add the new ``disksetup:`` key to it.

NFS Server Setup
----------------

On Master Node
^^^^^^^^^^^^^^

- Create ``/opt/vm/storage.xml`` for deploying the storage VM (:download:`Available here <storage.xml>`)

- Create disk image for the storage VM::

    qemu-img create -f qcow2 storage.qcow2 80G

- Define the VM::

    virsh define storage.xml

.. _deploy-storage:

On Controller VM
^^^^^^^^^^^^^^^^

- Create a group for the storage VM (add at least ``storage1`` as a node in the group, set additional groups of ``services,cluster,domain`` allows for more diverse group management)::

    metal configure group storage
    
- Customise ``storage1`` node configuration (set the primary IP address to 10.10.0.3)::

    metal configure node storage1

- Create ``/var/lib/metalware/repo/config/storage1.yaml`` with the ip definition::

    nfsconfig:
      is_server: true
    
    nfsexports:
      /export/users:
      /export/data:
        # Modify the export options [optional]
        #options: <%= networks.pri.network %>/<%= networks.pri.netmask %>(ro,no_root_squash,async)

.. note:: The ``options:`` namespace is optional, if not specified then the default export options will be used (``<%= networks.pri.network %>/<%= networks.pri.netmask %>(rw,no_root_squash,sync)``)

- Add the following to ``/var/lib/metalware/repo/config/domain.yaml``::

    nfsconfig:
      is_server: false
    nfsmounts:
      /users:
        server: 10.10.0.3
        export: /export/users
      /data:
        server: 10.10.0.3
        export: /export/data
        options: intr,sync,rsize=32768,wsize=32768,_netdev

.. note:: Add any NFS exports to be created as keys underneath ``nfsmounts:``. The ``options:`` namespace is only needed if wanting to override the default mount options (``intr,rsize=32768,wsize=32768,_netdev``)

- Additionally, add the following to the ``setup:`` namespace list in ``/var/lib/metalware/repo/config/domain.yaml``::

    - /opt/alces/install/scripts/01-nfs.sh

- Download the ``nfs.sh`` script to the above location::

    mkdir -p /opt/alces/install/scripts/
    cd /opt/alces/install/scripts/
    wget -O 01-nfs.sh https://raw.githubusercontent.com/alces-software/knowledgebase/master/epel/7/nfs/nfs.sh

- Follow :ref:`client-deployment` to setup the compute nodes

Lustre Server Setup
-------------------

On Master Node
^^^^^^^^^^^^^^

- Create ``/opt/vm/lustre-mds.xml`` for deploying the lustre metadata server VM (:download:`Available here <lustre-mds.xml>`)

- Create disk image for the lustre metadata server VM::

    qemu-img create -f qcow2 lustre-mds.qcow2 80G

- Define the VM::

    virsh define lustre-mds.xml

.. _deploy-lustre-mds:

On Controller VM
^^^^^^^^^^^^^^^^

- Create a group for the lustre VM (add at least ``lustre-mds1`` as a node in the group, set additional groups of ``lustre,services,cluster,domain`` allows for more diverse group management)::

    metal configure group lustre-mds
    
- Customise ``lustre-mds1`` node configuration (set the primary IP address to 10.10.0.10)::

    metal configure node lustre-mds1

- Create a deployment file specifically for ``lustre-mds1`` at ``/var/lib/metalware/repo/config/lustre-mds1.yaml`` with the following content::

    lustreconfig:
      type: server
      networks: tcp0(<%= networks.pri.interface %>)
      mountentry: "10.10.0.10:/lustre    /mnt/lustre    lustre    default,_netdev    0 0"

.. note:: If the server has an Infiniband interface that can be used for storage access then set ``networks`` to a list of modules which includes Infiniband, e.g. ``o2ib(<%= networks.ib.interface %>),tcp0(<%= networks.pri.interface %>)``

- Add the following to ``/var/lib/metalware/repo/config/domain.yaml``::

    lustreconfig:
      type: none
      networks: tcp0(<%= networks.pri.interface %>)
      mountentry: "10.10.0.10:/lustre    /mnt/lustre    lustre    default,_netdev    0 0"

.. note:: For clients to lustre, replicate the above entry into the group or node config file and change ``type: none`` to ``type: client``, also ensuring that ``networks`` reflects the available modules and interfaces on the system

- Additionally, add the following to the ``setup:`` namespace list in ``/var/lib/metalware/repo/config/domain.yaml``::

    - /opt/alces/install/scripts/08-lustre.sh

- Download the ``lustre.sh`` script to the above location::

    mkdir -p /opt/alces/install/scripts/
    cd /opt/alces/install/scripts/
    wget -O 08-lustre.sh https://raw.githubusercontent.com/alces-software/knowledgebase/master/epel/7/lustre/lustre.sh

- Follow :ref:`client-deployment` to setup the lustre node

- Once this has completed the lustre-mds node will have the necessary configuration to host a lustre metadata target or storage configuration. To configure the metadata disk or storage configuration see the below section.

Lustre Storage Setup
^^^^^^^^^^^^^^^^^^^^

A lustre storage configuration usually consists of a metadata server (that is used to authorise mount, read and write requests to the lustre storage volume) and multiple storage servers (with disk arrays attached to them). The above configuration shows how a metadata server can be configured as part of the network but with some naming tweaks the lustre storage servers can also be added to the environment.


**Metadata Storage Target**

- To format a metadata storage disk from the metadata server run a command similar to the following (replacing ``lustre`` with the desired name of the lustre filesystem and ``/dev/sda`` with the path to the disk for storing metadata)::

    mkfs.lustre --index=0 --mgs --mdt --fsname=lustre --servicenode=10.10.0.10 --reformat /dev/sda

- To activate the storage, mount it somewhere on the metadata server::

    mount -t lustre /dev/sda /mnt/lustre/mdt

**Lustre Storage Target**

These commands should be performed from different systems connected to the same storage backends across the storage configuration (depending on the network configuration) to ensure that the device management is distributed.

- A storage target for the lustre filesystem can be formatted as follows (replacing ``lustre`` with the name of the filesystem from mdt configuration, repeat ``--servicenode=IP-OF-OSSX`` for each storage system that's also connected to the same storage backend and replace ``/dev/mapper/ostX`` with the path to the storage device)::

    mkfs.lustre --ost --index=0 --fsname=lustre --mgsnode=IP-OF-MDS-NODE --mkfsoptions="-E stride=32,stripe_width=256" --servicenode=IP-OF-OSSX /dev/mapper/ostX

- The device can then be mounted::

    mount -t lustre /dev/mapper/ostX /mnt/lustre/ostX

**Client Mount**

- The following command will mount the example lustre volume created from the above steps::

    mount -t lustre 10.10.0.10:/lustre /mnt/lustre
