#!/bin/bash
ADMIN_TOKEN="406088b3e19f7131ebd4"
MARIADB_PASSWORD="openstack"
KEYSTONE_DB_PASSWORD="openstack"
USER_ADMIN_PASSWORD="openstack"
USER_DEMO_PASSWORD="openstack"
EMAIL_ADMIN="admin@example.com"
EMAIL_DEMO="demo@example.com"

function assert_superuser {
	[[ "$(id -u)" != "0" ]] && echo "You need to be 'root' dude." 1>&2 && exit 1
}

function create_keystone_database
{
	mysql -u root "-p${MARIADB_PASSWORD}" < "/home/openstack/OpenStack-Ocata/ocata/controller/sql/keystone.sql"
}

function install_keystone
{
	apt install -y keystone
}

function config_keystone
{
	cp "/home/openstack/OpenStack-Ocata/ocata/controller/config/keystone.conf" "/etc/keystone/keystone.conf"
}

function connect_database
{
	 su -s /bin/sh -c "keystone-manage db_sync" keystone
}

function initializate_fernet
{
	 keystone-manage fernet_setup --keystone-user keystone --keystone-group keystone
	 keystone-manage credential_setup --keystone-user keystone --keystone-group keystone
}

function bootstrap_keystone
{
	keystone-manage bootstrap --bootstrap-password openstack \
  --bootstrap-admin-url http://10.0.2.4:35357/v3/ \
  --bootstrap-internal-url http://10.0.2.4:5000/v3/ \
  --bootstrap-public-url http://10.0.2.4:5000/v3/ \
  --bootstrap-region-id RegionOne
}

function config_apache
{
	cp "/home/openstack/OpenStack-Ocata/ocata/controller/config/apache2.conf" "/etc/apache2/apache2.conf"
}

function restart_apache_service
{
	service apache2 restart
	remove_if_exists "/var/lib/keystone/keystone.db"
}

function remove_if_exists {
	[[ -f "$1" ]] && rm -f "$1"
}

function create_auth_user_and_role
{
	export OS_USERNAME=admin
	export OS_PASSWORD=openstack
	export OS_PROJECT_NAME=admin
	export OS_USER_DOMAIN_NAME=Default
	export OS_PROJECT_DOMAIN_NAME=Default
	export OS_AUTH_URL=http://10.0.0.4:35357/v3
	export OS_IDENTITY_API_VERSION="3"

	openstack project create --domain default \
	  --description "Service Project" service

	openstack project create --domain default \
	  --description "Demo Project" demo

	openstack user create --domain default \
	  --password-prompt demo

	openstack role create user
}

function verify_operation
{
	 unset OS_AUTH_URL OS_PASSWORD
	openstack --os-auth-url http://10.0.2.4:35357/v3 \
	  --os-project-domain-name default --os-user-domain-name default \
	  --os-project-name admin --os-username admin token issue

	openstack --os-auth-url http://10.0.2.4:5000/v3 \
	  --os-project-domain-name default --os-user-domain-name default \
	  --os-project-name demo --os-username demo token issue
}

function main
{
#	assert_superuser
#	create_keystone_database
#	install_keystone
#	config_keystone
#	connect_database
#	initializate_fernet
#	bootstrap_keystone
#	config_apache

	create_auth_user_and_role
	verify_operation
	. "/home/openstack/OpenStack-Ocata/ocata/controller/admin-demo/admin-openrc"

	openstack token issue
}

main
