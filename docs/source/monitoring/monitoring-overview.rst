.. _monitoring-overview:

Monitoring Overview
===================

About
-----

This package will configure a monitoring master system with metric collection services and a web front-end. Slave nodes will have the client monitoring service setup to send metrics to the master system.

Components
----------

The monitoring system will provide the following applications:

  - Ganglia, a passive monitoring system with metric graphs
  
      - Clients send metrics to the Ganglia host system which are plotted on graphs for viewing data trends for the environment. The data is available through both a command-line utility and a web interface.
  
  - Nagios, an active monitoring system with notifications
  
      - Nagios clients are configured on the server and are not required to run client software unless additional metrics are needed. The system will actively monitor metrics and if the values go over a predefined, customisable threshold.

Key Files
---------

- ``/etc/ganglia/gmetad.conf``
- ``/etc/ganglia/gmond.conf``
- ``/etc/httpd/conf.d/ganglia``
- ``/var/lib/ganglia/*``
- ``/etc/nagios/*``
- ``/etc/httpd/conf.d/nagios.conf``
- ``/usr/share/nagios/*``
