Cluster Platform Knowledgebase
==============================

This site documents the considerations and guidelines for designing and developing a HPC platform for cluster computing. The documentation describes general practices and considerations when designing a HPC platform as well as recommendations and guides used by Alces Software to configure HPC platforms.

Acknowledgements
----------------

We recognise the respect the trademarks of all third-party providers referenced in this documentation. Please see the respective EULAs for software packages used in configuring your own environment based on this knowledgebase. 

License
^^^^^^^

This documentation is released under the `Creative-Commons: Attribution-ShareAlike 4.0 International <http://creativecommons.org/licenses/by-sa/4.0/>`_ license.


HPC Cluster Platform
--------------------

This knowledgebase document is broken down into the following sections:

.. Navigation/TOC

.. toctree::
   :maxdepth: 1
   :glob:
   :caption: Introduction
   :name: introduction
   
   introduction.rst
   overviews.rst

.. toctree::
   :maxdepth: 1
   :glob:
   :caption: Network and Hardware
   :name: network-hardware
   
   network-hardware/*

.. toctree::
   :maxdepth: 1
   :glob:
   :caption: Infrastructure
   :name: infrastructure
   
   infrastructure/*

.. toctree::
   :maxdepth: 1
   :glob:
   :caption: Base System Deployment
   :name: base-system
   
   base/deployment-overview
   base/deployment-considerations
   base/0*

.. toctree::
   :maxdepth: 1
   :glob:
   :caption: Repository Management
   :name: repository-management

   repo/repository-overview
   repo/repository-guidelines

.. toctree::
   :maxdepth: 1
   :glob:
   :caption: User Management
   :name: user-management
   
   user-management/user-management-overview
   user-management/*

.. toctree::
   :maxdepth: 1
   :glob:
   :caption: Storage
   :name: storage
   
   storage/storage-overview
   storage/*

.. toctree::
   :maxdepth: 1
   :glob:
   :caption: Monitoring
   :name: monitoring
   
   monitoring/monitoring-overview
   monitoring/*

.. toctree::
   :maxdepth: 1
   :glob:
   :caption: Hardware Drivers
   :name: hardware-drivers

   hardware-drivers/hardware-drivers-overview
   hardware-drivers/first-boot-setup
   hardware-drivers/compute-node-setup

.. toctree::
   :maxdepth: 1
   :glob:
   :caption: HPC Environment
   :name: hpc-environment
   
   hpc-environment/hpc-environment-overview
   hpc-environment/*

.. toctree::
   :maxdepth: 1
   :glob:
   :caption: Verification
   :name: verification
   
   verification/*

.. toctree::
   :maxdepth: 1
   :glob:
   :caption: Deployment on AWS
   :name: deployment-on-aws
   
   base/deployment-aws
