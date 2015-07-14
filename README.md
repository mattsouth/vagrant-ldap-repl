vagrant-ldap-repl
============

Provision multiple Ubuntu 14.04 VirtualBox VMs with replicated (N-Way Multi Master) openldap directory.

### Dependencies:
* VirtualBox
* Vagrant

### Installation:
```bash
git clone git@github.com:mattsouth/vagrant-ldap-repl.git
cd vagrant-ldap-repl
./build.sh
cd hub
vagrant ssh
sudo ldapmodify -Q -Y EXTERNAL -H ldapi:/// -f /vagrant/repldit.ldif
```
Once installed, the replicated ldap directory is available at:
* ldap://192.168.50.50 (hub)
* ldap://192.168.50.51 (node1)
* ldap://192.168.50.52 (node2)

The directories are available read-only with anonymous authentication.
To write to any directory you will need to logon with the User DN 'cn=admin,dc=test,dc=net' and password 'admin'.  
Note that the names hub, nodeX are slightly off as they are all masters, however during the install it's the
hub that has the seed group and user loaded, and which first replicates the organisation dit.

see https://help.ubuntu.com/lts/serverguide/openldap-server.html for more
detailed instructions on the original setup and
http://www.openldap.org/doc/admin24/replication.html#N-Way%20Multi-Master
for details of the alternate replication strategy.

Note that provision.sh uses a slightly different install
technique for openldap, as I wasnt able to use the hosts file trick to set the
directory dn.
