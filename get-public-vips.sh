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

KEYSTONE_IP=$($HIERACMD profile::api::keystone::public::ip)
GLANCE_IP=$($HIERACMD profile::api::glance::public::ip)
NEUTRON_IP=$($HIERACMD profile::api::neutron::public::ip)
NOVA_IP=$($HIERACMD profile::api::nova::public::ip)
CINDER_IP=$($HIERACMD profile::api::cinder::public::ip)
HEAT_IP=$($HIERACMD profile::api::heat::public::ip)
HORIZON_IP=$($HIERACMD profile::api::horizon::public::ip)

echo

for HOST in $CONTROLLERS; do
  echo $HOST
  echo '==============='
  SERVICES=$(ssh $HOST "ip a show br-ex | egrep -o \
    '[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[1][0-9]{2}'" 2> /dev/null)
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
        $HORIZON_IP)  echo "HORIZON  ($SERVICE)"
        ;;
      esac
    done
  else echo "Host is unreachable or have no VIPs assigned"
  fi
  echo
done
