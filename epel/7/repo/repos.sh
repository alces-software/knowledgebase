yum install -y yum-plugin-priorities yum-utils
<% if (config.yumrepo.is_server rescue false) -%>
yum -y install createrepo httpd git ruby
# Download repoman
cd /opt/
git clone https://github.com/alces-software/repoman.git

# Add additional repositories
mkdir -p /var/lib/repoman/templates/centos/7/
cd /var/lib/repoman/templates/centos/7/
REPOFILES="base.alcesaws base.alcesinternal base.flightcenter lustre.alcesaws lustre.alcesinternal lustre.flightcenter"
for repofile in $REPOFILES ; do
  wget https://raw.githubusercontent.com/alces-software/knowledgebase/master/epel/7/repo/$repofile
done

# Generate repo config
mkdir -p /opt/alces/repo/
/opt/repoman/repoman.rb generate --distro centos7 --include <%= config.yumrepo.source_repos %> --outfile /opt/alces/repo/client.repo

# HTTP setup
cat << EOF > /etc/httpd/conf.d/repo.conf
<Directory /opt/alces/repo/>
    Options Indexes MultiViews FollowSymlinks
    AllowOverride None
    Require all granted
    Order Allow,Deny
    Allow from <%= config.networks.pri.network %>/255.255.0.0
</Directory>
Alias /repo /opt/alces/repo
EOF

systemctl enable httpd.service
systemctl restart httpd.service

<% else -%>
<%     if (config.yumrepo.clientrepofile rescue false) -%>
find /etc/yum.repos.d/*.repo -exec mv -fv {} {}.bak \;
curl <%= config.yumrepo.clientrepofile %> > /etc/yum.repos.d/cluster.repo
yum clean all
<%     end -%>
<% end -%>

