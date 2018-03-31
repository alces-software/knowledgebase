.. _storage-overview:

Storage Overview
================

About
-----

This package configures an NFS master server to provide user and data filesystems to all slave nodes. 

Components
----------

The storage solution is comprised of the following:

  - NFS server
  
      - The NFS server serves redundant network storage (depending on hardware and network configuration) to the client systems in the environment. This allows for distributed access to project and user data.
  
  - Filesystem formatting
  
    - Ext4
    *or*
    - XFS
    
  - Exported filesystems
  
    - ``/export/users`` to be mounted at ``/users`` on clients
    - ``/export/data`` to be mounted at ``/data`` on clients

Key Files
---------

- ``/etc/sysconfig/nfs``
- ``/etc/exports``
- ``/etc/fstab``
