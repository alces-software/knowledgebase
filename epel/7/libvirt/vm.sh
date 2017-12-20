#!/bin/bash
#==============================================================================
# Copyright (C) 2017 Stephen F. Norledge and Alces Software Ltd.
#
# This file/package is part of Alces Knowledgebase.
#
# Alces Metalware is free software: you can redistribute it and/or
# modify it under the terms of the GNU Affero General Public License
# as published by the Free Software Foundation, either version 3 of
# the License, or (at your option) any later version.
#
# Alces Metalware is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
# Affero General Public License for more details.
#
# You should have received a copy of the GNU Affero General Public License
# along with this package.  If not, see <http://www.gnu.org/licenses/>.
#
# For more information on the Alces Metalware, please visit:
# https://github.com/alces-software/metalware
#==============================================================================

# Add to hunter
echo '<%= node.name %>: <%= config.vm.primac %>' >> /var/lib/metalware/cache/hunter.yaml
metal dhcp

# Login to controller and create VM
NAME=<%= config.vm.nodename %>
BASEPATH=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
LIBVIRTPOOL=<%= config.vm.virtpool %>

virt-install \
 --name $NAME \
 --import \
 --ram 4096 \
 --boot "network,hd" \
 --disk path=$LIBVIRTPOOL/$NAME.qcow2,size=<%= config.vm.disksize %> \
 --vcpus 2 \
 --os-type linux \
 --os-variant centos7.0 \
 --network bridge=pri,mac="<%= config.vm.primac %>" \
 --network bridge=ext,mac="<%= config.vm.extmac %>" \
 --graphics vnc,password="<%= config.vm.vncpassword %>",listen=0.0.0.0,port="-1" --noautoconsole \
 --console pty,target_type=serial \

virsh destroy $NAME
