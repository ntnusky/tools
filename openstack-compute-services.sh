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

if [[ ! $(hostname) =~ compute ]]; then
  echo "This tool should only run on compute nodes"
  exit 2
fi

echo "$1 nova-compute..."
systemctl $1 nova-compute 
$step || read -n 1 -s -p "Press any key to continue"
echo "$1 neutron-openvswitch-agent..."
systemctl $1 neutron-openvswitch-agent
