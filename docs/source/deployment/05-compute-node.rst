.. _05-compute-node:

Compute Node Setup
==================

Infiniband Setup
----------------

- Create a configuration file specifically for the nodes group ``/var/lib/metalware/repo/config/nodes.yaml`` with the ib network setup::

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

- If the repo VM was configured then download the Nvidia installer to ``/opt/alces/installers/`` on the repo VM as ``nvidia.run``

.. note:: If no repo VM has been setup then a server definition on the deployment system will need to be setup.

- Download the ``nvidia.sh`` script from the knowledgebase::

    mkdir -p /opt/alces/install/scripts/
    cd /opt/alces/install/scripts/
    wget -O 07-nvidia.sh https://raw.githubusercontent.com/alces-software/knowledgebase/master/epel/7/nvidia/nvidia.sh

.. note:: If the HTTP server has been setup elsewhere then replace ``URL=`` with the path to the directory containing the ``nvidia.run`` script.

- Add the script to the ``scripts:`` namespace list in ``/var/lib/metalware/repo/config/domain.yaml``::

    - /opt/alces/install/scripts/07-nvidia.sh
