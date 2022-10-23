
FROM alpine

ADD mdns-repeater.c mdns-repeater.c

RUN apk add --no-cache build-base bash docker-cli \
    && gcc -O3 -o /bin/mdns-repeater mdns-repeater.c -DHGVERSION="\"1\"" \
    && apk del build-base \
    && rm -rf /var/cache/apk/* /tmp/*

COPY entrypoint.sh /entrypoint.sh
RUN chmod a+x entrypoint.sh

ENV USE_MDNS_REPEATER=1 \
    OPTIONS="" \
    INTERFACES="eth0" \
    DOCKER_NETWORKS="net1 net2"

ENTRYPOINT [ "/entrypoint.sh" ]
