.. _storage-considerations:

Considerations for Storage Solution
===================================

Storage Hardware
----------------

When selecting the storage solution it is worth considering the size, performance and resilience of the desired storage solution. Usually some sort of storage array will be used, that is, a collection of disks (otherwise known as JBOD - Just a Bunch Of Disks) in the form of an internal or external RAID array.

Network Storage Solutions
-------------------------

Single server w/ NFS
^^^^^^^^^^^^^^^^^^^^

.. image:: SingleServerNFS.png
    :alt: Single Server with NFS

In this example, a single server is connected to a RAID 6 storage array which it is serving over NFS to the systems on the network. While simple in design and implementation, this design only provides redundancy at the RAID level.

Multiple Servers w/ NFS
^^^^^^^^^^^^^^^^^^^^^^^

.. image:: MultiServerNFS.png
    :alt: Multi Server with NFS

In addition to the previous example, this setup features multiple storage servers which balance the load of serving the disk over NFS.

Multiple Servers w/ Lustre
^^^^^^^^^^^^^^^^^^^^^^^^^^

.. image:: MultiServerLustre.png
    :alt: Multi Server with Lustre

This setup features multiple RAID sets which sit externally to the storage servers and are connected to both of them using multipath - this allows for multiple paths to the storage devices to be utilised. On top of this, a Lustre volume has been configured which consists of all the external disks, authorisation of access to the storage volume is managed by the metadata node.

Additional Considerations and Questions
---------------------------------------

  - What data will need to be centrally stored?
  - Where will data be coming from?
  
    - Are source files created within the HPC network or do they exist in the external network?
    - Will compute nodes be writing out logs/results from running jobs?
    - Where else might data be coming from?
    
  - Is scratch space needed?
  - What level of redundancy/stability is required for the data?
  - How will the data be backed up?
  
    - Will there be off-site backups?
    - Should a separate storage medium be used?
    - Does all the data need backing up or only certain files?
