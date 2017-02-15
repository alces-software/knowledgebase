#!/bin/bash
#(c)2017 Alces Software Ltd. HPC Consulting Build Suite
#Job ID: <JOB>
#Cluster: <CLUSTER>

source /root/.deployment

yum -y install createrepo yum-utils

cd /var/www/html/${_ALCES_CLUSTER}/

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
install_file yum.upstream yum.repos
cat yum.repos >> yum.conf

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

install_file yum.local /etc/yum.repos.d/cluster.repo
