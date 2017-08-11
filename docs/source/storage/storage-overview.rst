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
  - Filesystem formatting
  
    - Ext4
    - *or*
    - XFS
    
  - Exported filesystems
  
    - ``/export/users`` to be mounted at ``/users`` on clients
    - ``/export/data`` to be mounted at ``/data`` on clients

Key Files
---------

- ``/etc/sysconfig/nfs``
- ``/etc/exports``
- ``/etc/fstab``
