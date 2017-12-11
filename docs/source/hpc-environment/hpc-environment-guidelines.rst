.. _hpc-environment-guidelines:

Recommendations for HPC Environment Design
==========================================

SLURM Setup (From Controller VM)
--------------------------------

- Create a group for the slurm VM (add at least ``slurm1`` as a node in the group, set additional groups of ``services,cluster,domain`` allows for more diverse group management)::

    metal configure group slurm
    
- Customise ``slurm1`` node configuration (set the primary IP address to 10.10.0.6)::

    metal configure node slurm1

- Create ``/var/lib/metalware/repo/config/slurm1.yaml`` with the following network and server definition::

    slurm:
      is_server: true

- Add the following to ``/var/lib/metalware/repo/config/domain.yaml`` (set ``server`` to the hostname of the SLURM VM)::

    slurm:
      server: slurm1
      is_server: false
      mungekey: ff9a5f673699ba8928bbe009fb3fe3dead3c860c

- Additionally, add the following to the ``setup:`` namespace list in ``/var/lib/metalware/repo/config/domain.yaml``::

    - /opt/alces/install/scripts/06-slurm.sh

- Download the ``slurm.sh`` script to the above location::

    mkdir -p /opt/alces/install/scripts/
    cd /opt/alces/install/scripts/
    wget -O 06-slurm.sh https://raw.githubusercontent.com/alces-software/knowledgebase/release/2017.2/epel/7/slurm/slurm.sh

- Build SLURM RPMs in custom repo (``/opt/alces/repo/custom/Packages``), a guide to building the SLURM RPMs can be found in the `SLURM documentation <https://slurm.schedmd.com/quickstart_admin.html>`_. Once the packages have been moved to the previously mentioned custom repo directory, rebuild the repo with ``createrepo custom``

- Follow :ref:`client-deployment` to setup the SLURM node

.. note:: All systems that are built will have SLURM installed and the SLURM daemon running which will allow that node to submit and run jobs. Should this not be desired then the service can be permanently stopped and disabled with ``systemctl disable slurmd && systemctl stop slurmd`` on the node which is no longer to run SLURM.

Modules Setup (From Deployment VM)
----------------------------------

The environment modules software allows for dynamic path changing on a user profile.

- Create a group for the modules VM (add at least ``apps1`` as a node in the group, set additional groups of ``services,cluster,domain`` allows for more diverse group management)::

    metal configure group apps
    
- Customise ``apps1`` node configuration (set the primary IP address to 10.10.0.7)::

    metal configure node apps1

- Create ``/var/lib/metalware/repo/config/apps1.yaml`` with the following network and server definition::

    modules:
      is_server: true

- Add the following to ``/var/lib/metalware/repo/config/domain.yaml`` (set ``server`` to the IP of the apps VM)::

    modules:
      server: 10.10.0.7
      directory: /opt/apps
      is_server: false

- Additionally, add the following to the ``setup:`` namespace list in ``/var/lib/metalware/repo/config/domain.yaml``::

    - /opt/alces/install/scripts/07-modules.sh

- Download the ``modules.sh`` script to the above location::

    mkdir -p /opt/alces/install/scripts/
    cd /opt/alces/install/scripts/
    wget -O 07-modules.sh https://raw.githubusercontent.com/alces-software/knowledgebase/release/2017.2/epel/7/modules/modules.sh
    
- Follow :ref:`client-deployment` to setup the apps node

.. note:: The apps directory can be setup on the :ref:`storage node <deploy-storage>` if one was created, this allows for all NFS exports to come from a centralised server.
    
