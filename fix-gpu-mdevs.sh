#!/bin/bash

if [[ $(dpkg -l | grep -c python3-osc-placement) -eq 0 ]]; then
  echo The script needs python3-osc-placement
  exit 1
fi

if [[ -z $OS_AUTH_URL ]]; then
  echo "Need to be authenticated to openstack to work."
  exit 2
fi

declare -A config
instances=$(virsh list --all --name)

# Determine mdev uuid's for each VM
for i in ${instances}; do
  config["${i},UUID"]=$(virsh dumpxml $i | grep '<uuid>' | egrep -o '[a-z0-9\-]{36}')
  config["${i},mdev"]=$(virsh dumpxml $i | grep -A 5 mdev | grep uuid | egrep  -o '[a-z0-9\-]{36}')

  providerID=$(openstack resource provider allocation show \
    ${config["${i},UUID"]} -f value -c resource_provider -c resources | \
    grep VGPU | egrep  -o '[a-z0-9\-]{36}')
  
  if [[ ! -z $providerID ]]; then
    name=$(openstack resource provider show ${providerID} -f value -c name)
    if [[ $name =~ pci_([0-9a-f]{4})_([0-9a-f]{2})_([0-9a-f]{2})_([0-9a-f]) ]]; then
      pcidev="${BASH_REMATCH[1]}:${BASH_REMATCH[2]}:${BASH_REMATCH[3]}.${BASH_REMATCH[4]}"
    else
      echo HUPS
    fi

    profile=$(grep $pcidev /etc/nova/nova.conf -b1 | head -n 1 | egrep -o 'nvidia-[0-9]+')

    config["${i},GPUproviderID"]=$providerID
    config["${i},GPUdev"]=$pcidev
    config["${i},Profile"]=$profile
  fi
done

# Create the known mdev's
for i in ${instances}; do
  if [[ ! -z ${config["${i},GPUdev"]} ]]; then
    echo "Creating an mdev with ID ${config["${i},mdev"]}"
    echo "  - at PCI-dev ${config["${i},GPUdev"]} with the ${config["${i},Profile"]} profile"

    echo "${config["${i},mdev"]}" > /sys/class/mdev_bus/${config["${i},GPUdev"]}/mdev_supported_types/${config["${i},Profile"]}/create
  fi
done

function getFree {
  for profile in $(grep ^enabled_vgpu_types /etc/nova/nova.conf | \
      cut -f 2 -d '=' | tr ',' ' '); do
    for dev in $(grep -A 1 vgpu_${profile} /etc/nova/nova.conf | tail -n 1 | \
        cut -d '=' -f 2 | tr ',' ' '); do
      n=$(cat /sys/class/mdev_bus/${dev}/mdev_supported_types/${profile}/available_instances)
      if [[ $n -gt 0 ]]; then
        freeDev="$dev,$profile"
        return
      fi
    done
  done
  freeDev="NONE"
}

# Create valid mdevs for instances not in placement (ie: GPU's which are to be
# deleted. 
for i in ${instances}; do
  if [[ -z ${config["${i},GPUdev"]} ]]; then
    getFree
    if [[ $freeDev != "NONE" ]]; then
      dev=$(echo $freeDev | cut -f 1 -d ',')
      profile=$(echo $freeDev | cut -f 2 -d ',')
      echo "Creating an mdev with ID ${config["${i},mdev"]}"
      echo "  - at PCI-dev ${dev} with the ${profile} profile"

      echo "${config["${i},mdev"]}" > /sys/class/mdev_bus/${dev}/mdev_supported_types/${profile}/create
    else
      echo "FATAL: Cannot find devices to create mdevs on!"
      echo "  Cannot find a place to create mdev ${config["${i},mdev"]}"
      echo "  for insance ${config["${i},UUID"]}"
    fi
  fi
done
