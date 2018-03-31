.. _hpc-environment-considerations:

Considerations for HPC Environment Design
=========================================

Job Scheduling
--------------

In a HPC environment there are large, distributed, multiple processor jobs that the users wish to run. While these jobs can be run manually by simply executing job scripts along with a hostfile containing the compute nodes to execute on, you will soon run into problems with multiple users, job queuing and priorities. These features are provided by a job scheduler, delivering a centralised server that manages the distribution, prioritisation and execution of job scripts from multiple users in the HPC network.

Popular job schedulers for HPC clusters include:

  - Open Grid Scheduler (SGE)
  - PBS / Torque-Maui / Torque-Moab / PBSPro
  - SLURM
  - Load-sharing facility (LSF) / OpenLava
  
All job schedulers provide a similar level of functionality and customisations so it is worth investigating the features of the available solutions to find the one best suited for your environment.

.. _application-deployment:

Application Deployment
----------------------

General management of applications and libraries is mentioned :ref:`repo-management` however this section focuses on installing applications into the entire HPC environment instead of individually to each node system.

A few things to consider when designing/implementing an application deployment system are:

  - How will applications be stored? (central network storage location?)
  - What parts of the application need to be seen by the nodes? (application data? program files? libraries?)
  - How will multiple versions of the same application be installed, and how will users choose between them?
  - How will dependencies be managed? (more on this below)
  
An application deployment system can be created yourself or `Alces Gridware <http://docs.alces-flight.com/en/release-2017.1/apps/apps.html#gridware-shared-cluster-applications>`_ provides tools and an index of HPC applications for HPC platform installations.

Dependencies
^^^^^^^^^^^^

When it comes to managing dependencies for applications it can either be done with local installations of libraries/packages or by storing these in a centralised location (as suggested with the applications themselves). Dependency control is one of the main reasons that using the same OS for all systems is recommended as it eliminates the risk of applications only working on some systems within the HPC environment.

Dependancies must be managed across all nodes of the cluster, and over time as the system is managed. For example, an application that requires a particular C++ library that is available from your Linux distribution may not work properly after you install distribution updates on your compute nodes. Dependancies for applications that utilise dynamic libraries (i.e. loaded at runtime, rather than compile-time) must be particularly carefully managed over time.


Reproducibility
^^^^^^^^^^^^^^^

It is important that your users receive a consistent, long-term service from your HPC cluster to allow them to rely on results from applications run at different points in your clusters' lifecycle. Consider the following questions when designing your application management system:

 - How can I install new applications quickly and easily for users?
 - What test plans have I created to ensure that applications run in the same way across all cluster nodes?
 - How can I ensure that applications run normally as nodes are re-installed, or new nodes are added to the cluster?
 - How can I test that applications are working properly after an operating system upgrade or update?
 - How will I prepare for moving to a new HPC cluster created on fresh hardware, or using cloud resources?
 - What are the disaster recovery plans for my software applications? 
