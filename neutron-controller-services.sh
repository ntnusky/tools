#!/bin/bash

if [[ $# -le 1 ]]; then
  echo "Usage: $0 [step] <start|stop|restart>"
  exit 1
fi

if [[ $1 -eq step ]]; then
  step="/bin/false"
  shift
else
  step="/bin/true"
fi

if [[ $1 != "start" && $1 != "stop" && $1 != "restart" ]]; then
  echo "Usage: $0 [step] <start|stop|restart>"
  exit 1
fi

if [[ ! $(hostname) =~ controller ]]; then
  echo "This tool should only run on controllers"
  exit 2
fi

echo "$1 neutron-openvswitch-agent..."
systemctl $1 neutron-openvswitch-agent 
$step || read -n 1 -s -p "Press any key to continue"
echo "$1 neutron-l3-agent..."
systemctl $1 neutron-l3-agent 
$step || read -n 1 -s -p "Press any key to continue"
echo "$1 neutron-dhcp-agent..."
systemctl $1 neutron-dhcp-agent 
$step || read -n 1 -s -p "Press any key to continue"
echo "$1 neutron-metadata-agent..."
systemctl $1 neutron-metadata-agent 
$step || read -n 1 -s -p "Press any key to continue"
echo "$1 neutron-server..."
systemctl $1 neutron-server
