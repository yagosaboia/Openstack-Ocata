#!/bin/bash

function assert_superuser {
        [[ "$(id -u)" != "0" ]] && echo "You need to be 'root' dude." 1>&2 && e$
}

function main
{
	openstack flavor create --id 0 --vcpus 1 --ram 64 --disk 1 m1.nano
	. "/home/openstack/OpenStack-Ocata/ocata/controller/admin-demo/demo-openrc"
	ssh-keygen -q -N ""
	openstack keypair create --public-key ~/.ssh/id_rsa.pub mykey
	openstack keypair list
	
}

main
