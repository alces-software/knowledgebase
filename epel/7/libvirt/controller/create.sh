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
TAG=-stuts2

BASEPATH="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
NAME=controller$TAG

virt-install \
--name $NAME \
--ram 4096 \
--disk path=/opt/vm/$NAME.qcow2,size=80 \
--vcpus 2 \
--os-type linux \
--os-variant centos7.0 \
--network bridge=pri \
--network bridge=mgt \
--network bridge=ext \
--graphics vnc,password='sqrt(s*w)',listen=0.0.0.0,port='-1' --noautoconsole \
--console pty,target_type=serial \
--location 'http://repo.alces-software.com/repo/centos/7/base' \
--initrd-inject $BASEPATH/controller.ks \
--extra-args 'console=tty0 console=ttyS0,115200n8 ip=eth2:dhcp bootdev=eth2 ks=file:/controller.ks'

virsh console $NAME

