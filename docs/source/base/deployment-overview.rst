.. _deployment-overview:

Base System Overview
====================

About
-----

The base system is comprised of the integral services required for a deployment environment.

It is recommended that periodic updates are run in the future with the source tree for the minor OS version. The systems would require careful testing after any updates have been applied to ensure system functionality has persisted. 

.. note:: If a :ref:`local repository <repository-overview>` has been setup then the local repo mirrors will need to be resynced before deploying updates.

The controller node also provides IP Masquerading on its external interface. All slave nodes are configured to default route out via the controller node's external interface.

A tftp service, dhcpd service and webserver are installed on the controller node, these enable slave systems to be booted and pickup a series of automated deployment scripts that will result in a blank system being deployed and joining the environment.

Components
----------

This package will set up and configure:

  - Up-to-date OS installation (CentOS 7.3 with full upstream 'update' tree applied)
  - Firewall rules for network interfaces
  - Metalware cluster management software, providing:

    - Custom yum repository for providing additional packages to nodes
    
        - The directory ``/opt/alces/repo/custom/Packages`` can be used to store RPMs that will then be served to client nodes, allowing for custom, additional or non-supported packages to be installed.
    
    - DHCP and TFTP server configuration for network booting
    
        - DHCP will provide host identity management, such as, serving IPs and hostnames to client systems based on the hardware MAC address of the client. This information is used during installation to configure the node uniquely.
        - TFTP will provide the boot configuration of the system in order to provide the build or boot environment of client systems.
        
    - NTP for keeping the cluster clocks in sync

  - Name resolution services either:

    - DNSmasq using ``/etc/hosts``
    
        - Alongside the server providing lookup responses, the client systems will also have a fully populated ``/etc/hosts`` files for local queries.
    
    - *or*
    - Named from bind packages
    
        - Named creates forward and reverse search zones on the controller node that can be queried by all clients. Unlike DNSmasq, the client systems have an empty ``/etc/hosts`` as named is serving all of the additional host information.
    
  - Management tools built around ipmitool, pdsh and libgenders
  
      - These management tools allow for running commands on multiple systems defined in groups, improving the ease and flexibility of environment management.

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
