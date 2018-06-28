#!/bin/bash

declare -A servers

servers['cinder1']="bk_cinder_api_admin"
servers['cinder2']="bk_cinder_api_admin"
servers['glance1']="bk_glance_api_admin,bk_glance_registry"
servers['glance2']="bk_glance_api_admin,bk_glance_registry"
servers['heat1']="bk_heat_api_admin,bk_heat_cfn_admin"
servers['heat2']="bk_heat_api_admin,bk_heat_cfn_admin"
servers['keystone1']="bk_keystone_admin,bk_keystone_internal"
servers['keystone2']="bk_keystone_admin,bk_keystone_internal"
servers['munin1']="bk_munin"
servers['munin2']="bk_munin"
servers['munin3']="bk_munin"
servers['mysql1']="bk_mysqlcluster"
servers['mysql2']="bk_mysqlcluster"
servers['mysql3']="bk_mysqlcluster"
servers['neutronapi1']="bk_neutron_api_admin"
servers['neutronapi2']="bk_neutron_api_admin"
servers['novaapi1']="bk_nova_api_admin,bk_nova_metadata,bk_nova_place_admin"
servers['novaapi2']="bk_nova_api_admin,bk_nova_metadata,bk_nova_place_admin"
servers['puppetdb1']="bk_puppetdb"
servers['puppetdb2']="bk_puppetdb"
servers['puppetdb3']="bk_puppetdb"
servers['puppet1']="bk_puppetserver"
servers['puppet2']="bk_puppetserver"
servers['puppet3']="bk_puppetserver"
servers['redis1']="bk_redis"
servers['redis2']="bk_redis"
servers['redis3']="bk_redis"
servers['shiftleader1']="bk_shiftleader"
servers['shiftleader2']="bk_shiftleader"
servers['shiftleader3']="bk_shiftleader"
servers['sensu1']="bk_uchiwa"
servers['sensu2']="bk_uchiwa"
servers['sensu3']="bk_uchiwa"

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


