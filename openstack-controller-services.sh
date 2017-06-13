#!/bin/bash

if [[ $# -lt 1 ]]; then
  echo "Usage: $0 [step] <start|stop|restart>"
  exit 1
fi

if [[ $1 == "step" ]]; then
  step="/bin/false"
  shift
else
  step="/bin/true"
fi

if [[ $1 != "start" && $1 != "stop" && $1 != "restart" ]]; then
  echo "Usage: $0 [step] <start|stop|restart>"
  exit 2
fi

if [[ ! $(hostname) =~ controller ]]; then
  echo "This tool should only run on controllers"
  exit 3
fi

echo "$1 apache2..."
systemctl $1 apache2
$step || read -n 1 -s -p "Press any key to continue"

echo "$1 glance-registry..."
systemctl $1 glance-registry
$step || read -n 1 -s -p "Press any key to continue"
echo "$1 glance-api..."
systemctl $1 glance-api
$step || read -n 1 -s -p "Press any key to continue"

echo "$1 nova-api..."
systemctl $1 nova-api
$step || read -n 1 -s -p "Press any key to continue"
echo "$1 nova-cert..."
systemctl $1 nova-cert
$step || read -n 1 -s -p "Press any key to continue"
echo "$1 nova-consoleauth..."
systemctl $1 nova-consoleauth
$step || read -n 1 -s -p "Press any key to continue"
echo "$1 nova-scheduler..."
systemctl $1 nova-scheduler
$step || read -n 1 -s -p "Press any key to continue"
echo "$1 nova-conductor..."
systemctl $1 nova-conductor
$step || read -n 1 -s -p "Press any key to continue"
echo "$1 nova-novncproxy..."
systemctl $1 nova-novncproxy
$step || read -n 1 -s -p "Press any key to continue"

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
$step || read -n 1 -s -p "Press any key to continue"

echo "$1 heat-api..."
systemctl $1 heat-api
$step || read -n 1 -s -p "Press any key to continue"
echo "$1 heat-api-cfn..."
systemctl $1 heat-api-cfn
$step || read -n 1 -s -p "Press any key to continue"
echo "$1 heat-engine..."
systemctl $1 heat-engine
$step || read -n 1 -s -p "Press any key to continue"

echo "$1 openvswitch-switch..."
systemctl $1 openvswitch-switch
$step || read -n 1 -s -p "Press any key to continue"

echo "$1 cinder-volume..."
systemctl $1 cinder-volume
$step || read -n 1 -s -p "Press any key to continue"
echo "$1 cinder-api..."
systemctl $1 cinder-api
$step || read -n 1 -s -p "Press any key to continue"
echo "$1 cinder-scheduler..."
systemctl $1 cinder-scheduler
