.. _infrastructure-considerations:

Considerations for Infrastructure Design
========================================

Infrastructure design largely relates to the considerations made for the :ref:`cluster-architectures`. Depending on the design being used, some of the infrastructure decisions may have already been made. 

Infrastructure Service Availability
-----------------------------------

There are typically 3 possible service availability options to choose from, these are:

  - All-in-one
  - VM Platform
  - High Availability VM Platform

These are covered in more detail below.

All-in-one
^^^^^^^^^^

This is the most common solution, an all-in-one approach loads services onto a single machine which serves the network. It is the simplest solution as a single OS install is required and no additional configuration of virtual machine services is needed. 

This solution, while quick and relatively easy to implement, is not a recommended approach. Due to the lack of redundancy options and the lack of service isolation there is a higher risk of an issue effecting one service (or the machine) to have an effect on other services.

VM Platform
^^^^^^^^^^^

A VM platform provides an additional layer of isolation between services. This can allow for services to be configured, migrated and modified without potentially effecting other services. 

There are a few solutions for hosting virtual machines, including:

  - VirtualBox
  - KVM
  - Xen

The above software solutions are similar and can all provide a valid virtualisation platform. Further investigation into the ease of use, flexibility and features of the software is recommended to identify the ideal solution for the HPC platform.

High Availability VM Platform
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

For further redundancy, the virtualisation platform can utilise a resource pool. The service will be spread across multiple machines which allows for VMs to migrate between the hosts whilst still active. This live migration can allow for one of the hosts to be taken off of the network for maintenance without impacting the availability of the service VMs.

Node Network Configuration
--------------------------

In addition to the availability of services, the network configuration on the node can provide better performance and redundancy. Some of the network configuration options that can improve the infrastructure are:

  - **Channel Bonding** - Bonding interfaces allows for traffic to be shared between 2 network interfaces. If the bonded interfaces are connected to separate network switches then this solution
  - **Interface Bridging** - Network bridges are used by interfaces on virtual machines to connect to the rest of the network. A bridge can sit on top of a channel bond such that the VMs network connection in constantly available.
  - **VLAN Interface Tagging** - VLAN management can be performed both on a managed switch and on the node. The node is able to create subdivisions of network interfaces to add VLAN tags to packets. This will create separate interfaces that can be seen by the operating system (e.g. eth0.1 and eth0.2) which can individually have IP addresses set.

Additional Considerations and Questions
---------------------------------------

  - Could containerised solutions be used instead of VMs?
  
      - *Docker* or *Singularity* containerised services can provide similar levels of isolation between services as VMs without the additional performance overhead. 