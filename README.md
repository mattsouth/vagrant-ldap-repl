vagrant-ldap-repl
============

Provision two Ubuntu 14.04 VirtualBox VMs with replicated openldap directory, hub -> node{X}

### Dependencies:
* VirtualBox
* Vagrant

### Installation:
```bash
git clone git@github.com:mattsouth/vagrant-xnat-ldap.git
cd vagrant-xnat-ldap/hub
vagrant up
cd ../node1
vagrant up
```
Once the Vagrant boxes are up and running a replicated ldap directory is available at:
* ldap://192.168.50.50 (hub)
* ldap://192.168.50.51 (node)

The ldap directory is available read-only with anonymous authentication
To write to the directory you will need to logon with the User DN 'dc=dpuk,dc=org' and password 'admin'

see https://help.ubuntu.com/lts/serverguide/openldap-server.html for details of setup.  Note that the install is
slightly different, as I wasnt able to use the hosts file trick indicated to set the default dn.
