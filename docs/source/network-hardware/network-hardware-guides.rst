.. _network-hardware-guides:

Recommendations for Network and Hardware Design
===============================================

At Alces software, the recommended network design differs slightly depending on the number of users and quantity of systems within the HPC platform. 

Network Designs
---------------

With the :ref:`Network and Hardware Design Considerations<network-hardware-considerations>` in mind, diagrams of different networks are below. They increase in complexity and redundancy as the list goes on.

Example 1
^^^^^^^^^

.. image:: NodeTypes1.png
    :alt: Node Types Example 1

The above network consists of master, login and compute nodes. The services provided by the master & login nodes can be seen to the right of each node type. This network only separates the services for users and admins.

Example 2
^^^^^^^^^

.. image:: NodeTypes2.png
    :alt: Node Types Example 2

This network provides additional redundancy to the services running on the master node. For example, the disk array is connected to both master nodes which use multipath to ensure the higher availability of the storage device. 

Example 3
^^^^^^^^^

.. image:: NodeTypes3.png
    :alt: Node Types Example 3

This network puts services inside of VMs to improve the ability to migrate and modify services with little impact to the other services and systems on the network. Virtual machines can be moved between VM hosts live without service disruption allowing for hardware replacements to take place on servers.