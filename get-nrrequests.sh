#!/bin/bash

for device in /sys/block/sd*; do
	echo "Queue-length for $device"
	cat ${device}/queue/nr_requests
done
