.. _hpc-environment-considerations:

Considerations for HPC Environment Design
=========================================

Job Scheduling
--------------

In a HPC environment there are large, distributed, multiple processor jobs that the users wish to run. While these jobs can be run manually by simply executing job scripts along with a hostfile containing the compute nodes to execute on, you will soon run into problems with multiple users, job queuing and priorities. This is where job schedulers come in, these provide a centralised server that manages the distribution, prioritisation and execution of job scripts in the HPC network.

Popular job schedulers include:

  - Open Grid Scheduler
  - PBS
  - SLURM
  
All job schedulers provide a similar level of functionality and customisations so it is worth investigating the features of the available solutions to find the one best suited for your environment.

.. _application-deployment:

Application Deployment
----------------------

General management of applications and libraries is mentioned :ref:`repo-management` however this section focuses on installing applications into the entire HPC environment instead of individually to each node system.

A few things to consider when designing/implementing an application deployment system are:

  - How will applications be stored? (central network storage location?)
  - What parts of the application need to be seen by the nodes? (application data? program files? libraries?)
  - How will dependencies be managed? (more on this below)

Dependencies
^^^^^^^^^^^^

When it comes to managing dependencies for applications it can either be done with local installations of libraries/packages or by storing these in a centralised location (as suggested with the applications themselves). Dependency control is one of the main reasons that using the same OS for all systems is recommended as it eliminates the risk of applications only working on some systems within the HPC environment.

