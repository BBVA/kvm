FROM alpine:latest
MAINTAINER BBVA Innovation <eurocloud-oneteam.group@bbva.com>
ENV container docker

RUN apk -U --no-cache add       \
      qemu                      \
      qemu-system-x86_64        \
      bridge-utils              \
      bash                      \
      dnsmasq                   \
    && rm -rf /var/cache/apk/*

COPY startvm /usr/local/bin/startvm
RUN chmod u+x /usr/local/bin/startvm

VOLUME /image

ENTRYPOINT ["/usr/local/bin/startvm"]
CMD []