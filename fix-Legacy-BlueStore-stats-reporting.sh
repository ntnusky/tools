#!/bin/bash

for file in /var/lib/ceph/osd/*; do
  [[ $file =~ [0-9]+$ ]]
  id=${BASH_REMATCH[0]};

  echo "Stopping OSD $id"
  systemctl stop ceph-osd@${id}.service
  echo "Repairing OSD $id"
  ceph-bluestore-tool repair --path /var/lib/ceph/osd/ceph-${id}
  echo "Starting OSD $id"
  systemctl start ceph-osd@${id}.service
done
