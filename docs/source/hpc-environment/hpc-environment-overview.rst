.. _hpc-environment-overview:

HPC Environment Overview
========================

About
-----

This package provides tools for queuing jobs and running applications across the cluster. 

Components
----------

The HPC environment will be comprised of:

  - Queuing system for optimised resource utilisation
  
    - SLURM 
       
        - The SLURM job scheduler is a centrally managed job scheduler that cant constrain resources based on grid utilisation, user/group assignment and job resource requirements.
    
    - *or*
    - Open Grid Scheduler
    
        - Much like SLURM, OGS provides a centrally managed job scheduler with similar resource management possibilities.
  
  - Application deployment solution
  
    - Environment modules
    
        - Modules allows for applications to be loaded dynamically in shell sessions. With the paths being updated on-the-fly, applications can be installed to a network storage location - minimising installation time and improving the ease of application use (both in interactive and non-interactive sessions).
    
    - *or*
    - Alces Gridware
    
        - Gridware contains an implementation of environment modules and also provides a useful CLI tool for installing and managing applications from a large repository of HPC applications.

Key Files
---------

- ``/etc/slurm/*``
- *or*
- ``/opt/gridscheduler/*``

- ``/opt/apps/*``
- *or*
- ``/opt/gridware/``

