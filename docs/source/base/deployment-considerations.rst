.. _deployment-considerations:

Considerations for Software and Application Deployment
======================================================

Before considering *how* the OS and applications will be deployed it is worth making a few decisions regarding the OS that will be used:

  - Will the same OS be used on all systems? (it's strong recommended to do so)
  - What software will be used? (and therefore will need to be supported by the OS)
  - How stable is the OS? (bleeding edge OSes may have bugs and instabilities that could negatively impact the HPC environment) 
  - If you are using bare-metal hardware, is the OS supported by your hardware vendor? (running an unsupported OS can lead to issues when attempting to obtain hardware support)

Deployment
----------

The deployment of the HPC platform can be summarised in two main sections, these being:

  - Operating System Deployment
  - Software Package Repository Management

Operating System Deployment
^^^^^^^^^^^^^^^^^^^^^^^^^^^

When it comes to performing many operating installations across nodes in the network it can be tricky to find a flexible, manageable, automated solution. Performing manual installations of operating systems may be the ideal solution if there are only a few compute nodes, however, there are many other ways of improving the speed of OS deployment:

  - **Disk Cloning** - A somewhat inelegant solution, disk cloning involves building the operating system once and creating a compressed copy on a hard-drive that can be restored to blank hard-drives. 
  - **Kickstart** - A kickstart file is a template for automating OS installations, the configuration file can be served over the network such that clients can PXE boot the installation. This can allow for easy, distributed deployment over a local network.
  - **Image Deployment** - Cloud service providers usually deploy systems from template images that set hostnames and other unique system information at boot time. Customised templates can also be created for streamlining the deployment and customisation procedure.

It is worth considering manual, cloning and kickstart solutions for your OS deployment, any one of them could be the ideal solution depending on the number of machines that are being deployed.

.. _repo-management:

Repository Management
^^^^^^^^^^^^^^^^^^^^^

It is worth considering how packages, libraries and applications will be installed onto individual nodes and the network as a whole. Operating systems usually have their own package management system installed that uses public repositories for pulling down packages for installation. It is likely that all of the packages required for a system are not in the public repositories so it's worth considering where additional packages will come from (e.g. a 3rd party repository, downloaded directly from the package maintainer or manually compiled). 

Further to managing packages on the local system, the entire network may require applications to be installed; there are a couple of options for achieving this:

  - **Server Management Tools** - Management tools such as puppet, chef or pdsh can execute commands across multiple systems in parallel. This saves time instead of having to individually login and run commands on each node in the system.
  - **Network Package Managers** - Software such as `Alces Gridware <https://gridware.alces-flight.com>`_ can install an application in a centralised storage location, allowing users simply to modify their ``PATH`` and ``LD_LIBRARY_PATH`` on a node in order to start using the application.
  
For more information regarding network package managers and application deployment, see :ref:`application-deployment`

Additional Considerations and Questions
---------------------------------------

  - How will applications outside of the repositories be installed?
  - Will the application need to be useable by all nodes in the HPC network? (e.g. an NFS export for apps may solve the issue of multiple installations)
  - How will new package versions be installed when the HPC environment being maintained in the future?
  - How will you create and maintain a consistent software environment on all nodes over time?
