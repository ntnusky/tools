#!/bin/bash

declare -A servers

servers['cinder1']="bk_cinder_api_public"
servers['cinder2']="bk_cinder_api_public"
servers['glance1']="bk_glance_api_public"
servers['glance2']="bk_glance_api_public"
servers['heat1']="bk_heat_public,bk_heat_cfn_public"
servers['heat2']="bk_heat_public,bk_heat_cfn_public"
servers['horizon1']="bk_horizon"
servers['horizon2']="bk_horizon"
servers['keystone1']="bk_keystone_public"
servers['keystone2']="bk_keystone_public"
servers['neutronapi1']="bk_neutron_public"
servers['neutronapi2']="bk_neutron_public"
servers['novaapi1']="bk_nova_public"
servers['novaapi2']="bk_nova_public"
servers['novaservices1']="bk_nova_vnc"
servers['novaservices2']="bk_nova_vnc"
servers['shiftleader1']="bk_shiftleader"
servers['shiftleader2']="bk_shiftleader"
servers['shiftleader3']="bk_shiftleader"

if [[ $# -lt 2 ]]; then
  echo "usage: $0 <enable|disable> <servername>"
  exit 1
fi

if [[ ! $1 =~ ^(enable|disable)$ ]]; then
  echo "usage: $0 <enable|disable> <servername>"
  exit 2
fi

action=$1
server=$2

for backend in $(echo ${servers[$server]} | tr , ' '); do
  echo "$action the server $server in the $backend backend."
  echo $action server $backend/$server | nc -U /var/lib/haproxy/stats
done


