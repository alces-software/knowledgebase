.. _hpc-environment-guidelines:

Recommendations for HPC Environment Design
==========================================

SLURM Setup (From Deployment VM)
--------------------------------

- Add the slurm server to ``/opt/metalware/etc/genders``, an example entry is below::

    # SERVICES
    slurm slurm,services,cluster,domain

- Create ``/var/lib/metalware/repo/config/slurm.yaml`` with the following network and server definition::

    networks:
      pri:
        ip: 10.10.0.6
      
      mgt:
        defined: false
    
    slurm:
      is_server: true

- Add the following to ``/var/lib/metalware/repo/config/domain.yaml`` (set ``server`` to the hostname of the SLURM VM)::

    slurm:
      server: slurm
      is_server: false
      mungekey: ff9a5f673699ba8928bbe009fb3fe3dead3c860c

- Additionally, add the following to the ``setup:`` namespace list in ``/var/lib/metalware/repo/config/domain.yaml``::

    - /opt/alces/install/scripts/06-slurm.sh

- Download the ``slurm.sh`` script to the above location::

    mkdir -p /opt/alces/install/scripts/
    cd /opt/alces/install/scripts/
    wget -O 06-slurm.sh https://raw.githubusercontent.com/alces-software/knowledgebase/master/epel/7/slurm/slurm.sh

- Build SLURM RPMs in custom repo (``/opt/alces/repo/custom/Packages``), a guide to building the SLURM RPMs can be found in the `SLURM documentation <https://slurm.schedmd.com/quickstart_admin.html>`_. Once the packages have been moved to the previously mentioned custom repo directory, rebuild the repo with ``createrepo custom``

- Follow :ref:`client-deployment` to setup the SLURM node

Modules Setup (From Deployment VM)
----------------------------------

The environment modules software allows for dynamic path changing on a user profile.

- Add the apps server to ``/opt/metalware/etc/genders``, an example entry is below::

    # SERVICES
    apps1 apps,services,cluster,domain

- Create ``/var/lib/metalware/repo/config/apps1.yaml`` with the following network and server definition::

    networks:
      pri:
        ip: 10.10.0.7
      
      mgt:
        defined: false
    
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
    wget -O 07-modules.sh https://raw.githubusercontent.com/alces-software/knowledgebase/master/epel/7/modules/modules.sh
    
- Follow :ref:`client-deployment` to setup the apps node

.. note:: The apps directory can be setup on the :ref:`storage node <deploy-storage>` if one was created, this allows for all NFS exports to come from a centralised server.
    