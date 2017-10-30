.. _vm-deployment:

Deploy VMs From Controller
==========================

On Controller VM
----------------

- Create a group for the VMs (this example will create a group for infrastructure VMs within the additional groups of ``services,cluster,domain`` and containing the nodes ``infra[1-3]``)::

    metal configure group infra

- Create a deployment file for the ``infra`` group at ``/var/lib/metalware/repo/config/infra.yaml`` with the following content::

    vm:
      master: 10.101.0.50
      virtpool: /opt/vm/
      nodename: "<%= alces.nodename %>-<%= cluster %>"
      primac: 52:54:00:78:<%= '%02x' % alces.group_index %>:<%= '%02x' % alces.index %>
      extmac: 52:54:00:78:<%= '%02x' % (alces.group_index + 1) %>:<%= '%02x' % alces.index %>
      vncpassword: 'password'
      disksize: 250

- Additionally, download the VM creation script to ``/opt/alces/install/scripts/vm.sh``::

    mkdir -p /opt/alces/install/scripts/
    cd /opt/alces/install/scripts/
    wget https://raw.githubusercontent.com/alces-software/knowledgebase/master/epel/7/libvirt/vm.sh

.. note:: Ensure that passwordless SSH is configured from the controller to the system set as ``vm.master`` in the configuration file before running the script

- Run the script for a node::

    metal render /opt/alces/install/scripts/vm.sh infra1 |/bin/bash

- Alternatively, run the script for the entire group::

    metal each -g infra 'metal render /opt/alces/install/scripts/vm.sh <%= alces.nodename %> |/bin/bash'

- The above will create the virtual machines, these will then need to be started (from the VM master with ``virsh start infra1-testcluster``) and the metal build command run to grab them for the build::

    metal build infra1

