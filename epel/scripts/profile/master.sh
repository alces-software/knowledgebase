#!/bin/bash
#(c)2017 Alces Software Ltd. HPC Consulting Build Suite
#Job ID: <JOB>
#Cluster: <CLUSTER>

source /root/.deployment
export ALCES_PROFILE="MASTER"

run_script install/base.sh
run_script install/infiniband.sh
run_script install/deploymentserver.sh
run_script install/httpserver.sh
run_script install/nfsserver.sh
run_script install/nisserver.sh
run_script install/postfixserver.sh
