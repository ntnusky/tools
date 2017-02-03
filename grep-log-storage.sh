#!/bin/bash
for i in $(cat ~/hostlists/storage) ; do 
  echo $i
  ssh $i grep --color=always -rns $1 /var/log
done
