.. _user-management-overview:

User Management Overview
========================

About
-----

This package contains the services required to configure a central user management server for the HPC environment. This relieves the need to manage ``/etc/passwd`` locally on every system within the HPC environment and provides further authentication management of different services.

Components
----------

For user management, one of the following software solutions will be implemented:

- NIS (Network Information Service)

    - The Network Information Service (NIS) is a directory service that enables the sharing of user and host information across a network. 

- *or*

- IPA (Identity, Policy, Audit)

    - FreeIPA provides all the information that NIS does as well as providing application and service information to the network. Additionally, FreeIPA uses directory structure such that information can be logically stored in a tree-like structure. It also comes with a web interface for managing the solution.

Key Files
---------

- ``/etc/sysconfig/network``

- ``/etc/yp.conf``, ``/var/yp/*``
 *or*
- ``/etc/ipa/*``
