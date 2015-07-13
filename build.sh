#!/bin/bash
# This script is used to reduce unnecessary replication in this project.
# It populates three directories (hub, node1, node2) that can be used to
# provision three VMs for testing ldap replication

# build hub
cp Vagrantfile hub/.
cp dpkg.txt hub/.
cp logging.ldif hub/.

# build nodes
function createnode {
  cp Vagrantfile $1/.
  sed -i -e 's/192.168.50.50/$2/g' $1/Vagrantfile
  cp dpkg.txt $1/.
  cp logging.ldif $1/.
  cp provisionnode.sh $1/provision.sh
}
createnode node1 192.168.50.51
createnode node2 192.168.50.52
