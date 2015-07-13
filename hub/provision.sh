# setup test name resolution
echo -e '192.168.50.50\thub.test.net\n192.168.50.51\tnode1.test.net\n192.168.50.52\tnode2.test.net' | sudo tee --append /etc/hosts

# setup keys
sudo apt-get -y install gnutls-bin ssl-cert
sudo sh -c "certtool --generate-privkey > /etc/ssl/private/cakey.pem"
echo -e 'cn = Test Company\nca\ncert_signing_key' | sudo tee /etc/ssl/ca.info
sudo certtool --generate-self-signed --load-privkey /etc/ssl/private/cakey.pem --template /etc/ssl/ca.info --outfile /etc/ssl/certs/cacert.pem
sudo certtool --generate-privkey --bits 1024 --outfile /etc/ssl/private/hub_slapd_key.pem
echo -e 'organization = Test Company\ncn = hub.test.net\ntls_www_server\nencryption_key\nsigning_key\nexpiration_days = 7' | sudo tee /etc/ssl/hub.info
sudo certtool --generate-certificate --load-privkey /etc/ssl/private/hub_slapd_key.pem --load-ca-certificate /etc/ssl/certs/cacert.pem --load-ca-privkey /etc/ssl/private/cakey.pem --template /etc/ssl/hub.info --outfile /etc/ssl/certs/hub_slapd_cert.pem
echo -e 'dn: cn=config\nadd: olcTLSCACertificateFile\nolcTLSCACertificateFile: /etc/ssl/certs/cacert.pem\n-\nadd: olcTLSCertificateFile\nolcTLSCertificateFile: /etc/ssl/certs/hub_slapd_cert.pem\n-\nadd: olcTLSCertificateKeyFile\nolcTLSCertificateKeyFile: /etc/ssl/private/hub_slapd_key.pem' | sudo tee /etc/ssl/certinfo.ldif

# install ldap
sudo debconf-set-selections /vagrant/dpkg.txt
sudo apt-get -y install slapd ldap-utils ssl-cert
# load default ldap user
ldapadd -c -x -H ldap://localhost:389 -D cn=admin,dc=test,dc=net -w admin -f /vagrant/users.ldif
# boost the ldap logging level
sudo ldapmodify -Q -Y EXTERNAL -H ldapi:/// -f /vagrant/logging.ldif
# setup accesslog for syncrepl
sudo -u openldap mkdir /var/lib/ldap/accesslog
sudo -u openldap cp /var/lib/ldap/DB_CONFIG /var/lib/ldap/accesslog
sudo service apparmor reload
# configure replication
sudo ldapadd -Q -Y EXTERNAL -H ldapi:/// -f /vagrant/replprovider.ldif
sudo service slapd restart

# configure tls encryption for ldap
sudo ldapmodify -Y EXTERNAL -H ldapi:/// -f /etc/ssl/certinfo.ldif
sudo adduser openldap ssl-cert
sudo chgrp ssl-cert /etc/ssl/private/hub_slapd_key.pem
sudo chmod g+r /etc/ssl/private/hub_slapd_key.pem
sudo chmod o-r /etc/ssl/private/hub_slapd_key.pem
sudo service slapd restart
