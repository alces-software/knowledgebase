.. _deployment-considerations:

Considerations for Software and Application Deployment
======================================================

Before considering *how* the OS and applications will be deployed it is worth making a few decisions regarding the OS that will be used:

  - Will the same OS be used on all systems? (it's strong recommended to do so)
  - What software will be used? (and therefore will need to be supported by the OS)
  - How stable is the OS? (bleeding edge OSes may have bugs and instabilities that could negatively impact the HPC environment) 

Deployment
----------

The deployment of the HPC platform can be boiled down to two main sections, these being:

  - Operating System Deployment
  - Repository Management

Operating System Deployment
^^^^^^^^^^^^^^^^^^^^^^^^^^^

When it comes to performing many operating installations across nodes in the network it can be tricky to find a flexible, manageable, automated solution. Performing manual installations of operating systems may be the ideal solution if there are only a few compute nodes, however, there are many other ways of improving the speed of OS deployment:

  - **Disk Cloning** - A somewhat inelegant solution, disk cloning involves building the operating system once and creating a compressed copy on a hard-drive that can be restored to blank hard-drives. 
  - **Kickstart** - A kickstart file is a template for automating OS installations, the configuration file can be served over the network such that clients can PXE boot the installation. This can allow for easy, distributed deployment over a local network.

It is worth considering manual, cloning and kickstart solutions for your OS deployment, any one of them could be the ideal solution depending on the number of machines that are being deployed.

Repository Management
^^^^^^^^^^^^^^^^^^^^^

It is worth considering how packages, libraries and applications will be installed onto individual nodes and the network as a whole. Operating systems usually have their own package management system installed that uses public repositories for pulling down packages for installation. It is likely that all of the packages required for a system are not in the public repositories so it's worth considering where these will come from (3rd party repository? downloaded directly from the package maintainer? manually compiled?). 

Further to managing packages on the local system, the entire network may require applications to be installed, there are a couple of options for achieving this:

  - **Server Management Tools** - Management tools such as puppet, chef or pdsh can execute commands across multiple systems in parallel. This saves time having to individually login and run commands on each node in the system.
  - **Network Package Managers** - Software such as `Alces Gridware <https://gridware.alces-flight.com>`_ can install an application in a centralised storage location such that changes to ``PATH`` and ``LD_LIBRARY_PATH`` on a node is all that is required for it to start using the application.

Additional Considerations and Questions
---------------------------------------

  - How will applications outside of the repositories be installed?
  
    - Will the application need to be useable by all nodes in the HPC network? (an NFS export for apps may solve the issue of multiple installations)