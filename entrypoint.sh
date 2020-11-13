#!/bin/bash

# These are now set in environment variables that are passed in
#EXTERNAL_INTERFACE="wlan0"
#DOCKER_NETWORK_NAME="fermentrack"
#OPTIONS=""

# This searches the list of docker networks for the network name in order to get the ID, then (below) uses that ID
# to infer the docker interface name.
DOCKER_INTERFACE=$(docker network list | grep "${DOCKER_NETWORK_NAME}" | awk '{print $1}')

# Below is for future use in case I want to try to auto-detect the external interface
#NON_VIRTUAL_INTERFACES=($(ip addr | grep "state UP" -A2 | awk '/inet/{print $(NF)}' | grep -P '^(?:(?!veth).)*$' | tr '\n' ' '))

exec mdns-repeater -f ${OPTIONS} "${EXTERNAL_INTERFACE}" "br-${DOCKER_INTERFACE}"
