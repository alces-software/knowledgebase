.. _hardware-drivers-overview:

Hardware Drivers Overview
=========================

About
-----

Some clusters may require custom hardware drivers for your chosen operating system. This can be the case for both bare-metal hardware and cloud-based resources for devices such as Infiniband or other accelerated network technologies, GPU and FPGA cards or RAID controllers. This package will create an environment that allows nodes to run installers during first-boot to build the driver against the up-to-date operating system packages.

Components
----------

The components in this package are:

  - First boot environment for automatically executing installers at boot time
  
      - This provides a system service that can be used to run installation scripts when a system is turned on. For example, Nvidia graphics driver can be set to compile after the initial build of the system such that it is compiled against the correct kernel version.
  
  - Infiniband driver first-boot script
  
      - A script that can install the Mellanox Infiniband driver either from upstream repositories or through local compilation from the source files
  
  - Nvidia graphics driver first-boot script

Key Files
---------

- ``/etc/systemd/system/firstrun.service``
- ``/var/lib/firstrun/*``
- ``/var/log/firstrun/*``
- ``/opt/alces/installers/*``


.. note:: In order to use first-boot, the system must be compatible with the base operating system. Review instructions for your chosen operating system if you need to use special drivers in order to allow your nodes to install the base OS. 
