.. _user-management-guidelines:

Recommendations for User Management
===================================

NIS Server Setup
----------------

On Master Node
^^^^^^^^^^^^^^

- Create ``/opt/vm/nis.xml`` for deploying the nis VM (:download:`Available here <nis.xml>`)

- Create disk image for the nis VM::

    qemu-img create -f qcow2 nis.qcow2 80G

- Define the VM::

    virsh define nis.xml

.. _deploy-user:

On Controller VM
^^^^^^^^^^^^^^^^

- Create a group for the nis VM (add at least ``nis1`` as a node in the group, set additional groups of ``services,cluster,domain`` allows for more diverse group management)::

    metal configure group nis
    
- Customise ``nis1`` node configuration (set the primary IP address to 10.10.0.4)::

    metal configure node nis1

- Create a deployment file specifically for ``nis1`` at ``/var/lib/metalware/repo/config/nis1.yaml`` with the following content::

    nisconfig:
      is_server: true

- Add the following to ``/var/lib/metalware/repo/config/domain.yaml`` (the nisserver IP should match the one specified in ``nis1.yaml``): ::

    nisconfig:
      nisserver: 10.10.0.4
      nisdomain: nis.<%= domain %>
      is_server: false
      # specify non-standard user directory [optional]
      users_dir: /users

- Additionally, add the following to the ``setup:`` namespace list in ``/var/lib/metalware/repo/config/domain.yaml``::

    - /opt/alces/install/scripts/02-nis.sh

- Download the ``nis.sh`` script to the above location::

    mkdir -p /opt/alces/install/scripts/
    cd /opt/alces/install/scripts/
    wget -O 02-nis.sh https://raw.githubusercontent.com/alces-software/knowledgebase/master/epel/7/nis/nis.sh

- Follow :ref:`client-deployment` to setup the compute nodes

