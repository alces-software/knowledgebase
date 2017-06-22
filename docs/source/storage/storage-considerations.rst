.. _storage-considerations:

Considerations for Storage Solution
===================================

Storage Hardware
----------------

When selecting the storage solution it is worth considering the size, performance and resilience of the desired storage solution. Usually some sort of storage array will be used, that is, a collection of disks (otherwise known as JBOD - Just a Bunch Of Disks) in the form of an internal or external RAID array.


Network Storage Solutions
-------------------------

- Single server w/ NFS (internal or external RAID 6 array)
- 2 servers w/ NFS (external RAID 6 array - SAS expanders from servers connect to the array)
- 2 servers w/ parallel file system (same as above but with additional hardware and software config)

.. note:: GFS is used for storing VM images when high availability VM solution is being used.

Storage Array
- RAID card
- separate JBOD [what technology is this called?]

Storage Server Connection
- PCI (for RAID card)
- iSCSI (for separate JBOD) - This allows for multipathing, correct?

Network Export
- NFS
- GFS
- Parallel


Additional Considerations and Questions
---------------------------------------

  - What data will need to be centrally stored?
  - Where will data be coming from?
  
    - Are source files created within the HPC network or do they exist in the external network?
    - Will compute nodes be writing out logs/results from running jobs?
    - Where else might data be coming from?
    
  - Is scratch space needed?
  - What level of redundancy/stability is required for the data?
