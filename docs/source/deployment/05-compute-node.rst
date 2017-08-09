.. _05-compute-node:

Compute Node Setup
==================

Infiniband Setup
----------------

- Create a configuration file specifically for the nodes group ``/var/lib/metalware/repo/config/nodes.yaml`` with the ib network setup::

    networks:
      ib:
        defined: true
        ib_use_installer: false
        mellanoxinstaller: http://route/to/MLNX_OFED_LINUX-x86_64.tgz
        ip: 

.. note:: If you want to install the Mellanox driver (and not use the IB drivers from the CentOS repositories), set ``ib_use_installer`` to ``true`` and set ``mellanoxinstaller`` to the location of the mellanox OFED installer.

- Download the ``infiniband.sh`` script from the knowledgebase::

    mkdir -p /opt/alces/install/scripts/
    cd /opt/alces/install/scripts/
    wget -O 06-infiniband.sh https://raw.githubusercontent.com/alces-software/knowledgebase/master/epel/7/infiniband/infiniband.sh

- Add the script to the ``scripts:`` namespace list in ``/var/lib/metalware/repo/config/domain.yaml``::

    - /opt/alces/install/scripts/06-infiniband.sh

- Follow :ref:`client-deployment` to setup the compute nodes

Nvidia Driver Setup
-------------------

- This requires the :ref:`First Boot Script Environment <04-first-boot>` to be setup

- Download the Nvidia installer to ``/opt/alces/installers/`` on the deployment VM as ``nvidia.run``

- Download the ``nvidia.sh`` script from the knowledgebase::

    mkdir -p /opt/alces/install/scripts/
    cd /opt/alces/install/scripts/
    wget -O 07-nvidia.sh https://raw.githubusercontent.com/alces-software/knowledgebase/master/epel/7/nvidia/nvidia.sh

- Add the script to the ``scripts:`` namespace list in ``/var/lib/metalware/repo/config/domain.yaml``::

    - /opt/alces/install/scripts/07-nvidia.sh

- To run the installer on all nodes in a group (for example, ``gpunodes``) add the following line to the group's config file (in this example, ``/var/lib/metalware/config/gpunodes.yaml``)::

    nvidia: true
