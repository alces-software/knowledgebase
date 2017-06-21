.. _network-hardware-considerations:

Considerations for Network and Hardware Design
==============================================

In general, the things to consider when designing the hardware and network solution for a HPC platform are:

  - The types of nodes required in the network
  - The different networks to be used by the network
  - The level of resilience desired
  - The hostname and domain naming convention
  
These are covered in more detail below...

.. _node-types:

Node Types
----------

A complete HPC platform will be comprised of systems that serve different purposes within the network. Ideas of node types along with the services and purpose of those nodes can be seen below.

  - **Login Node** - A login node will usually provide access to the HPC platform and will be the central system that users access to run applications. How users will access the system should be considered, usually this will be SSH and some graphical login service, such as, VNC.
  - **Master Node** - A master node will usually run services for the HPC platform. Such as, the master process for a job scheduler, monitoring software, storage arrays and user management services.
  - **Compute Node** - Compute nodes are usually used for running HPC applications that are queued through a job scheduler. Additionally, these can be used for VM deployments (via software like OpenStack) or other computational uses. Compute nodes usually have large amounts of cores and memory as well as high bandwidth interconnect (like Infiniband).

The above types are not strict. Services can be mixed, matched and moved around to create the desired balance and distribution of services and functions for the platform.

.. _different-networks:

Different Networks
------------------

The network in the system will most likely be broken up (physically or virtually with VLANs) into separate networks to serve different usages and isolate traffic. Potential networks that may be in the HPC platform are:

  - **Primary Network** - The main network that all systems are connected to.
  - **Out-of-Band Network** - A separate network for management traffic. This could contain on-board BMCs, switch management ports and disk array management ports. Typically this network would only be accessible by system administrators from within the HPC network.
  - **High Performance Network** - Usually built on an Infiniband fabric, the high performance network would be used by the compute nodes for running large parallel jobs over MPI. This network can also be used for storage servers to provide performance improvements to data access.
  - **External Networks** - The network outside of the HPC environment that nodes may need to access. For example, the *Master Node* could be connected to an *Active Directory* server on the external network and behave as a slave to relay user information to the rest of the HPC environment. 
  - **Build Network** - This network can host a DHCP server for deploying operating systems via PXE boot kickstart installations. It allows for systems that require a new build or rebuild to be flipped over and provisioned without disturbing the rest of the network.
  - **DMZ** - A demilitarised zone would contain any externally-facing services, this could be setup in conjunction with the external networks access depending on the services and traffic passing through.

The above networks could be physically or virtually separated from one another. In a physical separation scenario there will be a separate network switch for each one, preventing any sort of cross-communication. In a virtually separated network there will be multiple bridged switches that separate traffic by dedicating ports (or tagging traffic) to different VLANs. The benefit of the VLAN solution is that the bridged switches (along with bonded network interfaces) provides additional network redundancy.

Resilience
----------

How well a system can cope with failures is crucial when delivering a HPC platform. Adequate resilience can allow for maximum system availability with a minimal chance of failures disrupting the user. System resilience can be improved with many hardware and software solutions, such as:

  - **RAID Arrays** - A RAID array is a collection of disks configured in such a way that they become a single storage device. There are different RAID levels which improve data redundancy or storage performance (and maybe even both). Depending on the RAID level used, a disk in the array can fail without disrupting the access to data and can be hot swapped to rebuild the array back to full functionality. [#f1]_
  - **Service Redundancy** - Many software services have the option to configure a slave/failover server that can take over the service management should the master process be unreachable. Having a secondary server that mirrors critical network services would provide suitable resilience to master node failure. 
  - **Failover Hardware** - For many types of hardware there is the possibility of setting up failover devices. For example, in the event of a power failure (either on the circuit or in a power supply itself) a redundant power supply will continue to provide power to the server without any downtime occurring. 

There are many more options than the examples above for improving the resilience of the HPC platform, it is worth exploring and considering available solutions during design.

Hostname and Domain Names
-------------------------

Using proper domain naming conventions during design of the HPC platform is best practice for ensuring a clear, logical and manageable network. Take the below fully qualified domain name::

  node01.pri.cluster1.compute.estate

Which can be broken down as follows:

  - ``node01`` - The hostname of the system
  - ``pri`` - The network that the interface of the system is sat on (in this case, pri = primary)
  - ``cluster1`` - The cluster that ``node01`` is a part of
  - ``compute`` - The subdomain of the greater network that ``cluster1`` is a part of
  - ``estate`` - The top level domain 

Additional Considerations and Questions
---------------------------------------

The below questions should be considered when designing the network and hardware solution for the HPC platform.

  - How much power will the systems draw?

    - Think about the power draw of the selected hardware, it may be drawing a large amount of amps so sufficient power sources must be available. 

  - How many users are going to be accessing the system?
  
    - A complex, distributed service network would most likely be overkill and a centralised login/master node would be more appropriate.

  - What network interconnect will be used?
  
    - It's most likely that different network technologies will be used for :ref:`different-networks`. For example, the high performance network could benefit from using Infiniband as the interconnect. 

  - How could the hardware be optimised?
  
    - BIOS settings could be tweaked on the motherboard to give additional performance and stability improvements.
    - Network switch configurations could be optimised for different types of traffic

  - What :ref:`types of nodes <node-types>` will be in the system?
  - What applications are going to be run on the system?
  
    - Are they memory intensive?
    - Is interconnect heavily relied upon for computations?

.. [#f1] For more information on RAID arrays see https://en.wikipedia.org/wiki/RAID