#!/bin/bash
function assert_superuser {
	[[ "$(id -u)" != "0" ]] && echo "You need to be 'root' dude." 1>&2 && exit 1
}

function install_identity_packages
{
	apt install -y memcached python-memcache
}

function config_memcached
{
	cp "/home/openstack/OpenStack-Ocata/ocata/controller/config/memcached.conf" "/etc/memcached.conf"
}

function restart_services
{
	service memcached restart
}

function main
{
	assert_superuser
	install_identity_packages
	config_memcached
	restart_services
	
}

main
