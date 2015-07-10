# test name resolution
echo -e '192.168.50.50\thub.test.net\n192.168.50.51\tnode1.test.net\n192.168.50.52\tnode2.test.net' | sudo tee --append /etc/hosts
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
