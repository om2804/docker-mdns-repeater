#!/bin/bash

ifnames=(${INTERFACES})

# determine interface names for all given docker networks
for dn in ${DOCKER_NETWORKS}; do
  ifname=$(docker network list | grep "$dn" | awk '{print $1}')
  if [[ -z $ifname ]]; then
    echo "unable to find docker interface for $dn" > /dev/stderr
  fi

  ifnames+=("br-$ifname")
done

if [[ ${USE_MDNS_REPEATER} -eq 1 ]]; then
  exec mdns-repeater ${OPTIONS} ${ifnames[@]}
else
  # If the local user has disabled the app, then just sleep forever
  sleep infinity
fi
