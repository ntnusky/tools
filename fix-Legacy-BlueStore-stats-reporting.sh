#!/bin/bash

for file in /var/lib/ceph/osd/*; do
  [[ $file =~ [0-9]+$ ]]
  id=${BASH_REMATCH[0]};

  systemctl stop ceph-osd@${id}.service
  ceph-bluestore-tool repair --path /var/lib/ceph/osd/ceph-${id}
  systemctl start ceph-osd@${id}.service
done
