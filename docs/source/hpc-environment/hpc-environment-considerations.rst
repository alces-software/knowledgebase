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



Dependencies
^^^^^^^^^^^^



