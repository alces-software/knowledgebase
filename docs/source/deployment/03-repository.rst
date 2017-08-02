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

On Deploy VM
------------

- Add the repo server to ``/opt/metalware/etc/genders``, an example entry is below::

    # SERVICES
    repo1 repo,services,cluster,domain

- Create a deployment file specifically for ``repo1`` at ``/var/lib/metalware/repo/config/repo1.yaml`` with the following content::

    networks:
      pri:
        ip: 10.10.0.2

      mgt:
        defined: false
    
    repoconfig:
      is_server: true

- Add the following to ``/var/lib/metalware/repo/config/domain.yaml`` (the reposerver IP should match the one specified in ``repo1.yaml``)::

    localmirror: true
    repoconfig:
      reposerver: 10.10.0.2
      repopath: repo
      repourl: http://<%= repoconfig.reposerver %>/<%= repoconfig.repopath %>
      is_server: false
    upstreamrepos:
      centos:
        name: centos
        baseurl: http://mirror.ox.ac.uk/sites/mirror.centos.org/7/os/x86_64/
        # description to be used for yum repo [optional] 
        #description: The base CentOS repository
      centos-updates:
        name: centos-updates
        baseurl: http://mirror.ox.ac.uk/sites/mirror.centos.org/7/updates/x86_64/
        # check GPG signatures of packages [optional]
        #gpgcheck: 1
      centos-extras:
        name: centos-extras
        baseurl: http://mirror.ox.ac.uk/sites/mirror.centos.org/7/extras/x86_64/
      epel:
        name: epel
        baseurl: http://anorien.csc.warwick.ac.uk/mirrors/epel/7/x86_64/
        # disable the repository [optional]
        enabled: 0
        # lower the repo priority [optional]
        priority: 11
        # don't skip repo if it isn't available [optional]
        #skip_if_unavailable: 0
    localrepos:
      centos:
        name: centos
        baseurl: <%= repoconfig.repourl %>/centos/
      centos-updates:
        name: centos-updates
        baseurl: <%= repoconfig.repourl %>/centos-updates/
      centos-extras:
        name: centos-extras
        baseurl: <%= repoconfig.repourl %>/centos-extras/
      epel:
        name: epel
        baseurl: <%= repoconfig.repourl %>/epel/
        enabled: 0
        priority: 11
    customrepo:
      custom:
        # custom repo at /opt/alces/repo/custom on the deployment VM for storing any additional RPMs
        name: custom
        baseurl: http://<%= alces.hostip %>/<%= repoconfig.repopath %>/custom/
        # increase the repo priority [optional]
        priority: 1

.. note:: Any repos added to ``domain.yaml`` must include a ``name`` and a ``baseurl`` element. Optionally the repo definitions can include ``description``, ``enabled`` (default: 1), ``skip_if_unavailable`` (default: 1), ``gpgcheck`` (default: 0) and ``priority`` (default: 10) to override the default values that are set when generating the repos.

- Additionally, add the following to the ``setup:`` namespace list in ``/var/lib/metalware/repo/config/domain.yaml``::

    - /opt/alces/install/scripts/00-repos.sh

- Modify ``/var/lib/metalware/repo/kickstart/default``

  - Old line::
  
      #url --url=http://${_ALCES_BUILDSERVER}/${_ALCES_CLUSTER}/repo/centos/
      url --url=http://mirror.ox.ac.uk/sites/mirror.centos.org/7/os/x86_64/
  
  - New line::
  
      <% if localmirror -%>
      url --url=<%= repoconfig.repourl %>/centos/
      <% else -%>
      url --url=http://mirror.ox.ac.uk/sites/mirror.centos.org/7/os/x86_64/
      <% end -%>

- Download the ``repos.sh`` script to the above location::

    mkdir -p /opt/alces/install/scripts/
    cd /opt/alces/install/scripts/
    wget  -O 00-repos.sh https://raw.githubusercontent.com/alces-software/knowledgebase/master/epel/7/repo/repos.sh

.. note:: The script is renamed to ``00-repos.sh`` to guarantee that it is run before any other setup scripts.

- Follow :ref:`client-deployment` to setup the repo node

- The repo VM will now be up and can be logged in with passwordless SSH from the deployment VM and will have a clone of the CentOS upstream repositories locally.

Custom Repository Setup
-----------------------

The above configuration will allow the deployment VM to be configured as a local custom repository (even if local upstream mirrors are not being created). The purpose of this repository is to provide packages to the network that aren't available in upstream repositories or require higher installation priority than other available packages (e.g. a newer kernel package).

To setup the custom repo, run the following command from the deployment VM::

    metal render /opt/alces/install/scripts/00-repos.sh metalware |/bin/bash
