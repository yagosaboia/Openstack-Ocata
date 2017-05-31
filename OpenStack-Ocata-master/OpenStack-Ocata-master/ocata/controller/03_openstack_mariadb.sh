#!/bin/bash

function assert_superuser {
	[[ "$(id -u)" != "0" ]] && echo "You need to be 'root' dude." 1>&2 && exit 1
}

function install_mariadb
{
	apt install -y mariadb-server python-pymysql
}

function config_mariadb
{
	cp "/home/openstack/OpenStack-Ocata/ocata/controller/config/99-openstack.cnf" "/etc/mysql/mariadb.conf.d/99-openstack.cnf"
}

function main
{
	assert_superuser
	install_mariadb
	config_mariadb
	service mysql restart
	mysql_secure_installation
}

main
