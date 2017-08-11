.. _user-management-overview:

User Management Overview
========================

About
-----

This package contains the services required to configure a central user management server for the HPC environment.

Components
----------

For user management, one of the following software solutions will be implemented:

- NIS (Network Information Service)
- *or*
- IPA (Identity, Policy, Audit)

Key Files
---------

- ``/etc/sysconfig/network``

- ``/etc/yp.conf``, ``/var/yp/*``
- *or*
- ``/etc/ipa/*``
