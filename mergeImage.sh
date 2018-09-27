#!/bin/bash

if [[ $# -lt 2 ]]; then
        echo "Usage: $0 <imagefile> <basefile>"
        exit 1
fi

imagefile=$1
basefile=$2
newfile=$1.new

if [[ -e "$newfile" ]]; then
	echo "The file $newfile already exists. Delete it or move it before running this script"
	exit 2
fi

if [[ ! -e "$imagefile" ]]; then
	echo "The file $imagefile does not exist"
	exit 3
fi

if [[ ! -e "$basefile" ]]; then
	echo "The file $basefile does not exist"
	exit 4
fi

imagesize=$(stat "$imagefile" -c '%s')
imageblocks=$((imagesize/1048576))
basesize=$(stat "$basefile" -c '%s')
baseblocks=$((basesize/1048576))

if [[ $baseblocks -gt $imageblocks ]]; then
	echo "The base image is bigger than the CoW image. Uncertain on what to do."
	exit 5
fi

i=0
echo "Starting to merge image"
while [[ $i -lt $baseblocks ]]; do
        imageZero=$(dd if="$imagefile" bs=1M count=1 skip=$i 2> /dev/null | xxd -p -c 64 | egrep '0{64}' -v -c)

        if [[ $imageZero -eq 0 ]]; then
                echo From base: $i >> "$newfile.log"
                echo -e -n "\r From base:  $i"
                dd if="$basefile" of="$newfile" bs=1M count=1 skip=$i oflag=append conv=notrunc 2> /dev/null
        else
                echo From image: $i >> "$newfile.log"
                echo -e -n "\r From image: $i"
                dd if="$imagefile" of="$newfile" bs=1M count=1 skip=$i oflag=append conv=notrunc 2> /dev/null
        fi
        ((i++))

        target=$((i*1024*1024)) 
        real=$(stat "$newfile" -c '%s')
        if [[ $target -ne $real ]]; then
                echo "Uhmm? The target-image's size is wrong. Iteration $i, expected $target but is $real"
        fi
done

echo " Done merging"
echo Copying the rest
dd if="$imagefile" of="$newfile" bs=1M skip=$baseblocks oflag=append conv=notrunc 2> /dev/null

echo "The image $newfile is created based on $basefile as base and $imagefile as changes."
