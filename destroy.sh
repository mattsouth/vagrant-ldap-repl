#!/bin/bash
# this script tears down vagrant VMs and cleans up the built files
cd node2
vagrant destroy -f
cd ../node1
vagrant destroy -f
cd ../hub
vagrant destroy -f
cd ..
rm -r node1
rm -r node2
rm hub/dpkg.txt
rm hub/logging.ldif
rm hub/Vagrantfile
rm -r hub/.vagrant
