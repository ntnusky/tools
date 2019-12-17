#!/bin/bash

NAME="${1}"
CPU="${2}"
RAM="${3}"
DISK="${4}"
NET="${5}"

if [ $# -ne 5 ]; then
  echo "Usage: $0 <name> <cores> <RAM in MB> <disk in GB> <net>"
  exit 1
fi

virt-install --name $NAME --memory $RAM --vcpus $CPU --cpu host --pxe --boot network,hd --os-variant ubuntu18.04 --disk size=$DISK,pool=vmvg -w network:$NET --autostart --noautoconsole --wait 0
virsh domiflist $NAME
