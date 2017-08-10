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
