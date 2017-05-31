#!/bin/bash

function assert_superuser {
        [[ "$(id -u)" != "0" ]] && echo "You need to be 'root' dude." 1>&2 && e$
}

function configure_neutron
{
	 cp "/home/compute1/OpenStack-Ocata/ocata/compute1/config/neutron.conf" "/etc/neutron/neutron.conf"
	 cp "/home/compute1/OpenStack-Ocata/ocata/compute1/config/linuxbridge_agent.ini" "/etc/neutron/plugins/ml2/linuxbridge_agent.ini"
}

function restart_services
{
	service nova-compute restart
	service neutron-linuxbridge-agent restart
}

function main
{
        assert_superuser
#        apt install -y neutron-linuxbridge-agent
	configure_neutron
	restart_services
}

main

