#!/bin/bash
# this script tears down vagrant VMs and cleans up the built files
for dir in $(ls -d */)
do
  if [[ $dir == node* ]]
  then
    cd $dir
    vagrant destroy -f
    cd ..
    rm -r $dir
  fi
done
cd hub
vagrant destroy -f
cd ..
rm hub/dpkg.txt
rm hub/Vagrantfile
rm hub/*.ldif
rm hub/*.pem
