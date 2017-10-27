# Setup prompt
cat << "EOF" > /etc/profile.d/flightcenter.sh
#Custom PS1 with client name
[ -f /etc/flightcentersupported ] && c=32 || c=31
if [ "$PS1" ]; then
  PS1="[\u@\h\[\e[1;${c}m\][<%=cluster%>]\[\e[0m\] \W]\\$ "
fi
EOF

# Enable support
touch /etc/flightcentersupported

# Crontab
cat << 'EOF' > /etc/cron.d/tmpdir
SHELL=/bin/bash
PATH=/sbin:/bin:/usr/sbin:/usr/bin
MAILTO=root
* * * * * root mkdir -p -m 0777 /tmp/users
EOF

# User directories
cat << 'EOF' > /etc/profile.d/alces-fs.sh
################################################################################
##
## Alces HPC Software Stack - User helper directory creation on login
## Copyright (c) 2008-2017 Alces Software Ltd
##
################################################################################

ARCHIVE_DIR="<%= flightcenter.archivedir %>"
SHAREDSCRATCH_DIR="<%= flightcenter.sharedscratchdir %>"
LOCALSCRATCH_DIR="<%= flightcenter.localscratchdir %>"

USERDIR=$USER/

export SKIP_USERS="root alces"
export LOWEST_UID=500

check_user() {
  for SKIPUSER in $SKIP_USERS; do
    if [ "$USER" ==  "$SKIPUSER" ]; then
      return 1
    fi
    if [ $LOWEST_UID -gt `id -u` ]; then
      return 1
    fi
  done
  return 0
}

do_userpath() {

  TYPE=$1
  LINK=$2
  BASEDIR=$3
  MODE=$4
  if [ -z $MODE]; then
    MODE=700
  fi
  if ! [ -z $BASEDIR ]; then
    TARGET_DIR=$BASEDIR/$USERDIR
    if ! [ -d $TARGET_DIR ] && [ -w $BASEDIR ]; then
      echo "Creating user dir for '$TYPE'"
      mkdir -m $MODE -p $TARGET_DIR
    fi
    TARGET_LINK=$HOME/$LINK
    if [ -d $TARGET_DIR ]; then
      if ! [ -f $TARGET_LINK ] && ! [ -L $TARGET_LINK ] && ! [ -d $TARGET_LINK ] ; then
        echo "Creating user link for '$TYPE'"
        if ! ( ln -sn $TARGET_DIR $TARGET_LINK 2>&1 ); then
          echo "Warning: A '$TYPE' directory is available but a link cannot be created on this node" >&2
      fi
      fi
    else
      if [ -L $TARGET_LINK ]; then
        echo "Warning: A '$TYPE' link exists but the target is not available on this node" >&2
      fi
    fi
  fi
}

if ( check_user ); then
  do_userpath "Local Scratch" localscratch $LOCALSCRATCH_DIR
  do_userpath "Shared Scratch" sharedscratch $SHAREDSCRATCH_DIR
  do_userpath "Archive" archive $ARCHIVE_DIR
fi

EOF

<% if alces.nodename == 'self' -%>
# NTP
cat << EOF > /etc/chrony.conf
server <%= flightcenter.ntpserver %> iburst

stratumweight 0

driftfile /var/lib/chrony/drift

rtcsync

makestep 10 3

bindcmdaddress 127.0.0.1
bindcmdaddress ::1

keyfile /etc/chrony.keys

commandkey 1

generatecommandkey

noclientlog

logchange 0.5

logdir /var/log/chrony

allow <%= networks.pri.network %>/<% require 'ipaddr'; netmask=IPAddr.new(networks.pri.netmask).to_i.to_s(2).count('1') %><%= netmask %>
EOF

# Mail relay
sed -n -e '/^relayhost\s*=/!p' -e '$arelayhost=[<%=flightcenter.mailserver%>]' /etc/postfix/main.cf -i

# Ganglia
GMOND=`cat << EOF
globals {
  daemonize = yes
  setuid = yes
  user = ganglia
  debug_level = 0
  max_udp_msg_len = 1472
  mute = no
  deaf = no
  allow_extra_data = yes
  host_dmax = 86400
  host_tmax = 20
  cleanup_threshold = 300
  gexec = no
  send_metadata_interval = 0
}
cluster {
  name = "<%= cluster %>"
  owner = "unspecified"
  latlong = "unspecified"
  url = "unspecified"
}
host {
  location = "unspecified"
}
udp_send_channel {
  mcast_join = <%= flightcenter.gangliaserver %>
  port = 8649
  ttl = 1
}
udp_recv_channel {
  port = 8649
}
tcp_accept_channel {
  port = 8659
  gzip_output = no
}
modules {
  module {
    name = "core_metrics"
  }
  module {
    name = "cpu_module"
    path = "modcpu.so"
  }
  module {
    name = "disk_module"
    path = "moddisk.so"
  }
  module {
    name = "load_module"
    path = "modload.so"
  }
  module {
    name = "mem_module"
    path = "modmem.so"
  }
  module {
    name = "net_module"
    path = "modnet.so"
  }
  module {
    name = "proc_module"
    path = "modproc.so"
  }
  module {
    name = "sys_module"
    path = "modsys.so"
  }
}
collection_group {
  collect_once = yes
  time_threshold = 20
  metric {
    name = "heartbeat"
  }
}
collection_group {
  collect_every = 60
  time_threshold = 60
  metric {
    name = "cpu_num"
    title = "CPU Count"
  }
  metric {
    name = "cpu_speed"
    title = "CPU Speed"
  }
  metric {
    name = "mem_total"
    title = "Memory Total"
  }
  metric {
    name = "swap_total"
    title = "Swap Space Total"
  }
  metric {
    name = "boottime"
    title = "Last Boot Time"
  }
  metric {
    name = "machine_type"
    title = "Machine Type"
  }
  metric {
    name = "os_name"
    title = "Operating System"
  }
  metric {
    name = "os_release"
    title = "Operating System Release"
  }
  metric {
    name = "location"
    title = "Location"
  }
}
collection_group {
  collect_once = yes
  time_threshold = 300
  metric {
    name = "gexec"
    title = "Gexec Status"
  }
}
collection_group {
  collect_every = 20
  time_threshold = 90
  metric {
    name = "cpu_user"
    value_threshold = "1.0"
    title = "CPU User"
  }
  metric {
    name = "cpu_system"
    value_threshold = "1.0"
    title = "CPU System"
  }
  metric {
    name = "cpu_idle"
    value_threshold = "5.0"
    title = "CPU Idle"
  }
  metric {
    name = "cpu_nice"
    value_threshold = "1.0"
    title = "CPU Nice"
  }
  metric {
    name = "cpu_aidle"
    value_threshold = "5.0"
    title = "CPU aidle"
  }
  metric {
    name = "cpu_wio"
    value_threshold = "1.0"
    title = "CPU wio"
  }
  metric {
    name = "cpu_steal"
    value_threshold = "1.0"
    title = "CPU steal"
  }
}
collection_group {
  collect_every = 20
  time_threshold = 90
  metric {
    name = "load_one"
    value_threshold = "1.0"
    title = "One Minute Load Average"
  }
  metric {
    name = "load_five"
    value_threshold = "1.0"
    title = "Five Minute Load Average"
  }
  metric {
    name = "load_fifteen"
    value_threshold = "1.0"
    title = "Fifteen Minute Load Average"
  }
}
collection_group {
  collect_every = 80
  time_threshold = 950
  metric {
    name = "proc_run"
    value_threshold = "1.0"
    title = "Total Running Processes"
  }
  metric {
    name = "proc_total"
    value_threshold = "1.0"
    title = "Total Processes"
  }
}
collection_group {
  collect_every = 40
  time_threshold = 180
  metric {
    name = "mem_free"
    value_threshold = "1024.0"
    title = "Free Memory"
  }
  metric {
    name = "mem_shared"
    value_threshold = "1024.0"
    title = "Shared Memory"
  }
  metric {
    name = "mem_buffers"
    value_threshold = "1024.0"
    title = "Memory Buffers"
  }
  metric {
    name = "mem_cached"
    value_threshold = "1024.0"
    title = "Cached Memory"
  }
  metric {
    name = "swap_free"
    value_threshold = "1024.0"
    title = "Free Swap Space"
  }
}
collection_group {
  collect_every = 40
  time_threshold = 300
  metric {
    name = "bytes_out"
    value_threshold = 4096
    title = "Bytes Sent"
  }
  metric {
    name = "bytes_in"
    value_threshold = 4096
    title = "Bytes Received"
  }
  metric {
    name = "pkts_in"
    value_threshold = 256
    title = "Packets Received"
  }
  metric {
    name = "pkts_out"
    value_threshold = 256
    title = "Packets Sent"
  }
}
collection_group {
  collect_every = 1800
  time_threshold = 3600
  metric {
    name = "disk_total"
    value_threshold = 1.0
    title = "Total Disk Space"
  }
}
collection_group {
  collect_every = 40
  time_threshold = 180
  metric {
    name = "disk_free"
    value_threshold = 1.0
    title = "Disk Space Available"
  }
  metric {
    name = "part_max_used"
    value_threshold = 1.0
    title = "Maximum Disk Space Used"
  }
}
include ("/etc/ganglia/conf.d/*.conf")
EOF
`
<% end -%>
