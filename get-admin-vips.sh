#!/bin/bash

HIERA=$(which hiera)

if [ -z "$HIERA" ]; then
  echo 'Missing the hiera-command. Exiting...'
  exit 1
fi

HIERAFILE='/etc/puppet/hieradata/common.yaml'
HIERACONFIG='/etc/puppet/hiera.yaml'
HIERACMD="$HIERA -y $HIERAFILE -c $HIERACONFIG"

CONTROLLERS=$(cat /root/hostlists/controller)

KEYSTONE_IP=$($HIERACMD profile::api::keystone::admin::ip)
GLANCE_IP=$($HIERACMD profile::api::glance::admin::ip)
NEUTRON_IP=$($HIERACMD profile::api::neutron::admin::ip)
NOVA_IP=$($HIERACMD profile::api::nova::admin::ip)
CINDER_IP=$($HIERACMD profile::api::cinder::admin::ip)
HEAT_IP=$($HIERACMD profile::api::heat::admin::ip)
RABBITMQ_IP=$($HIERACMD profile::rabbitmq::ip)
MYSQL_IP=$($HIERACMD profile::mysql::ip)
MEMCACHE_IP=$($HIERACMD profile::memcache::ip)

echo

for HOST in $CONTROLLERS; do
  echo $HOST
  echo '==============='
  SERVICES=$(ssh $HOST "ip a | egrep -o \
    '[0-9]{1,3}\.[0-9]{1,3}\.[1]\.[1][0-9]{2}'" 2> /dev/null)
  if [ ! -z "$SERVICES" ]; then
    for SERVICE in $SERVICES; do
      case $SERVICE in
        $KEYSTONE_IP) echo "KEYSTONE ($SERVICE)"
        ;;
        $GLANCE_IP)   echo "GLANCE   ($SERVICE)"
        ;;
        $NEUTRON_IP)  echo "NEUTRON  ($SERVICE)"
        ;;
        $NOVA_IP)     echo "NOVA     ($SERVICE)"
        ;;
        $CINDER_IP)   echo "CINDER   ($SERVICE)"
        ;;
        $HEAT_IP)     echo "HEAT     ($SERVICE)"
        ;;
        $RABBITMQ_IP) echo "RABBITMQ ($SERVICE)"
        ;;
        $MYSQL_IP)    echo "MYSQL    ($SERVICE)"
        ;;
        $MEMCACHE_IP) echo "MEMCACHE ($SERVICE)"
        ;;
      esac
    done
  else echo "Host is unreachable or have no VIPs assigned"
  fi
  echo
done
