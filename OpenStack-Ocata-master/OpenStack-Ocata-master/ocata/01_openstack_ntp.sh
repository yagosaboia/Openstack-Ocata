#!/bin/bash

function assert_superuser {
	[[ "$(id -u)" != "0" ]] && echo "You need to be 'root' dude." 1>&2 && exit 1
}

function config_chrony_server
{
	cp "/home/openstack/OpenStack-Ocata/ocata/config/chrony.conf" "/etc/chrony/chrony.conf"

}

function config_chrony_client
{
	cp "/home/compute1/ocata/conf/chrony.conf" "/etc/chrony/chrony.conf"

}

function restart_chrony
{
	service chrony restart
}

function main
{
	assert_superuser
	apt-get install -y chrony
	config_chrony_server
	config_chrony_client
	restart_chrony
}

main
