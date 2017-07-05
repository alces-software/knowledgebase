.. _storage-guidelines:

Recommendations for Storage Solution
====================================

Storage Hardware
----------------

For recommended storage hardware technologies, see https://github.com/alces-software/knowledgebase/wiki#storage

Changing Disk Formatting
------------------------

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

