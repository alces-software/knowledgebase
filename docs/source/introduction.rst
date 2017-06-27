.. _infrastructure-guide:

Introduction
============

The purpose of this documentation is to provide a list of considerations and guidelines for the development of a HPC environment. This documentation should be followed through in order to properly understand the structure of the environment and that certain considerations are not missed out along the way.

To generalise the entire process, it goes as follows::

    Hardware Architecture Design -> Hardware Build -> Software Build -> Platform Delivery

Ensuring that a suitable hardware and network architecture is designed before the build process creates a stable base for the HPC platform. 

Performing the hardware build before doing any software configuration guarantees that the network and hardware is properly setup. A partially built network during software setup can lead to unforeseen issues with communication and configuration.

Once the infrastructure has been physically built the software build can proceed. Usually the central servers will be configured first before client and compute nodes are configured.

.. note:: It is recommended to read through all of the documentation before starting to design the HPC platform to understand the scope and considerations.
