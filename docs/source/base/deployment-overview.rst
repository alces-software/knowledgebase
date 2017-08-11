.. _deployment-overview:

Base System Overview
====================

About
-----

The base system is comprised of the integral services required for a deployment environment.

It is recommended that periodic updates are run in the future with the source tree for the minor OS version. The systems would require careful testing after any updates have been applied to ensure system functionality has persisted. 

.. note:: If a :ref:`local repository <repository-overview>` has been setup then the local repo mirrors will need to be resynced before deploying updates.

The deployment node also provides IP Masquerading on its external interface. All slave nodes are configured to default route out via the deployment node's external interface.

A tftp service, dhcpd service and webserver are installed on the deployment node, these enable slave systems to be booted and pickup a series of automated deployment scripts that will result in a blank system being deployed and joining the environment.

Components
----------

This package will set up and configure:

  - Up-to-date OS installation (CentOS 7.3 with full upstream 'update' tree applied)
  - Firewall rules for network interfaces
  - Metalware cluster management software, providing:

    - Custom yum repository for providing additional packages to nodes
    - DHCP and TFTP server configuration for network booting
    - NTP for keeping the cluster clocks in sync

  - Name resolution services either:

    - DNSmasq using ``/etc/hosts``
    - *or*
    - Named from bind packages
    
  - Management tools built around ipmitool, pdsh and libgenders

Key Files
---------

- ``/etc/hosts``
- ``/etc/dhcp/dhcpd.*``
- ``/etc/dnsmasq.conf`` or ``/etc/named/metalware.conf``
- ``/opt/metalware/*``
- ``/var/lib/metalware/*``
- ``/var/lib/tftpboot/*``
- ``/etc/ntp.conf``

Licensing
---------

The CentOS Linux distribution is released under a number of Open-source software licenses, including GPL. A copy of the relevant license terms is included with the CentOS software installed on your cluster. The CentOS Linux distribution does not require any per-server license registration.

Additionally, the applications and services installed have similar open-source licensing which can be viewed either online or through the manual pages for the specific package.
