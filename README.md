# docker-mdns-repeater

This image uses Darell Tan's mdns-repeater to bridge/repeat mDNS requests between two network interfaces. 

The intended use of this container is to relay mDNS broadcast packets between different network segments, which you typically have when docker containers are operated in `net=bridged` mode.
Packets are synchronized between all given interfaces in all directions.
A typical use would be, to place the relay between your host's external interface and one or more named docker interfaces (see Setup scenarios below).

Image on Docker Hub: https://hub.docker.com/r/jdelker/docker-mdns-repeater

## Using this container

This container was designed to be used as part of a docker-compose stack. When creating the configuration file:

1. Use docker-compose version 3.5 or later
2. Ensure that you use named docker networks, either by explicitly creating them or by referencing the *_default networks created for each docker-compose stack.
3. Provide the required environment variables. See service `mdns-repeater` in the docker-compose examle below.

There are three environment variables that must be set:
- **USE_MDNS_REPEATER** - A flag that can be used to disable the service. Intended use case is if we want to disable the repeater 
- **INTERFACES** - The list of interface names we want to bridge (e.g. `eth0`, `wlan0`, etc.), separated by space.
- **DOCKER_NETWORKS** - Optional list of docker network names, to include in bridging.

NOTE:
The variables `INTERFACES` and `DOCKER_NETWORKS` are complementry.
Docker interfaces names are dynamic and are created with variating names, especially if you use implicit networks as provided through docker-compose. For your convenience, docker network names placed in `DOCKER_NETWORKS` are automatically resolved into their particular interface names and **appended** to `INTERFACES` automatically.

## Setup scenarios

### Option A: Bridge between two (or more) physical host interfaces (Example: eth0 and eth1)

Environment:
```
INTERFACES="eth0 eth1"
```

### Option B: Bridge between the physical host interface and the docker network "smart-home_default"

Environment:
```
INTERFACES="eth0"
DOCKER_NETWORKS="smart-home_default"
```

### Option C: Bridge between two physical host interfaces (eth0, eth1) and two docker networks (smart-home_default, jellyfin)

Environment:
```
INTERFACES="eth0 eth1"
DOCKER_NETWORKS="smart-home_default jellyfin"
```

## The docker-compose file

General Note:
As the repeater requires access to the physical host interfaces, it must be run `privileged` and in `network=host` mode.

Then there are several ways where to define the mdns-repeater service:

### Scenario A: Bridge between two (or more) physical host interfaces (Example: eth0 and eth1)

Here you would probably place the `mdns-repeater` in it's distinct docker-compose file or even run the container directly.
```
version: '3.5'

services:
  mdns-repeater:
    image: jdelker/mdns-repeater:latest
    network_mode: "host"
    privileged: true
    environment:
      INTERFACES: "eth0 eth1"
    volumes:
      - /var/run/docker.sock:/var/run/docker.sock
```

### Option B: Bridge between the physical host interface and the named docker network ("walled")

If the relay is just required for a single docker-compose stack, place it within that stack:

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

  mdns-repeater:
    image: jdelker/mdns-repeater:latest
    network_mode: "host"
    privileged: true
    environment:
      INTERFACES: "eth0"
      DOCKER_NETWORKS: "walled"
    volumes:
      - /var/run/docker.sock:/var/run/docker.sock

networks:
  walled:
    name: walled
```

### Option C: Establish a common bridge between two host interfaces (eth0, eth1) and two docker-compose stacks (smart-home, jellyfin)

This would just be an extension of scenario A, but also include two docker networks.
With two separate docker-compose stacks named "smart-home" and "jellyfin", add a new central docker-compose for "mdns-repeater".
```
version: '3.5'

services:
  mdns-repeater:
    image: jdelker/mdns-repeater:latest
    network_mode: "host"
    privileged: true
    environment:
      INTERFACES: "eth0 eth1"
      DOCKER_NETWORKS: "smart-home_default jellyfin_default"
    volumes:
      - /var/run/docker.sock:/var/run/docker.sock
```


## Credits

mdns-repeater.c was obtained from [kennylevinsen's fork](https://github.com/kennylevinsen/mdns-repeater) of [Darell Tan's](https://bitbucket.org/geekman/mdns-repeater) mdns-repeater.c

The original dockerization of mdns-repeater was done by [angelnu](https://github.com/angelnu/docker-mdns_repeater) 

Licensing is GPLv2 as inherited from Darell Tan's mdns-repeater.c.



