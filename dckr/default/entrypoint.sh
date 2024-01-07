#!/bin/bash

if [ ! -z "$HOSTS" ]; then
  echo "$HOSTS" | tr ',' '\n' > /usr/local/haraka/config/host_list
fi

exec /opt/haraka/bin/haraka -c /opt/haraka 2>&1
