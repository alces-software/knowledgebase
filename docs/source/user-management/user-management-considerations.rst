.. _user-management-considerations:

Considerations for User Management
==================================

User Authentication
-------------------

User authentication is usually performed in a server/client setup inside the HPC environment due to the unnecessary overhead of manually maintaining ``/etc/passwd`` on a network of nodes. A few options for network user management are:

  - **NIS** - The Network Information Service (NIS) is a directory service that enables the sharing of user and host information across a network. 
  - **FreeIPA** - FreeIPA provides all the information that NIS does as well as providing application and service information to the network. Additionally, FreeIPA uses directory structure such that information can be logically stored in a tree-like structure. It also comes with a web interface for managing the solution.
  - Connecting to an **externally-managed** user-authentication service (e.g. LDAP, active-directory). This option is not recommended, as a large HPC cluster can put considerable load on external services. Using external user-authentication also creates a dependancy for your cluster on another service, complicating troubleshooting and potentially impacting service availability. 
  
.. note:: If the user accounts need to be consistent with accounts on the external network then the master node should have a slave service to the external networks account management system. This will allow the account information to be forwarded to the HPC network, without creating a hard-dependancy on an external authentication service. 

User Access
-----------

It is also worth considering how users will be accessing the system. A few ways that users can be accessing and interacting with the HPC environment are:

  - **SSH** - This is the most common form of access for both users and admins. SSH will provide terminal-based access and X forwarding capabilities to the user. 
  - **VNC** - The VNC service creates a desktop session that can be remotely connected to by a user, allowing them to run graphical applications inside the HPC network. 
  - **VPN** - A VPN will provide remote network access to the HPC environment. This can be especially useful when access to the network is required from outside of the external network. Once connected to the VPN service, SSH or VNC can be used as it usually would be. 

.. note:: If running firewall services within the environment (recommended) then be sure to allow access from the ports used by the selected user access protocols.

Additional Considerations and Questions
---------------------------------------

- What information will need to be shared between the systems?
- How will users want to access the system?
