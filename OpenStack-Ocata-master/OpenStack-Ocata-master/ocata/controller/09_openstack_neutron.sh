#!/bin/bash
MARIADB_PASSWORD="openstack"

function assert_superuser {
	[[ "$(id -u)" != "0" ]] && echo "You need to be 'root' dude." 1>&2 && exit 1
}

function create_neutron_database
{
	 mysql -u root "-p${MARIADB_PASSWORD}" < "/home/openstack/OpenStack-Ocata/ocata/controller/sql/neutron.sql"

}

function register_in_keystone
{
	. "/home/openstack/OpenStack-Ocata/ocata/controller/admin-demo/admin-openrc"
        openstack user create --domain default --password-prompt neutron
        openstack role add --project service --user neutron admin
        openstack service create --name neutron --description "OpenStack Networking" network
        openstack endpoint create --region RegionOne network public http://10.0.2.4:9696
        openstack endpoint create --region RegionOne network internal http://10.0.2.4:9696
        openstack endpoint create --region RegionOne network admin http://10.0.2.4:9696

}

function install_neutron_packages
{
	apt install -y neutron-server neutron-plugin-ml2 neutron-linuxbridge-agent neutron-l3-agent neutron-dhcp-agent neutron-metadata-agent
}

function config_neutron
{
	 cp "/home/openstack/OpenStack-Ocata/ocata/controller/config/neutron.conf" "/etc/neutron/neutron.conf"
	 cp "/home/openstack/OpenStack-Ocata/ocata/controller/config/ml2_conf.ini" "/etc/neutron/plugins/ml2/ml2_conf.ini"
	 cp "/home/openstack/OpenStack-Ocata/ocata/controller/config/linuxbridge_agent.ini" "/etc/neutron/plugins/ml2/linuxbridge_agent.ini"
	 cp "/home/openstack/OpenStack-Ocata/ocata/controller/config/l3_agent.ini" "/etc/neutron/l3_agent.ini"
	 cp "/home/openstack/OpenStack-Ocata/ocata/controller/config/dhcp_agent.ini" "/etc/neutron/dhcp_agent.ini"
	 cp "/home/openstack/OpenStack-Ocata/ocata/controller/config/metadata_agent.ini" "/etc/neutron/metadata_agent.ini"
	 cp "/home/openstack/OpenStack-Ocata/ocata/controller/config/nova.conf" "/etc/nova/nova.conf"
	su -s /bin/sh -c "neutron-db-manage --config-file /etc/neutron/neutron.conf \
	  --config-file /etc/neutron/plugins/ml2/ml2_conf.ini upgrade head" neutron

}

function restart_services
{
	service nova-api restart
	service neutron-server restart
	service neutron-linuxbridge-agent restart
	service neutron-dhcp-agent restart
	service neutron-metadata-agent restart
	service neutron-l3-agent restart
}

function verify_operation
{
	. "/home/openstack/OpenStack-Ocata/ocata/controller/admin-demo/admin-openrc"
	openstack extension list --network
	openstack network agent list
}

function main
{
#	assert_superuser
#	create_neutron_database
#	register_in_keystone
#	install_neutron_packages
#	config_neutron
#	restart_services
	verify_operation
}

main
