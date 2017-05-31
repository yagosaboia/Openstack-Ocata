#!/bin/bash

MARIADB_PASSWORD="openstack"

function assert_superuser {
	[[ "$(id -u)" != "0" ]] && echo "You need to be 'root' dude." 1>&2 && exit 1
}

function create_nova_database
{
	mysql -u root "-p${MARIADB_PASSWORD}" < "/home/openstack/OpenStack-Ocata/ocata/controller/sql/nova.sql"
}

function register_in_keystone
{
	 . "/home/openstack/OpenStack-Ocata/ocata/controller/admin-demo/admin-openrc"
	openstack user create --domain default --password-prompt nova
	openstack role add --project service --user nova admin
	openstack service create --name nova \
	  --description "OpenStack Compute" compute
	 openstack endpoint create --region RegionOne \
	  compute public http://10.0.2.4:8774/v2.1
	openstack endpoint create --region RegionOne \
	  compute internal http://10.0.2.4:8774/v2.1
	openstack endpoint create --region RegionOne \
	  compute admin http://10.0.2.4:8774/v2.1

	openstack user create --domain default --password-prompt placement
	openstack role add --project service --user placement admin
	openstack service create --name placement --description "Placement API" placement
	openstack endpoint create --region RegionOne placement public http://10.0.2.4/placement
	openstack endpoint create --region RegionOne placement internal http://10.0.2.4/placement
	openstack endpoint create --region RegionOne placement admin http://10.0.2.4/placement

}

function install_nova_packages
{
	apt install -y nova-api nova-conductor nova-consoleauth nova-novncproxy nova-scheduler nova-placement-api
}

function connect_database
{
	su -s /bin/sh -c "nova-manage api_db sync" nova
	su -s /bin/sh -c "nova-manage cell_v2 map_cell0" nova
	su -s /bin/sh -c "nova-manage cell_v2 create_cell --name=cell1 --verbose" nova 109e1d4b-536a-40d0-83c6-5f121b82b650
	su -s /bin/sh -c "nova-manage db sync" nova
	nova-manage cell_v2 list_cells
}

function restart_services
{
	service nova-api restart
	service nova-consoleauth restart
	service nova-scheduler restart
	service nova-conductor restart
	service nova-novncproxy restart
}

function verify_operation
{
	. "/home/openstack/OpenStack-Ocata/ocata/controller/admin-demo/admin-openrc"
#	openstack hypervisor list
#	su -s /bin/sh -c "nova-manage cell_v2 discover_hosts --verbose" nova
	openstack compute service list
	openstack catalog list
	openstack image list

}

function main
{
#	assert_superuser
#	create_nova_database
#	register_in_keystone
#	install_nova_packages
#	cp "/home/openstack/OpenStack-Ocata/ocata/controller/config/nova.conf" "/etc/nova/nova.conf"
#	connect_database
#	restart_services
	verify_operation
}

main
