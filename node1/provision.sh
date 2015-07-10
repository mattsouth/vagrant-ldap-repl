# test name resolution
echo -e '192.168.50.50\thub.test.net\n192.168.50.51\tnode1.test.net' | sudo tee --append /etc/hosts
# install ldap
sudo debconf-set-selections /vagrant/dpkg.txt
sudo apt-get -y install slapd ldap-utils ssl-cert
# NB - load default ldap user via replication
# boost the ldap logging level
sudo ldapmodify -Q -Y EXTERNAL -H ldapi:/// -f /vagrant/logging.ldif
# configure replication
sudo ldapadd -Q -Y EXTERNAL -H ldapi:/// -f /vagrant/replconsumer.ldif
