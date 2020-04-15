#!/bin/bash

for device in /sys/block/sd*; do
	echo "Scheduler for $device"
	cat ${device}/queue/scheduler
done
