vagrant-ldap-repl
============

Provision multiple Ubuntu 14.04 VirtualBox VMs with a replicated (mirrored with encryption) openldap
directory in a hub and spoke configuration, i.e. hub <-> node{1,2}

### Dependencies:
* VirtualBox
* Vagrant

### Installation:
```bash
git clone git@github.com:mattsouth/vagrant-ldap-repl.git
cd vagrant-ldap-repl
./build.sh
```
Once installed, the replicated ldap directory is available at:
* ldap://192.168.50.50 (hub)
* ldap://192.168.50.51 (node1)
* ldap://192.168.50.52 (node2)

To write to any directory you will need to logon with the User DN 'cn=admin,dc=test,dc=net' and password 'adminpassword'.
Note that to use encrypted authentication, you will need to have pointed your
client to the CA certificate (/etc/ssl/certs/cacert.pem).  For ldapsearch
this is done in /etc/ldap/ldap.conf

To test the replicated directory:
1. log on to a node
2. check that node has a People ou with a person, John
3. Add another person
4. log on to the other node
5. check that node has a People ou with John and your new person

### Add a new node:

To add a third node, you can run the build script again with a parameter:
```bash
./build.sh 3
```
Note this only works for values 3 and 4 and doesnt check whether it's overwriting an existing node.

### Clear up afterwards:
```bash
./destroy.sh
```
### Notes  

see https://help.ubuntu.com/lts/serverguide/openldap-server.html for more
detailed instructions on the original setup and
http://www.openldap.org/doc/admin24/replication.html#MirrorMode
for details of the alternate replication strategy.

Note that provision.sh uses a slightly different install
technique for openldap, as I wasnt able to use the hosts file trick to set the
directory dn.
