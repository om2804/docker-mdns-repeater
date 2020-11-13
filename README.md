# docker-mdns-repeater

This image uses Darell Tan's mdns-repeater to bridge/repeat mDNS requests between two network interfaces. 

The intended use of this container is to allow a docker-compose stack running in `net=bridge` mode to be able to communicate with the Docker host's external network.


## Using this container

This container was designed to be used as part of a docker-compose stack. When creating the configuration file:

1. Use docker-compose version 3.5 or later
2. Ensure that each of the bridged containers are part of the same, named network
3. Ensure that the network is named in the `networks:` section
4. Create & link an environment variable file similar to [env.sample](env.sample) to your mdns_reflector image (or set the appropriate environment variables in the stack's configuration)

See `mdns_reflector` in the example docker-compose file below for the other attributes necessary to run the container.

There are three environment variables that must be set:
- **EXTERNAL_INTERFACE** - The interface name of the external interface we want to bridge (e.g. `eth0`, `wlan0`, etc.)
- **DOCKER_NETWORK_NAME** - The name of the named network in the stack (`walled` in the example below)



### Example docker-compose file

```
version: '3.5'

services:
  redis:
    image: redis:5.0
    networks:
      - walled

  nginx:
    image: nginx
    networks:
      - walled

  mdns_reflector:
    image: jdbeeler/mdns-repeater:latest
    network_mode: "host"
    privileged: true
    env_file:
      - ./envs/mdns-reflector
    volumes:
      - /var/run/docker.sock:/var/run/docker.sock

networks:
  walled:
    name: walled
```


## Credits

mdns-repeater.c was obtained from [kennylevinsen's fork](https://github.com/kennylevinsen/mdns-repeater) of [Darell Tan's](https://bitbucket.org/geekman/mdns-repeater) mdns-repeater.c

The original dockerization of mdns-repeater was done by [angelnu](https://github.com/angelnu/docker-mdns_repeater) 

Licensing is GPLv2 as inherited from Darell Tan's mdns-repeater.c.



