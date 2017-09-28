#!/bin/bash

set -e

if [[ $# -le 0 ]]; then
  echo "Usage: $0 <seed-host>"
  exit 1
fi

host=$1
cd /

echo Stopping PostgreSQL
systemctl stop postgresql

echo Cleaning up old cluster directory
sudo -u postgres rm -rf /var/lib/postgresql/9.6/main

echo Starting base backup as replicator
sudo -u postgres pg_basebackup -h $host -D /var/lib/postgresql/9.6/main \
    -U replicator -v -P -w -R

echo Startging PostgreSQL
systemctl start postgresql
