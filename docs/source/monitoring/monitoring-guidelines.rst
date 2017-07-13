.. _monitoring-guidelines:

Recommendations for Monitoring the HPC Platform
===============================================

Setting Up Ganglia Server
-------------------------

On Master Node
^^^^^^^^^^^^^^

- Create ``/opt/vm/monitor.xml`` for deploying the storage VM (:download:`Available here <monitor.xml>`)

- Create disk image for the monitor VM::

    qemu-img create -f qcow2 monitor.qcow2 80G

- Define the VM::

    virsh define monitor.xml

On Deploy VM
^^^^^^^^^^^^

- Add the monitor server to ``/opt/metalware/etc/genders``, an example entry is below::

    # SERVICES
    monitor1 monitor,services,cluster,domain

- Create ``/var/lib/metalware/repo/config/monitor1.yaml`` with the following network and server definition::

    networks:
      pri:
        ip: 10.10.0.5
      
      mgt:
        defined: false
    
    ganglia:
      is_server: true

- Add the following to ``/var/lib/metalware/repo/config/domain.yaml``::

    ganglia:
      server: 10.10.0.5
      is_server: false

- Additionally, add the following to the ``setup:`` namespace list in ``/var/lib/metalware/repo/config/domain.yaml``:::

    - /opt/alces/install/scripts/ganglia.sh

- Download the ``ganglia.sh`` script to the above location::

    mkdir -p /opt/alces/install/scripts/
    cd /opt/alces/install/scripts/
    wget https://raw.githubusercontent.com/alces-software/knowledgebase/master/epel/7/ganglia/ganglia.sh

- Follow :ref:`client-deployment` to setup the compute nodes


