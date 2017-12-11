#!/bin/bash
curl https://raw.githubusercontent.com/alces-software/rootrun/master/install.sh |/bin/bash
cat << EOF > /opt/rootrun/rootrun.yaml
scriptdir: <%= config.rootrun.scriptdir %>
userlogdir: <%= config.rootrun.userlogdir %>
adminlogdir: <%= config.rootrun.adminlogdir %>
interval: 600
timeout: 300
# The groups \$HOSTNAME and 'all' are automatically assigned to the client.
# 'groups:' should be followed with a comma separated list of groups to include
groups:
EOF
systemctl restart rootrun
