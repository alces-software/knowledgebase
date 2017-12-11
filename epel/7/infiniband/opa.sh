#OmniPath OPA, using Intel Install download (requires Alces KB Firstboot)
#Download Intel OPA install package to /opt/alces/installers on metalware master, and create link to opa.tgz
#Eg ln -snf IntelOPA-IFS.RHEL73-x86_64.10.4.2.0.7.tgz opa.tgz

<% if (config.networks.ib.defined rescue false) -%>
if (lspci | grep -q 'Omni-Path'); then
  mkdir -p /var/lib/alceskb/opainstall/
  curl http://<%= domain.hostip %>/installers/opa.tgz > /var/lib/alceskb/opainstall/opa.tgz
  yum -y groupinstall "Development Tools" "Infiniband"
  yum -y install expect atlas kernel-devel bc libhfi1 libuuid-devel qperf perftest
  if [ -d /var/lib/firstrun/scripts/ ]; then
    cat << EOF > /var/lib/firstrun/scripts/installOPA.bash
cd /var/lib/alceskb/opainstall/
tar -zxv --strip=1 -f /var/lib/alceskb/opainstall/opa.tgz -C /var/lib/alceskb/opainstall/
./INSTALL -i opa_stack -i intel_hfi -i oftools -i fastfabric -i delta_ipoib -i opafm -i opa_stack_dev -i ipoib
#clean yum after opa install does some nasty
yum clean all
#toggle reboot flag
touch /firstrun.reboot
EOF
  fi
fi
<% else -%>
echo "Infiniband is not defined for node, skipping setup"
<% end -%>
