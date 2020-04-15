#!/bin/bash

for device in /sys/block/sd*; do
	echo "Setting nr_requests for $device to $1"
	echo $1 > ${device}/queue/nr_requests
done
