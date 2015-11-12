#!/bin/bash

NAME=change_me
# test name resolution
echo -e '192.168.50.50\thub.test.net\n192.168.50.51\tnode1.test.net\n192.168.50.52\tnode2.test.net' | sudo tee --append /etc/hosts
# install ldap
sudo debconf-set-selections /vagrant/dpkg.txt
sudo apt-get -y install slapd ldap-utils ssl-cert gnutls-bin
# NB - load default ldap user via replication
# boost the ldap logging level
sudo ldapmodify -Q -Y EXTERNAL -H ldapi:/// -f /vagrant/logging.ldif
# configure replication
sudo ldapadd -Q -Y EXTERNAL -H ldapi:/// -f /vagrant/replconsumer.ldif
# setup keys
sudo mv /vagrant/cacert.pem /etc/ssl/certs
sudo mv /vagrant/cakey.pem /etc/ssl/private
sudo adduser openldap ssl-cert
sudo certtool --generate-privkey --bits 1024 --outfile /etc/ssl/private/${NAME}_slapd_key.pem
sudo certtool --generate-certificate --load-privkey /etc/ssl/private/${NAME}_slapd_key.pem --load-ca-certificate /etc/ssl/certs/cacert.pem --load-ca-privkey /etc/ssl/private/cakey.pem --template /vagrant/node.info --outfile /etc/ssl/certs/${NAME}_slapd_cert.pem
sudo chgrp ssl-cert /etc/ssl/private/${NAME}_slapd_key.pem
sudo chmod g+r /etc/ssl/private/${NAME}_slapd_key.pem
sudo chmod o-r /etc/ssl/private/${NAME}_slapd_key.pem

sudo ldapmodify -Y EXTERNAL -H ldapi:/// -f /vagrant/certinfo.ldif
sudo ldapmodify -Y EXTERNAL -H ldapi:/// -f /vagrant/consumer_sync_tls.ldif
sudo service slapd restart
# note: ideally (and as per the instructions) we would have generated slapd_key
# and slapd_cert on the hub and copied them over with the cacert, but that
# protocol breaks the build model.  Instead we've copied the cakey and cacert
# and generated the slapd pems on this server, but we dont need the private key
# any more so now we'll delete it.
sudo rm /etc/ssl/private/cakey.pem
