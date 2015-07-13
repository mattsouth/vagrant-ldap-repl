vagrant-ldap-repl
============

Provision multiple Ubuntu 14.04 VirtualBox VMs with replicated openldap directory, hub -> node{X}

### Dependencies:
* VirtualBox
* Vagrant

### Installation:
```bash
git clone git@github.com:mattsouth/vagrant-ldap-repl.git
cd vagrant-xnat-ldap
./build.sh
```
Once installed, the replicated ldap directory is available at:
* ldap://192.168.50.50 (hub)
* ldap://192.168.50.51 (node1)
* ldap://192.168.50.52 (node2)

The directories are available read-only with anonymous authentication.
To write to the hub directory you will need to logon with the User DN 'cn=admin,dc=test,dc=net' and password 'admin'.  
The node directories are read only and can only be updated via updates pushed from the hub.

see https://help.ubuntu.com/lts/serverguide/openldap-server.html for more
detailed instructions.  Note that provision.sh uses a slightly different install
technique for openldap, as I wasnt able to use the hosts file trick to set the
directory dn.
