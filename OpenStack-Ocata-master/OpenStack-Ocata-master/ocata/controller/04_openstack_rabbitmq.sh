#!/bin/bash

RABBIT_PASS="openstack"

function assert_superuser {
	[[ "$(id -u)" != "0" ]] && echo "You need to be 'root' dude." 1>&2 && exit 1
}

function main
{
	assert_superuser
	apt install rabbitmq-server
	rabbitmqctl add_user openstack $RABBIT_PASS
	rabbitmqctl set_permissions openstack ".*" ".*" ".*"

	rabbitmq-plugins enable rabbitmq_mqtt
	rabbitmq-plugins enable rabbitmq_management
}

main
