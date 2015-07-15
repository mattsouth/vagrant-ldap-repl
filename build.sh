#!/bin/bash
# This script builds three VMs (hub, node1, node2) that have replicated ldap
# directories with encrypted authentication and replication

# build hub
echo '** building hub **'
cp Vagrantfile hub/.
cp dpkg.txt hub/.
cp logging.ldif hub/.
cp replmirror.ldif hub/.
sed -i -e "s/{SERVERREPLS}/olcSyncRepl: rid=001 provider=ldap:\/\/node1.test.net bindmethod=simple binddn=\"cn=admin,dc=test,dc=net\" credentials=adminpassword searchbase=\"dc=test,dc=net\" type=refreshAndPersist retry=\"60 +\"\nolcSyncRepl: rid=002 provider=ldap:\/\/node2.test.net binddn=\"cn=admin,dc=test,dc=net\" bindmethod=simple credentials=adminpassword searchbase=\"dc=test,dc=net\" type=refreshAndPersist retry=\"60 +\"/g" hub/replmirror.ldif
cd hub
vagrant up
cd ..

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
  sed -i -e "s/{SERVERREPLS}/olcSyncRepl: rid=001 provider=ldap:\/\/hub.test.net binddn=\"cn=admin,dc=test,dc=net\" bindmethod=simple credentials=adminpassword searchbase=\"dc=test,dc=net\" type=refreshAndPersist retry=\"60 +\"/g" $1/replmirror.ldif

  # # mv keys to new node directory
  # cp hub/cacert.pem $1/.
  # cp hub/cakey.pem $1/.
  # configure ldap install for node - see provisionnode.sh
  # sed -i -e "s/NAME=change_me/NAME=$1/g" $1/provision.sh
  # echo -e "organization = Test Organisation\ncn = $1.test.net\ntls_www_server\nencryption_key\nsigning_key\nexpiration_days = 7" > $1/node.info
  # echo -e "dn: cn=config\nadd: olcTLSCACertificateFile\nolcTLSCACertificateFile: /etc/ssl/certs/cacert.pem\n-\nadd: olcTLSCertificateFile\nolcTLSCertificateFile: /etc/ssl/certs/$1_slapd_cert.pem\n-\nadd: olcTLSCertificateKeyFile\nolcTLSCertificateKeyFile: /etc/ssl/private/$1_slapd_key.pem" > $1/certinfo.ldif
  # echo -e "dn: olcDatabase={1}hdb,cn=config\nreplace: olcSyncRepl\nolcSyncRepl: rid=0 provider=ldap://$1.test.net bindmethod=simple binddn=\"cn=admin,dc=test,dc=net\" credentials=adminpassword searchbase=\"dc=test,dc=net\" logbase=\"cn=accesslog\" logfilter=\"(&(objectClass=auditWriteObject)(reqResult=0))\" schemachecking=on type=refreshAndPersist retry=\"60 +\" syncdata=accesslog starttls=critical tls_reqcert=demand" > $1/consumer_sync_tls.ldif
  cd $1
  vagrant up
  cd ..
}

createnode node1 192.168.50.51 2
createnode node2 192.168.50.52 3

# tidy up
#rm hub/cacert.pem
#rm hub/cakey.pem
