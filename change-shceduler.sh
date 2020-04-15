#!/bin/bash

for device in /sys/block/sd*; do
	echo "Setting scheduler for $device to $1"
	echo $1 > ${device}/queue/scheduler
done
