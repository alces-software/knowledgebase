.. _03-repository:

Repository Mirror Server
========================

On Master Node
--------------

- Create ``/opt/vm/repo.xml`` for deploying the repo VM (:download:`Available here <repo.xml>`)

- Create disk image for the repo VM::

    qemu-img create -f qcow2 repo.qcow2 150G

- Define the VM::

    virsh define repo.xml

.. _deploy-repo:

On Controller VM
----------------

- Create a group for the repo VM (add at least ``repo1`` as a node in the group, set additional groups of ``services,cluster,domain`` allows for more diverse group management)::

    metal configure group repo
    
- Customise ``repo1`` node configuration (set the primary IP address to 10.10.0.2)::

    metal configure node repo1

- Create a deployment file specifically for ``repo1`` at ``/var/lib/metalware/repo/config/repo1.yaml`` with the following content::

    repoconfig:
      is_server: true

- Add the following to ``/var/lib/metalware/repo/config/domain.yaml`` (``build_url`` is the URL for client kickstart builds to use, ``source_repos`` should be a comma-separated list of source files that `repoman <https://github.com/alces-software/repoman>`_ will use to generate client configurations, ``clientrepofile`` will need to be a URL to a repo config file for the client to curl)::

    repoconfig:
      # Repostiroy URL for kickstart builds
      build_url: http://mirror.ox.ac.uk/sites/mirror.centos.org/7/os/x86_64/
      # If true, this server will host a client config file for the network
      is_server: false
      # Repoman source files for repository mirror server to use (comma separate)
      source_repos: base.upstream
      # The file for clients to curl containing repository information [OPTIONAL]
      # clientrepofile: http://myrepo.com/repo/client.repo
      clientrepofile: false

.. note:: See the repoman project page for the included repository template files. To add customised repositories, create them in ``/var/lib/repoman/templates/centos/7/`` on the repository server.

- Additionally, add the following to the ``setup:`` namespace list in ``/var/lib/metalware/repo/config/domain.yaml``::

    - /opt/alces/install/scripts/00-repos.sh

- Download the ``repos.sh`` script to the above location::

    mkdir -p /opt/alces/install/scripts/
    cd /opt/alces/install/scripts/
    wget  -O 00-repos.sh https://raw.githubusercontent.com/alces-software/knowledgebase/master/epel/7/repo/repos.sh

.. note:: The script is renamed to ``00-repos.sh`` to guarantee that it is run before any other setup scripts.

- Follow :ref:`client-deployment` to setup the repo node

- The repo VM will now be up and can be logged in with passwordless SSH from the controller VM and will have a clone of the CentOS upstream repositories locally. Modify ``build_url`` in ``/var/lib/metalware/repo/config/domain.yaml`` to be the, now built, repo server's URL so that new client builds will use that repository.

Custom Repository Setup
-----------------------

As well as using different sources for the upstream repositories it is beneficial to have a local repository that can be used to serve additional packages which are not part of upstream repos to clients. This will be known as the custom repository, details on setting up the custom repository are below. The purpose of this repository is to provide packages to the network that aren't available in upstream repositories or require higher installation priority than other available packages (e.g. a newer kernel package).

- Install package dependencies::

    yum -y install createrepo httpd yum-plugin-priorities yum-utils

- Create custom repository directory::

    mkdir -p /opt/alces/repo/custom/

- Define the repository::

    cd /opt/alces/repo/
    createrepo custom

- Create a repo source file to be served to clients at ``/var/lib/repoman/templates/centos/7/custom.local``::

    [custom]
    name=custom
    baseurl=http://myrepo.com/repo/custom/
    description=Custom repository local to the cluster
    enabled=1
    skip_if_unavailable=1
    gpgcheck=0
    priority=1

- Add the custom repository to the source repos in ``/var/lib/metalware/repo/config/domain.yaml``::
   
    repoconfig:
       # Repostiroy URL for kickstart builds
       build_url: http://mirror.ox.ac.uk/sites/mirror.centos.org/7/os/x86_64/
       # If true, this server will host a client config file for the network
       is_server: false
       # Repoman source files for repository mirror server to use (comma separate)
       source_repos: base.upstream,custom.local
       # The file for clients to curl containing repository information [OPTIONAL]
       # clientrepofile: http://myrepo.com/repo/client.repo
       clientrepofile: false
