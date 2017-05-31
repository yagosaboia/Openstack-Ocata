#!/bin/bash

function assert_superuser {
	[[ "$(id -u)" != "0" ]] && echo "You need to be 'root' dude." 1>&2 && exit 1
}

function configure_nova
{
	cp "/home/compute1/OpenStack-Ocata/ocata/compute1/config/nova.conf" "/etc/nova/nova.conf"
	cp "/home/compute1/OpenStack-Ocata/ocata/compute1/config/nova-compute.conf" "/etc/nova/nova-compute.conf"

}

function main
{
	assert_superuser
#	apt install -y nova-compute
	configure_nova
	service nova-compute restart
}

main
