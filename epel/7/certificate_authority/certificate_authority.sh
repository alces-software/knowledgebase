#!/bin/bash

yum -y install gnutls-utils-3.3.26-9.el7.x86_64

# Setup directory
CA_DIR=/opt/alces/ca_setup
mkdir -p $CA_DIR

# Certificate Authority
echo "Setting up certificate authority"
certtool --generate-privkey > $CA_DIR/cakey.pem
cat << EOF > $CA_DIR/ca.info
cn = Alces Software
ca
cert_signing_key
EOF
certtool --generate-self-signed --load-privkey $CA_DIR/cakey.pem --template $CA_DIR/ca.info --outfile $CA_DIR/cacert.pem
cp $CA_DIR/cacert.pem /etc/pki/CA/
echo "Copy $CA_DIR/cacert.pem to /etc/pki/CA/cacert.pem on the libvirt servers"
echo

# Server Authority
for server in <%= vm.server %> ; do
    echo "Setting up server certificate for $server"
    certtool --generate-privkey > $CA_DIR/$server-key.pem
    cat << EOF > $CA_DIR/$server.info
organization = Alces Software
cn = $server
tls_www_server
encryption_key
signing_key
EOF
    certtool --generate-certificate --load-privkey $CA_DIR/$server-key.pem --load-ca-certificate $CA_DIR/cacert.pem --load-ca-privkey $CA_DIR/cakey.pem --template $CA_DIR/$server.info --outfile $CA_DIR/$server-cert.pem
    echo "Copy $CA_DIR/$server-{key,cert}.pem to /etc/pki/libvirt/{servercert.pem,/private/serverkey.pem} on $server"
    echo
done

# Client (controller) Authority
echo "Setting up client certificate"
certtool --generate-privkey > $CA_DIR/clientkey.pem
cat << EOF > $CA_DIR/client.info
organization = Alces Software
cn = <%= alces.nodename %>
tls_www_client
encryption_key
signing_key
EOF
certtool --generate-certificate --load-privkey $CA_DIR/clientkey.pem --load-ca-certificate $CA_DIR/cacert.pem --load-ca-privkey $CA_DIR/cakey.pem --template $CA_DIR/client.info --outfile $CA_DIR/clientcert.pem
mkdir -p /etc/pki/libvirt/private/
cp $CA_DIR/clientkey.pem /etc/pki/libvirt/private/
cp $CA_DIR/clientcert.pem /etc/pki/libvirt/
echo

