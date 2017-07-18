.. _deployment-aws:

Setting Up AWS Environment for HPC Platform
===========================================

HPC platforms can be deployed in the cloud instead of on local hardware. While there are many cloud providers out there, this guide focusses on setting up login and compute nodes in the cloud on the AWS platform.

From Local Machine
------------------

AWS has a command line tool that can be used to create and manage resources. These will need to be run from a Linux/Mac machine.

- Create a VPC for the network::

    aws ec2 create-vpc --cidr-block 10.75.0.0/16

.. note:: Optionally, a name tag can be created for the VPC (which can make it easier to locate the VPC through the AWS web console) with ``aws ec2 create-tags --resources my_vpc_id --tags Key=Name,Value=Name-For-My-VPC``

- Create a security group (replacing my_vpc_id with the VpcId from the above command output)::

    aws ec2 create-security-group --description my-sg1 --group-name my-sg1 --vpc-id my_vpc_id

- Add rules to security group (replacing my_group_id with the GroupId from the above command output)::

    wget https://gist.githubusercontent.com/mjtko/2725a200fabf6395713005fce54063fa/raw/sg-permissions.json
    aws ec2 authorize-security-group-ingress --group-id my_group_id --ip-permissions file://sg-permissions.json

- Define subnet for the VPC (replacing my_vpc_id with the VpcId from earlier)::

    aws ec2 create-subnet --vpc-id my_vpc_id --cidr-block 10.75.0.0/16

- Create an Internet gateway::

    aws ec2 create-internet-gateway

- Attach the Internet gateway to the VPC (replacing my_igw_id with InternetGatewayId from the above command output)::

    aws ec2 attach-internet-gateway --internet-gateway-id my_igw_id --vpc-id my_vpc_id

- Locate route table for the VPC::

    aws ec2 describe-route-tables --filters Name=vpc-id,Values=my_vpc_id

- Create a route within the table (replacing my_rtb_id with RouteTableId from the above command output)::

    aws ec2 create-route --route-table-id my_rtb_id --destination-cidr-block 0.0.0.0/0 --gateway-id my_igw_id

- Create autoscaling role::

    wget https://gist.githubusercontent.com/mjtko/2725a200fabf6395713005fce54063fa/raw/ec2-role-trust-policy.json
    aws iam create-role --role-name my-autoscaling-role --assume-role-policy-document file://ec2-role-trust-policy.json

- Set role policy for above role::

    wget https://gist.githubusercontent.com/mjtko/2725a200fabf6395713005fce54063fa/raw/ec2-role-access-policy.json
    aws iam put-role-policy --role-name my-autoscaling-role --policy-name My-Autoscaling-Permissions --policy-document file://ec2-role-access-policy.json

- Create instance profile for autoscaling::

    aws iam create-instance-profile --instance-profile-name my-autoscaling-profile

- Join the role and instance profile::

    aws iam add-role-to-instance-profile --instance-profile-name my-autoscaling-profile --role-name my-autoscaling-role

- Create login node (ami-061b1560 is the ID for the Official CentOS 7 minimal installation, replace my_key_pair, my_sg_id and my_subnet_id with the related values from earlier commands)::

    wget https://gist.githubusercontent.com/mjtko/2725a200fabf6395713005fce54063fa/raw/mapping.json
    aws ec2 run-instances --image-id ami-061b1560 --key-name my_key_pair --instance-type r4.2xlarge --associate-public-ip-address --security-group-ids my_sg_id --block-device-mappings file://mapping.json --subnet-id my_subnet_id --iam-instance-profile Name=my-autoscaling-profile

From the Login Node (as root)
-----------------------------

- Install clusterware master::

    curl https://gist.githubusercontent.com/mjtko/2725a200fabf6395713005fce54063fa/raw/master.sh | /bin/bash -x

- Start the clusterware service::

    systemctl start clusterware-configurator

- Log out and back into the node

- Check the alces command utility is functioning::

    alces about identity

From Local Machine
------------------

- Create compute node (ami-061b1560 is the ID for the Official CentOS 7 minimal installation, replace my_key_pair, my_sg_id and my_subnet_id with the related values from earlier commands)::

    aws ec2 run-instances --image-id ami-061b1560 --key-name my_key_pair --instance-type c4.large --associate-public-ip-address --security-group-ids my_sg_id --block-device-mappings file://mapping.json --subnet-id my_subnet_id

From Compute Node (as root)
---------------------------

- Export installation variables (replace node-master-ip with the private IP address for the login node. cluster-token and cluster-uuid can be found in /opt/clusterware/etc/config.yml on the login node)::

    export MASTER_IP=node-master-ip
    export CLUSTER_TOKEN=cluster-token
    export CLUSTER_UUID=cluster-uuid

- Run the clusterware slave installation::

    curl https://gist.githubusercontent.com/mjtko/2725a200fabf6395713005fce54063fa/raw/slave.sh | /bin/bash -x

- Shutdown the node::

    shutdown -h now

From Local Machine
------------------

- Create a template image from the compute node (compute_node_id will be in the output from the instance creation command)::

    aws ec2 create-image --instance-id compute_node_id --name my-compute-node --no-reboot

- Wait for the image to be available (replacing my_ami_id with the id from the above command)::

    aws ec2 describe-images --image-id my_ami_id |jq '.Images[0].State'

- Setup autoscaling launch configuration (replacing compute_node_template_ami_id with the output from the first command)::

    aws autoscaling create-launch-configuration --launch-configuration-name my-compute-group1 --image-id compute_node_template_ami_id --key-name my_key_pair --security-groups my_sg_id --associate-public-ip-address --iam-instance-profile my-autoscaling-profile --instance-type c4.large --spot-price 0.113

- Create autoscaling group which can scale from 0 to 8 nodes and initially starts with 1::

    aws autoscaling create-auto-scaling-group --auto-scaling-group-name my-compute-group1 --launch-configuration-name my-compute-group1 --vpc-zone-identifier my_subnet_id --min-size 0 --max-size 8 --desired-capacity 1

Modify Nodes in Autoscale Group
-------------------------------

- To change the number of nodes currently running inside the autoscale group, set the capacity as follows (this example sets it to 2 nodes)::

    aws autoscaling set-desired-capacity --auto-scaling-group-name cluster1-compute-group1-stu --desired-capacity 2
