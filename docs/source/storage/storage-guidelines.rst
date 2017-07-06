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
      bootloader --location=mbr --driveorder=<%= disk %> --append="$bootloaderappend"
      clearpart --all --initlabel

      #Disk partitioning information
      part /boot --fstype ext4 --size=4096 --asprimary --ondisk <%= disk %>
      part pv.01 --size=1 --grow --asprimary --ondisk <%= disk %>
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

NFS & NIS Server Setup
----------------------

On Master Node
^^^^^^^^^^^^^^

- Create ``/opt/vm/storage.xml`` for deploying the repo VM (:download:`Available here <storage.xml>`)

- Create disk image for the storage VM::

    qemu-img create -f qcow2 storage.qcow2 80G

- Define the VM::

    virsh define storage.xml

On Deploy VM
^^^^^^^^^^^^

- Add the storage server to ``/opt/metalware/etc/genders``, an example entry is below::

    # SERVICES
    storage1 storage,services,cluster,domain

- Create ``/var/lib/metalware/repo/config/storage1.yaml`` with the ip definition::

    networks:
      pri:
        ip: 10.10.0.3
    
      mgt:
        defined: disabled

- Add the following to ``/var/lib/metalware/repo/config/domain.yaml`` (the nfsserver IP should match the one specified in ``storage1.yaml``):

    netconfig:
      nfsserver: 10.10.0.3
      nisserver: 10.10.0.3
      nisdomain: nis.<%= domain %>
    nfsmounts:
      users: /users
      data: /data

.. note:: Add any NFS exports to be created as keys underneath ``nfsmounts:``

- Additionally, add the following to the ``setup:`` namespace list in ``/var/lib/metalware/repo/config/domain.yaml``:::

    - /opt/alces/install/scripts/nfs.sh
    - /opt/alces/install/scripts/nis.sh

- Download the ``nfs.sh`` and ``nis.sh`` scripts to the above location::

    mkdir -p /opt/alces/install/scripts/
    cd /opt/alces/install/scripts/
    wget htps://raw.githubusercontent.com/alces-software/knowledgebase/master/epel/7/nfs/nfs.sh
    wget htps://raw.githubusercontent.com/alces-software/knowledgebase/master/epel/7/nis/nis.sh

- Follow :ref:`client-deployment` to setup the compute nodes
