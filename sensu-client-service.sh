#!/bin/bash

if [[ $# -lt 1 ]]; then
  echo "Usage: $0 <start|stop|restart>"
  exit 1
fi

if [[ $1 != "start" && $1 != "stop" && $1 != "restart" ]]; then
  echo "Usage: $0 <start|stop|restart>"
  exit 2
fi

CMD=$(which systemctl)

echo "$1 sensu-client..."
if [ -z $CMD ]; then
  CMD=$(which service)
fi

case $CMD in
  *service*)
    $CMD sensu-client $1
    ;;
  *systemctl*)
    $CMD $1 sensu-client
    ;;
esac
