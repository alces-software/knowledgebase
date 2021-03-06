.. _flightcenter:

Flight Center - Managed Machine Configuration
=============================================

Before proceeding with the Flight Center setup, ensure that the **controller**:

  - :ref:`Has been configured as a Ganglia server <deploy-monitor>`.
  - Is connected to Flight Center VPN

A managed cluster can be integrated with Flight Center by:

- Adding the following parameters to ``/var/lib/metalware/repo/config/domain.yaml``::

    flightcenter:
      archivedir: '/mnt/data1/users'
      sharedscratchdir: '/mnt/lustre/users'
      localscratchdir: '/tmp/users/'
      # mailserver: flightcenter-mail.flightcenter.alces-flight.com
      mailserver: 10.78.0.15
      # ntpserver: flightcenter-mail.flightcenter.alces-flight.com
      ntpserver: 10.78.0.15

- Adding the script reference to the ``scripts:`` namespace in ``/var/lib/metalware/repo/config/domain.yaml``::

    - /opt/alces/install/scripts/20-flightcenter.sh

- Downloading the script to the above location::

    mkdir -p /opt/alces/install/scripts/
    cd /op/alces/install/scripts/
    wget -O 20-flightcenter.sh https://raw.githubusercontent.com/alces-software/knowledgebase/master/epel/7/flight/flightcenter.sh

What this script does is:

  - Sets terminal prompt to display the cluster name [on all nodes]
  - Sets up temporary scratch directories for the users [on all nodes]
  - Connects to the Flight Center NTP server [controller only]
  - Connects to the Flight Center Mail relay [controller only]
  - Connects to the Flight Center Ganglia server [controller only]

