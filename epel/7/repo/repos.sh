#!/bin/bash
#(c)2017 Alces Software Ltd. HPC Consulting Build Suite
#Job ID: <JOB>
#Cluster: <CLUSTER>

REPOSERVER=10.10.0.1
REPOPATH=repo

UPSTREAMCONF=`cat << EOF
[centos]
name=CentOS Base
baseurl=http://mirror.ox.ac.uk/sites/mirror.centos.org/7/os/x86_64/
enabled=1
skip_if_unavailable=1
gpgcheck=0
priority=10

[centos-updates]
name=CentOS Updates
baseurl=http://mirror.ox.ac.uk/sites/mirror.centos.org/7/updates/x86_64/
enabled=1
skip_if_unavailable=1
gpgcheck=0
priority=10

[centos-extras]
name=CentOS Extras
baseurl=http://mirror.ox.ac.uk/sites/mirror.centos.org/7/extras/x86_64/
enabled=1
skip_if_unavailable=1
gpgcheck=0
priority=10

[epel]
name=Epel
baseurl=http://anorien.csc.warwick.ac.uk/mirrors/epel/7/x86_64/
enabled=0
skip_if_unavailable=1
gpgcheck=0
priority=11
EOF`

LOCALCONF=`cat << EOF
[centos]
name=CentOS Base
baseurl=http://$REPOSERVER/$REPOPATH/centos/
enabled=1
skip_if_unavailable=1
gpgcheck=0
priority=10

[centos-updates]
name=CentOS Updates
baseurl=http://$REPOSERVER/$REPOPATH/centos-updates/
enabled=1
skip_if_unavailable=1
gpgcheck=0
priority=10

[centos-extras]
name=CentOS Extras
baseurl=http://$REPOSERVER/$REPOPATH/centos-extras/
enabled=1
skip_if_unavailable=1
gpgcheck=0
priority=10

[custom]
name=Custom
baseurl=http://$REPOSERVER/$REPOPATH/custom
enabled=1
skip_if_unavailable=1
gpgcheck=0
priority=1

[epel]
name=Epel
baseurl=http://$REPOSERVER/$REPOPATH/epel
enabled=0
skip_if_unavailable=1
gpgcheck=0
priority=11
EOF`

install_repos() {
  yum -y install createrepo yum-utils yum-plugin-priorities httpd
  systemctl enable httpd.service

  mkdir -p /opt/alces
  cd /opt/alces

  if [ -d repo ]; then
    mv -v repo repo-`date +%F_%T`
  fi
  mkdir -p repo
  cd repo

  cat << EOF > yum.conf
[main]
cachedir=/var/cache/yum/$basearch/$releasever
keepcache=0
debuglevel=2
logfile=/var/log/yum.log
exactarch=1
obsoletes=1
gpgcheck=1
plugins=1
installonly_limit=5
bugtracker_url=http://bugs.centos.org/set_project.php?project_id=23&ref=http://bugs.centos.org/bug_report_page.php?category=yum
distroverpkg=centos-release
reposdir=/dev/null
EOF

cat << EOF > /etc/httpd/comf.d/repo.conf
<Directory /opt/alces/repo/>
    Options Indexes MultiViews FollowSymlinks
    AllowOverride None
    Require all granted
    Order Allow,Deny
    Allow from 10.110.0.0/255.255.0.0
</Directory>
Alias /repo /opt/alces/repo
EOF

  systemctl restart httpd.service
  
  echo "$UPSTREAMCONF" >> yum.conf

  reposync -nm --config yum.conf -r centos
  #distro special
  mkdir -p centos/LiveOS
  curl http://mirror.ox.ac.uk/sites/mirror.centos.org/7/os/x86_64/LiveOS/squashfs.img > centos/LiveOS/squashfs.img

  reposync -nm --config yum.conf -r centos-updates
  reposync -nm --config yum.conf -r centos-extras
  reposync -nm --config yum.conf -r epel

  mkdir custom
  createrepo -g comps.xml centos
  createrepo centos-updates
  createrepo centos-extras
  createrepo -g comps.xml epel
  createrepo custom
}

install_local() {
  find /etc/yum.repos.d/*.repo -exec mv -fv {} {}.bak \;
  echo "$LOCALCONF" > /etc/yum.repos.d/cluster.repo
  yum clean all
}

install_upstream() {
  find /etc/yum.repos.d/*.repo -exec mv -fv {} {}.bak \;
  echo "$UPSTREAMCONF" > /etc/yum.repos.d/cluster.repo
  yum clean all
}

ACTION=$1

case $ACTION in
'local')
  echo 'Installing Local conf'
  install_local
  ;;
'upstream')
  echo 'Installing upstream conf'
  install_upstream
  ;;
'install')
  echo 'Mirroring repos'
  install_repos
  ;;
*)
  echo 'Invalid action' >&2 
  exit 1
  ;;
esac
