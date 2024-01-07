#!/bin/sh

if [ ! -z "$HOSTS" ]; then
  echo "$HOSTS" | tr ',' '\n' > /usr/local/haraka/config/host_list
fi

exec haraka -c /usr/local/haraka 2>&1
