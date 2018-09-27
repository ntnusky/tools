#!/bin/bash

if [[ $# -ne 1 ]]; then
	echo "Usage: $0 <machine-id>"
	exit 1
fi

serverid=$1
servername=$(openstack server show $serverid -f value -c name)
image=$(openstack server show $serverid -f value -c image)

if [[ $? -ne 0 ]]; then
	echo "You does not have access to the machine $serverid"
	exit 2
fi

if [[ $image =~ .*([0-9a-f]{8}\-[0-9a-f]{4}\-[0-9a-f]{4}\-[0-9a-f]{4}\-[0-9a-f]{12}).* ]]; then
	imageID=${BASH_REMATCH[1]}
else
	echo "Could not find the image-id"
	exit 3
fi

if [[ ! -e ${imageID}.raw ]]; then
	echo "Baseimage is not stored locally. Downloading it from ceph."
	sudo rbd -p images export $imageID ${imageID}.raw
fi

if [[ -e ${servername}.raw ]]; then
	echo "The server image is already here."
else
	echo "The server image is missing. Downloading it from ceph."
	sudo rbd -p volumes export ${serverid}_disk "${servername}.raw"
fi

echo "Start merging $imagename with the base-image"
./mergeImage.sh "${servername}.raw" ${imageID}.raw

echo "Uploading the image to glance"
openstack image create --file "${servername}.raw.new" "REBUILT: ${servername}"

echo "Deleting the vm-image and the rebuilt image from local disk"
rm -f "${servername}.raw"
rm -f "${servername}.raw.new"

echo "Finished"
