#!/bin/bash
#(c)2017 Alces Software Ltd. HPC Consulting Build Suite
#Job ID: <JOB>
#Cluster: <CLUSTER>

echo ". /opt/sge/default/common/settings.sh" > /etc/profile.d/sge.sh
yum -y install jemalloc lesstif libdb4 munge-libs hwloc-libs
#cp -v /opt/sge/default/common/sgeexecd /etc/init.d/.
curl http://<MASTERIP>/<CLUSTER>/files/sgeexecd > /etc/init.d/sgeexecd
chmod 755 /etc/init.d/sgeexecd
chkconfig sgeexecd on
