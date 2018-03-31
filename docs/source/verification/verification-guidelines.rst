.. _verification-guidelines:

Recommendations for HPC Platform Verification
=============================================

Checking System Configuration
-----------------------------

For the system configuration (depending on which previous sections have been configured), the cluster administrator should verify the following settings: 

- Clocks - The current date/time is correct on all machines; clients are syncing with the controller
- User Login - Users from the chosen verification method can login to:

  - Infrastructure node(s) (should be possible for admin users only)
  - Login node(s)
  - Compute node(s)

- Storage system mounts - Mounted with correct mount options and permissions
- Job-scheduler - Jobs can be submitted and are run; nodes are all present and available on the queue
- Ganglia - All nodes present, metrics are logging
- Nagios - All nodes present, services are in positive state


Checking Hardware Configuration
-------------------------------

Benchmarking Software
^^^^^^^^^^^^^^^^^^^^^

For general notes on running memtester, IOZone, IMB and HPL see - https://github.com/alces-software/knowledgebase/wiki/Burn-in-Testing

Further details can be found at:

  - `Memtester <https://github.com/alces-software/knowledgebase/wiki/Burn-In-Tests:-Memtester>`_
  - `IOZone <https://github.com/alces-software/knowledgebase/wiki/Burn-In-Tests:-IOZone>`_
  - `IMB <https://github.com/alces-software/knowledgebase/wiki/Burn-In-Tests:-IMB>`_
  - `HPL <https://github.com/alces-software/knowledgebase/wiki/Burn-In-Tests:-HPL>`_

Hardware Information
^^^^^^^^^^^^^^^^^^^^

- Check CPU type::

    pdsh -g groupname 'grep -m 1 name /proc/cpuinfo'

- Check CPU count::

    pdsh -g groupname 'grep processor /proc/cpuinfo |wc -l'

- Check RAID active::

    pdsh -g groupname 'cat /proc/mdstat | grep md[0-1]'

- Check Infiniband up/active::

    pdsh -g groupname 'ibstatus |grep phys'

- Check free memory::

    pdsh -g groupname 'free -m |grep ^Mem'

- Check GPU type and count::

    pdsh -g groupname 'nvidia-smi'

- Grab serial numbers::

    pdsh -g groupname 'dmidecode -t baseboard |grep -i serial'


