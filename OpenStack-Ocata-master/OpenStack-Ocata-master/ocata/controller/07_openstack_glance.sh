#!/bin/bash
ADMIN_TOKEN="406088b3e19f7131ebd4"
MARIADB_PASSWORD="openstack"

GLANCE_DB_PASSWORD="openstack"
KEYSTONE_USER_GLANCE_PASSWORD="openstack"

EMAIL_GLANCE="glance@example.com"

function assert_superuser {
        [[ "$(id -u)" != "0" ]] && echo "You need to be 'root' dude." 1>&2 &&$
}


function create_glance_database
{
	mysql -u root "-p${MARIADB_PASSWORD}" < "/home/openstack/OpenStack-Ocata/ocata/controller/sql/glance.sql"
}

function register_in_keystone
{
	 . "/home/openstack/OpenStack-Ocata/ocata/controller/admin-demo/admin-openrc"	
	 openstack user create --domain default --password-prompt glance
	 openstack role add --project service --user glance admin
	 openstack service create --name glance \
	  --description "OpenStack Image" image
	 openstack endpoint create --region RegionOne \
	  image public http://10.0.2.4:9292
	openstack endpoint create --region RegionOne \
	  image internal http://10.0.2.4:9292
	openstack endpoint create --region RegionOne \
	  image admin http://10.0.2.4:9292
}

function configure_glance
{
	cp "/home/openstack/OpenStack-Ocata/ocata/controller/config/glance-api.conf" "/etc/glance/glance-api.conf"
	cp "/home/openstack/OpenStack-Ocata/ocata/controller/config/glance-registry.conf" "/etc/glance/glance-registry.conf"
}

function restart_services
{
	service glance-registry restart
	service glance-api restart
	remove_if_exists "/var/lib/glance/glance.sqlite"
}

function remove_if_exists {
	[[ -f "$1" ]] && rm -f "$1"
}

function verify_operation
{
	 . "/home/openstack/OpenStack-Ocata/ocata/controller/admin-demo/admin-openrc"
	wget -P /tmp http://download.cirros-cloud.net/0.3.5/cirros-0.3.5-x86_64-disk.img
	openstack image create "cirros" \
	  --file /tmp/cirros-0.3.5-x86_64-disk.img \
	  --disk-format qcow2 --container-format bare \
	  --public

	openstack image list
}

function main
{
#	assert_superuser
#	create_glance_database
#	register_in_keystone

#	apt install -y glance
#	configure_glance
#	su -s /bin/sh -c "glance-manage db_sync" glance
#	restart_services

	verify_operation
}

main

