#!/bin/bash

function assert_superuser {
	[[ "$(id -u)" != "0" ]] && echo "You need to be 'root' dude." 1>&2 && exit 1
}

function main
{
	assert_superuser
	apt install software-properties-common
	add-apt-repository cloud-archive:ocata
	apt update && apt -y dist-upgrade
	apt install -y python-openstackclient
}

main
