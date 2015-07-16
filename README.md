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

The directories are available read-only with anonymous authentication.
To write to any directory you will need to logon with the User DN 'cn=admin,dc=test,dc=net' and password 'adminpassword'.

### Add a new node

TODO

### Notes  

see https://help.ubuntu.com/lts/serverguide/openldap-server.html for more
detailed instructions on the original setup and
http://www.openldap.org/doc/admin24/replication.html#MirrorMode
for details of the alternate replication strategy.

Note that provision.sh uses a slightly different install
technique for openldap, as I wasnt able to use the hosts file trick to set the
directory dn.
