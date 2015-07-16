#!/bin/bash
# This script without an arguments builds three VMs (hub, node1, node2) that
# have replicated ldap directories with encrypted authentication and replication
# If you add an argument, e.g. 3 it will add a new node, i.e. node3
# Note that there is no testing of valid indices here because the hub only
# has hosts entries up to node4, only values 3 and 4 work.

# build nodes
function createnode {
  echo "** building $1 **"
  mkdir $1
  cp Vagrantfile $1/.
  sed -i -e "s/192.168.50.50/$2/g" $1/Vagrantfile
  cp dpkg.txt $1/.
  cp logging.ldif $1/.
  cp provisionnode.sh $1/provision.sh
  sed -i -e "s/\/hub.test.net/\/$1.test.net/g" $1/provision.sh
  cp replmirror.ldif $1/.
  sed -i -e "N; s/olcServerID: 1\n/olcServerID: $3\n/g; P; D" $1/replmirror.ldif
  sed -i -e "s/{SERVERREPLS}/olcSyncRepl: rid=001 provider=ldap:\/\/hub.test.net binddn=\"cn=admin,dc=test,dc=net\" bindmethod=simple credentials=adminpassword searchbase=\"dc=test,dc=net\" type=refreshAndPersist retry=\"60 +\" starttls=critical tls_reqcert=demand/g" $1/replmirror.ldif

  # mv keys to new node directory
  cp hub/cacert.pem $1/.
  cp hub/cakey.pem $1/.
  # configure ldap install for node - see provisionnode.sh
  sed -i -e "s/NAME=change_me/NAME=$1\necho -e '$2\t$1.test.net' | sudo tee --append \/etc\/hosts/g" $1/provision.sh
  echo -e "organization = Test Organisation\ncn = $1.test.net\ntls_www_server\nencryption_key\nsigning_key\nexpiration_days = 7" > $1/node.info
  echo -e "dn: cn=config\nadd: olcTLSCACertificateFile\nolcTLSCACertificateFile: /etc/ssl/certs/cacert.pem\n-\nadd: olcTLSCertificateFile\nolcTLSCertificateFile: /etc/ssl/certs/$1_slapd_cert.pem\n-\nadd: olcTLSCertificateKeyFile\nolcTLSCertificateKeyFile: /etc/ssl/private/$1_slapd_key.pem" > $1/certinfo.ldif
  cd $1
  vagrant up
  cd ..
}

if [ -z "$1" ]
then
  # build hub
  echo '** building hub **'
  cp Vagrantfile hub/.
  cp dpkg.txt hub/.
  cp logging.ldif hub/.
  cp replmirror.ldif hub/.
  sed -i -e "s/{SERVERREPLS}/olcSyncRepl: rid=001 provider=ldap:\/\/node1.test.net bindmethod=simple binddn=\"cn=admin,dc=test,dc=net\" credentials=adminpassword searchbase=\"dc=test,dc=net\" type=refreshAndPersist retry=\"60 +\" starttls=critical tls_reqcert=demand\nolcSyncRepl: rid=002 provider=ldap:\/\/node2.test.net binddn=\"cn=admin,dc=test,dc=net\" bindmethod=simple credentials=adminpassword searchbase=\"dc=test,dc=net\" type=refreshAndPersist retry=\"60 +\" starttls=critical tls_reqcert=demand/g" hub/replmirror.ldif
  echo -e "dn: cn=config\nadd: olcTLSCACertificateFile\nolcTLSCACertificateFile: /etc/ssl/certs/cacert.pem\n-\nadd: olcTLSCertificateFile\nolcTLSCertificateFile: /etc/ssl/certs/hub_slapd_cert.pem\n-\nadd: olcTLSCertificateKeyFile\nolcTLSCertificateKeyFile: /etc/ssl/private/hub_slapd_key.pem" > hub/certinfo.ldif
  cd hub
  vagrant up
  cd ..
  createnode node1 192.168.50.51 2
  createnode node2 192.168.50.52 3
else
  createnode node$1 192.168.50.5$1 $(($1+1))
  echo -e "dn: olcDatabase={1}hdb,cn=config\nchangetype: modify\nadd: olcSyncRepl\nolcSyncRepl: rid=00$1 provider=ldap://node$1.test.net binddn=\"cn=admin,dc=test,dc=net\" bindmethod=simple credentials=adminpassword searchbase=\"dc=test,dc=net\" type=refreshAndPersist retry=\"60 +\" starttls=critical tls_reqcert=demand" > hub/addnode$1.ldif
  echo -e "Almost done.  To finish the hub needs to be told about your new node. Run the following command on the hub:\n\nsudo ldapmodify -Y EXTERNAL -H ldapi:/// -f /vagrant/addnode$1.ldif"
fi
