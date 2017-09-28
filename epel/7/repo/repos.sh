yum install -y yum-plugin-priorities yum-utils
<% if repoconfig.is_server -%>
yum -y install createrepo httpd
# Download repoman
cd /opt/
git clone https://github.com/alces-software/repoman.git

# Add additional repositories
mkdir -p /var/lib/repoman/templates/centos/7/
cd /var/lib/repoman/templates/centos/7/
REPOFILES="base.alcesaws base.alcesinternal lustre.alcesaws lustre.alcesinternal"
for repofile in $REPOFILES ; do
  wget https://raw.githubusercontent.com/alces-software/knowledgebase/master/epel/7/repo/$repofile
done

<%     if repoconfig.is_mirror -%>
# Mirror repos
/opt/repoman/repoman.rb mirror --distro centos7 --include <%= repoconfig.source_repos %> --reporoot /opt/alces/repo --configurl http://<%= networks.pri.ip %>/repo/ --configout /opt/alces/repo/client.repo
<%     else -%>
# Generate repo config
/opt/repoman/repoman.rb generate --distro centos7 --include <%= repoconfig.source_repos %> --outfile /opt/alces/repo/client.repo
<%     end -%>

# HTTP setup
cat << EOF > /etc/httpd/conf.d/repo.conf
<Directory /opt/alces/repo/>
    Options Indexes MultiViews FollowSymlinks
    AllowOverride None
    Require all granted
    Order Allow,Deny
    Allow from <%= networks.pri.network %>/255.255.0.0
</Directory>
Alias /repo /opt/alces/repo
EOF

systemctl enable httpd.service
systemctl restart httpd.service

<% else -%>
<%     if repoconfig.clientrepofile -%>
find /etc/yum.repos.d/*.repo -exec mv -fv {} {}.bak \;
curl <%= repoconfig.clientrepofile %> > /etc/yum.repos.d/cluster.repo
yum clean all
<%     end -%>
<% end -%>

