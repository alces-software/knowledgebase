.. _04-first-boot:

First Boot Script Environment Setup
===================================

- Setting up the first boot script environment allows for things like Nvidia drivers and other installers to execute at boot time on a node in the correct environment

- Download the first run script from the knowledgebase::

    mkdir -p /opt/alces/install/scripts/
    cd /opt/alces/install/scripts/
    wget -O 05-firstrun.sh https://raw.githubusercontent.com/alces-software/knowledgebase/master/epel/7/firstrun/firstrun.sh

- Add the script to the beginning of the ``scripts:`` namespace in ``/var/lib/metalware/repo/config/domain.yaml``::

    - /opt/alces/install/scripts/05-firstrun.sh

Creating a First Boot Script
----------------------------

A first boot script is made up of a couple of components:

  - Setup script
  - First run script

Setup Script
^^^^^^^^^^^^

This script will run as part of the node build procedure and will be used to put the first run script into the correct location to be executed at boot time. 

- Create a script like the following example (replace ``myfile.bash`` with the name of the program and between ``cat`` and ``EOF`` with the installation commands)::

    cat << EOF > /var/lib/firstrun/scripts/myfile.bash
    curl http://www.system-driver.com/downloads/installer.sh > /tmp/installer.sh
    sh /tmp/installer.sh --quiet
    EOF

- The above script can then be saved somewhere under ``/opt/alces/install/scripts/`` on the deployment VM

- In ``/var/lib/metalware/repo/config/domain.yaml`` (or a group/node specific config file) add the path to the script in the ``setup:`` namespace

First Run Script
^^^^^^^^^^^^^^^^

In the example setup script above it creates a file called ``/var/lib/firstrun/scripts/myfile.bash`` which is the first run script. Any files ending with ``.bash`` in ``/var/lib/firstrun/scripts`` will be executed on the first boot of the node. 
