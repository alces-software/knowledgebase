.. _repository-overview:

Repository Overview
===================

About
-----

Upstream repositories for CentOS and EPEL will be mirrored locally to a virtual machine which can provide the packages to the rest of the nodes in the cluster. The local repository will be used for deployment installations and package updates. 

Components
----------

Upstream distribution primary repos and EPEL will imported to ``/opt/alces/repo/`` with ``reposync``, any upstream repo groups will also be imported to allow node redeployment without internet access (and a known working disaster recovery configuration).

Key Files
---------

- ``/etc/yum.repos.d/*``
- ``/opt/alces/repo/*``
