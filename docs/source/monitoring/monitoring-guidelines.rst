.. _monitoring-guidelines:

Recommendations for Monitoring the HPC Platform
===============================================

Setting Up Monitor Server (Ganglia & Nagios)
--------------------------------------------

On Master Node
^^^^^^^^^^^^^^

- Create ``/opt/vm/monitor.xml`` for deploying the storage VM (:download:`Available here <monitor.xml>`)

- Create disk image for the monitor VM::

    qemu-img create -f qcow2 monitor.qcow2 80G

- Define the VM::

    virsh define monitor.xml

.. _deploy-monitor:

On Controller VM
^^^^^^^^^^^^^^^^

- Create a group for the monitor VM (add at least ``monitor1`` as a node in the group, set additional groups of ``services,cluster,domain`` allows for more diverse group management)::

    metal configure group monitor
    
- Customise ``monitor1`` node configuration (set the primary IP address to 10.10.0.5)::

    metal configure node monitor1

- Create ``/var/lib/metalware/repo/config/monitor1.yaml`` with the following network and server definition::

    ganglia:
      is_server: true
      
    nagios:
      is_server: true

- Add the following to ``/var/lib/metalware/repo/config/domain.yaml``::

    ganglia:
      server: 10.10.0.5
      is_server: false
    nagios:
      is_server: false

- Additionally, add the following to the ``setup:`` namespace list in ``/var/lib/metalware/repo/config/domain.yaml``::

    - /opt/alces/install/scripts/03-ganglia.sh
    - /opt/alces/install/scripts/04-nagios.sh

- Download the ``ganglia.sh`` and ``nagios.sh`` scripts to the above location::

    mkdir -p /opt/alces/install/scripts/
    cd /opt/alces/install/scripts/
    wget -O 03-ganglia.sh https://raw.githubusercontent.com/alces-software/knowledgebase/master/epel/7/ganglia/ganglia.sh
    wget -O 04-nagios.sh https://raw.githubusercontent.com/alces-software/knowledgebase/master/epel/7/nagios/nagios.sh

- Follow :ref:`client-deployment` to setup the compute nodes

This will setup minimal installations of both Ganglia and Nagios. All nodes within the domain will be built to connect to these services such that they can be monitored. It is possible to expand upon the metrics monitored and notification preferences.

Once deployed, both Ganglia and Nagios services can be further configured and customised to deliver the metrics and notifications that you require. Review the documentation for each of the projects for assistance in settings up these tools. 
