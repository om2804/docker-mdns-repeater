#!/bin/bash


# These are now set in environment variables that are passed in
#EXTERNAL_INTERFACE="wlan0"
#DOCKER_NETWORK_NAME="fermentrack"
#OPTIONS=""

DOCKER_INTERFACE=$(docker network list | grep "${DOCKER_NETWORK_NAME}" | awk '{print $1}')

#BRIDGE_INTERFACES=($(ip addr | grep "state UP" -A2 | awk '/inet/{print $(NF)}' | grep -P '^(?:(?!veth).)*$' | tr '\n' ' '))

#./mdns-repeater "${EXTERNAL_INTERFACE}" "br-${DOCKER_INTERFACE}" -f

exec mdns-repeater -f ${OPTIONS} "${EXTERNAL_INTERFACE}" "br-${DOCKER_INTERFACE}"

