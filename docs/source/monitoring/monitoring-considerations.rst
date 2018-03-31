.. _monitoring-considerations:

Considerations for Monitoring the HPC Platform
==============================================

Types of Monitoring
-------------------

There are 2 types of monitoring that can be implemented into a network; these are:

  - **Passive** - Passive monitoring tools collect data and store from systems. Usually this data will be displayed in graphs and is accessible either through command-line or web interfaces. This sort of monitoring is useful for historical metrics and live monitoring of systems.
  - **Active** - Active monitoring collects and checks metrics; it will then send out notifications if certain thresholds or conditions are met. This form of monitoring is beneficial for ensuring the health of systems; for example, email notifications can be sent out when systems start overheating or if a system is no longer responsive.

Both forms of monitoring are usually necessary in order to ensure that your HPC cluster is running properly, and in full working order.

Metrics
-------

It is worth considering what metrics for the system will be monitored; a few common ones are listed here:

  - CPU
  
    - Load average
    - Idle percentage
    - Temperature
    
  - Memory
  
    - Used 
    - Free
    - Cached
  
  - Disk
  
    - Free space
    - Used space
    - Swap (free/used/total)
    - Quotas (if configured)
  
  - Network
  
    - Packets in
    - Packets out

.. note:: Cloud service providers usually have both passive and active monitoring services available through their cloud management front-end.

Additional Considerations and Questions
---------------------------------------

- What metrics should be monitored?
- How frequently should metrics be checked?
- What level of notification is required?

  - Escalation upon repeated errors?
  - Acknowledgement of long-running outages?
  - How do we avoid over-saturation of notifications during major outages?
  - What tests will we run to ensure that notifications are working properly?
