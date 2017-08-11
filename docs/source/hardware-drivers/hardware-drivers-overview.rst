.. _hardware-drivers-overview:

Hardware Drivers Overview
=========================

About
-----

Some clusters may require custom hardware drivers for your chosen operating system. This package will create an environment that allows nodes to run installers on its first boot to build the driver against the up-to-date OS.

Components
----------

The components in this package are:

  - First boot environment for automatically executing installers at boot time
  - Infiniband driver first-boot script 
  - Nvidia graphics driver first-boot script

Key Files
---------

- ``/etc/systemd/system/firstrun.service``
- ``/var/lib/firstrun/*``
- ``/var/log/firstrun/*``
- ``/opt/alces/installers/*``
