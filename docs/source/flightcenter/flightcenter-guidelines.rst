.. _flightcenter:

Flight Center - Managed Machine Configuration
=============================================

Before proceeding with the Flight Center setup, ensure that the:

  - :ref:`Ganglia server has been configured <deploy-monitor>`.
  - Connect the controller system to Flight Center VPN

A managed cluster can be integrated with Flight Center by:

- Adding the following parameters to ``/var/lib/metalware/repo/config/domain.yaml``::

  flightcenter:
    archivedir: '/mnt/data1/users'
    sharedscratchdir: '/mnt/lustre/users'
    localscratchdir: '/tmp/users/'
    mailserver: flightcenter-mail.flightcenter.alces-flight.com
    ntpserver: flightcenter-mail.flightcenter.alces-flight.com
    gangliaserver: flightcenter-ganglia.flightcenter.alces-flight.com


- Adding the script reference to the ``scripts:`` namespace in ``/var/lib/metalware/repo/config/domain.yaml``::

  - /opt/alces/install/scripts/20-flightcenter.sh

- Downloading the script to the above location::

  mkdir -p /opt/alces/install/scripts/
  cd /op/alces/install/scripts/
  wget -O 20-flightcenter.sh https://raw.githubusercontent.com/alces-software/knowledgebase/master/epel/7/flightcenter/flightcenter.sh

What this script does is:

  - Sets terminal prompt to display the cluster name [on all nodes]
  - Sets up temporary scratch directories for the users [on all nodes]
  - Connects to the Flight Center NTP server [controller only]
  - Connects to the Flight Center Mail relay [controller only]
  - Connects to the Flight Center Ganglia server [controller only]

