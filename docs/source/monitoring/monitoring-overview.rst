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
  - Nagios, an active monitoring system with notifications

Key Files
---------

- ``/etc/ganglia/gmetad.conf``
- ``/etc/ganglia/gmond.conf``
- ``/etc/httpd/conf.d/ganglia``
- ``/var/lib/ganglia/*``
- ``/etc/nagios/*``
- ``/etc/httpd/conf.d/nagios.conf``
- ``/usr/share/nagios/*``
