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

- Create a security group (replacing ``my_vpc_id`` with the VpcId from the above command output)::

    aws ec2 create-security-group --description my-sg1 --group-name my-sg1 --vpc-id my_vpc_id

- Create a file ``sg-permissions.json`` in the current directory with the following content::

    [
      {
        "IpProtocol": "-1",
        "IpRanges": [
          {
            "CidrIp": "10.75.0.0/16"
          }
        ]
      },
      {
        "IpProtocol": "tcp",
        "FromPort": 22,
        "ToPort": 22,
        "IpRanges": [
          {
            "CidrIp": "0.0.0.0/0"
          }
        ]
      },
      {
        "IpProtocol": "tcp",
        "FromPort": 443,
        "ToPort": 443,
        "IpRanges": [
          {
            "CidrIp": "0.0.0.0/0"
          }
        ]
      },
      {
        "IpProtocol": "tcp",
        "FromPort": 80,
        "ToPort": 80,
        "IpRanges": [
          {
            "CidrIp": "0.0.0.0/0"
          }
        ]
      }
    ]

- Add rules to security group (replacing ``my_group_id`` with the GroupId from the above command output)::

    aws ec2 authorize-security-group-ingress --group-id my_group_id --ip-permissions file://sg-permissions.json

- Define subnet for the VPC (replacing ``my_vpc_id`` with the VpcId from earlier)::

    aws ec2 create-subnet --vpc-id my_vpc_id --cidr-block 10.75.0.0/16

- Create an Internet gateway::

    aws ec2 create-internet-gateway

- Attach the Internet gateway to the VPC (replacing ``my_igw_id`` with InternetGatewayId from the above command output)::

    aws ec2 attach-internet-gateway --internet-gateway-id my_igw_id --vpc-id my_vpc_id

- Locate route table for the VPC::

    aws ec2 describe-route-tables --filters Name=vpc-id,Values=my_vpc_id

- Create a route within the table (replacing ``my_rtb_id`` with RouteTableId from the above command output)::

    aws ec2 create-route --route-table-id my_rtb_id --destination-cidr-block 0.0.0.0/0 --gateway-id my_igw_id

- Create a file ``ec2-role-trust-policy.json`` in the current directory with the following content::

    {
      "Version": "2012-10-17",
      "Statement": [
        {
          "Effect": "Allow",
          "Principal": { "Service": "ec2.amazonaws.com"},
          "Action": "sts:AssumeRole"
        }
      ]
    }

- Create autoscaling role::

    aws iam create-role --role-name autoscaling --assume-role-policy-document file://ec2-role-trust-policy.json

- Create a file ``ec2-role-access-policy.json`` in the current directory with the following content::

    {
      "Version": "2012-10-17",
      "Statement": [
        {
          "Effect": "Allow",
          "Action": [
            "autoscaling:DescribeAutoScalingGroups",
            "autoscaling:SetDesiredCapacity",
            "autoscaling:UpdateAutoScalingGroup",
            "autoscaling:TerminateInstanceInAutoScalingGroup",
            "ec2:DescribeTags"
          ],
          "Resource": [
            "*"
          ]
        }
      ]
    }

- Set role policy for above role::

    aws iam put-role-policy --role-name my-autoscaling-role --policy-name My-Autoscaling-Permissions --policy-document file://ec2-role-access-policy.json

- Create instance profile for autoscaling::

    aws iam create-instance-profile --instance-profile-name autoscaling

- Join the role and instance profile::

    aws iam add-role-to-instance-profile --instance-profile-name autoscaling --role-name autoscaling

- Create a file ``mapping.json`` in the current directory with the following content::

    [
      {
        "DeviceName": "/dev/sda1",
        "Ebs": {
          "DeleteOnTermination": true,
          "SnapshotId": "snap-00f18f3f6413c7879",
          "VolumeSize": 20,
          "VolumeType": "gp2"
        }
      }
    ]

- Create login node (``ami-061b1560`` is the ID for the Official CentOS 7 minimal installation, ```replace my_key_pair``, ``my_sg_id`` and ``my_subnet_id`` with the related values from earlier commands)::

    aws ec2 run-instances --image-id ami-061b1560 --key-name my_key_pair --instance-type r4.2xlarge --associate-public-ip-address --security-group-ids my_sg_id --block-device-mappings file://mapping.json --subnet-id my_subnet_id --iam-instance-profile Name=my-autoscaling-profile

From the Login Node (as root)
-----------------------------

- Install clusterware::

    export cw_DIST=el7
    export cw_BUILD_source_branch=develop
    curl -sL http://git.io/clusterware-installer | /bin/bash

- Enable required clusterware services::

    PATH=/opt/clusterware/bin:$PATH
    alces handler enable clusterable
    alces handler enable autoscaling
    alces service install modules
    alces handler enable cluster-slurm

- Disable SELinux::

    sed -e 's/^SELINUX=.*/SELINUX=disabled/g' -i /etc/selinux/config

- Scramble the root password::

    dd if=/dev/urandom count=50|md5sum|passwd --stdin root
    passwd -l root

- Setup clusterware config file::

    cat <<EOF > /opt/clusterware/etc/config.yml
    ---
    cluster:
      scheduler:
        allocation: autodetect
      name: cluster1
      hostname: login1
      role: master
      ephemeral_swap: always
      ephemeral_swap_size_kib: '0'
      ephemeral_swap_max_kib: '8192'
      ephemeral_scratch: ext4
      tags:
        scheduler_roles: ":master:"
      autoscaling: autodetect
      uuid: $(uuidgen)
      token: $(dd if=/dev/urandom bs=32 count=1 2>/dev/null | base64 | cut -c1-20)
    EOF

- Setup NFS::

    systemctl enable nfs
    cat <<EOF > /etc/exports
    /home 10.75.0.0/16(rw,no_root_squash,no_subtree_check,sync)
    EOF
    systemctl start nfs
    exportfs -a

- Start the clusterware service::

    systemctl start clusterware-configurator

- Log out and back into the node

- Check the alces command utility is functioning::

    alces about identity

From Local Machine
------------------

- Create compute node (``ami-061b1560`` is the ID for the Official CentOS 7 minimal installation, replace ``my_key_pair``, ``my_sg_id`` and ``my_subnet_id`` with the related values from earlier commands)::

    aws ec2 run-instances --image-id ami-061b1560 --key-name my_key_pair --instance-type c4.large --associate-public-ip-address --security-group-ids my_sg_id --block-device-mappings file://mapping.json --subnet-id my_subnet_id

From Compute Node (as root)
---------------------------

- Export installation variables (replace ``node-master-ip`` with the private IP address for the login node. ``cluster-token`` and ``cluster-uuid`` can be found in ``/opt/clusterware/etc/config.yml`` on the login node)::

    export MASTER_IP=node-master-ip
    export CLUSTER_TOKEN=cluster-token
    export CLUSTER_UUID=cluster-uuid

- Install clusterware::

    export cw_DIST=el7
    export cw_BUILD_source_branch=develop
    curl -sL http://git.io/clusterware-installer | /bin/bash

- Enable required clusterware services::

    PATH=/opt/clusterware/bin:$PATH
    alces handler enable clusterable
    alces handler enable autoscaling
    alces service install modules
    alces handler enable cluster-slurm

- Disable SELinux::

    sed -e 's/^SELINUX=.*/SELINUX=disabled/g' -i /etc/selinux/config

- Scramble the root password::

    dd if=/dev/urandom count=50|md5sum|passwd --stdin root
    passwd -l root

- Setup clusterware config file::

    cat <<EOF > /opt/clusterware/etc/config.yml
    ---
    cluster:
      scheduler:
        allocation: autodetect
      name: cluster1
      role: slave
      master: ${MASTER_IP}
      ephemeral_swap: enabled
      ephemeral_swap_size_kib: '0'
      ephemeral_swap_max_kib: '16384'
      ephemeral_scratch: xfs
      tags:
        scheduler_roles: ":compute:"
      uuid: ${CLUSTER_UUID}
      token: ${CLUSTER_TOKEN}
    EOF

- Setup NFS mounts::

    cat <<EOF >> /etc/fstab
    ${MASTER_IP}:/home /home nfs defaults 0 0
    EOF

- Shutdown the node::

    shutdown -h now

From Local Machine
------------------

- Create a template image from the compute node (``compute_node_id`` will be in the output from the instance creation command)::

    aws ec2 create-image --instance-id compute_node_id --name my-compute-node --no-reboot

- Wait for the image to be available (replacing ``my_ami_id`` with the id from the above command)::

    aws ec2 describe-images --image-id my_ami_id |jq '.Images[0].State'

- Setup autoscaling launch configuration (replacing ``compute_node_template_ami_id`` with the output from the first command)::

    aws autoscaling create-launch-configuration --launch-configuration-name my-compute-group1 --image-id compute_node_template_ami_id --key-name my_key_pair --security-groups my_sg_id --associate-public-ip-address --iam-instance-profile my-autoscaling-profile --instance-type c4.large --spot-price 0.113

- Create autoscaling group which can scale from 0 to 8 nodes and initially starts with 1::

    aws autoscaling create-auto-scaling-group --auto-scaling-group-name my-compute-group1 --launch-configuration-name my-compute-group1 --vpc-zone-identifier my_subnet_id --min-size 0 --max-size 8 --desired-capacity 1

Modify Nodes in Autoscale Group
-------------------------------

- To change the number of nodes currently running inside the autoscale group, set the capacity as follows (this example sets it to 2 nodes)::

    aws autoscaling set-desired-capacity --auto-scaling-group-name my-compute-group1 --desired-capacity 2
