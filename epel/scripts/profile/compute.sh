#!/bin/bash
#(c)2017 Alces Software Ltd. HPC Consulting Build Suite
#Job ID: <JOB>
#Cluster: <CLUSTER>

source /root/.deployment
export ALCES_PROFILE="COMPUTE"

run_script install/base.sh
run_script install/mlx5.sh
run_script install/nisclient.sh
run_script install/nfsclient.sh
run_script install/gangliaclient.sh
run_script install/postfixclient.sh
