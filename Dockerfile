FROM centos:latest
MAINTAINER BBVA Innovation <eurocloud-oneteam.group@bbva.com>
ENV container docker

RUN yum clean all \
    && yum update -y \
    && yum install -y qemu-kvm bridge-utils iproute telnet \
    && yum clean all

COPY startvm /usr/local/bin/startvm
RUN chmod u+x /usr/local/bin/startvm

VOLUME /image
EXPOSE 4555

ENTRYPOINT ["/usr/local/bin/startvm"]

