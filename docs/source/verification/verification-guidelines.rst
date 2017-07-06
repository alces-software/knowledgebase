.. _verification-guidelines:

Recommendations for HPC Platform Verification
=============================================

For general notes on running memtester, IOZone, IMB and HPL see - https://github.com/alces-software/knowledgebase/wiki/Burn-in-Testing

Further details can be found at:

  - `Memtester <https://github.com/alces-software/knowledgebase/wiki/Burn-In-Tests:-Memtester>`_
  - `IOZone <https://github.com/alces-software/knowledgebase/wiki/Burn-In-Tests:-IOZone>`_
  - `IMB <https://github.com/alces-software/knowledgebase/wiki/Burn-In-Tests:-IMB>`_
  - `HPL <https://github.com/alces-software/knowledgebase/wiki/Burn-In-Tests:-HPL>`_


Checking Hardware and Software Configuration
--------------------------------------------

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



