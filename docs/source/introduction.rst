.. _infrastructure-guide:

Introduction
============

The purpose of this documentation is to provide a list of considerations and guidelines for the development of a High Performance Computing (HPC) environment. This documentation should be followed through in order to properly understand the structure of the environment and that certain considerations are not missed out along the way.

To generalise the entire process, it goes as follows::

    Hardware Architecture Design -> Hardware Build -> Software Build -> Platform Delivery

Ensuring that a suitable hardware and network architecture is designed before the build process begins will allow you to create a stable base for your HPC platform. 

Performing the hardware build before doing any software configuration guarantees that the network and hardware is properly setup. A partially built network during software setup can lead to unforeseen issues with communication and configuration.

Once the infrastructure has been physically built the software build can proceed. Usually the central servers will be configured first before client and compute nodes are configured.

Finally, platform delivery includes a range of connectivity, performance and quality tests which ensure that the completed environment is stable, manageable and consistent. 

.. note:: It is recommended to read through all of the documentation before starting to design the HPC platform to understand the scope and considerations.
