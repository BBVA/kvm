FROM centos:latest
MAINTAINER Innovation <innovation@bbva.com>
ENV container docker

RUN yum clean all \
    && yum update -y \
    && yum install -y qemu-kvm bridge-utils \
    && yum clean all

ENV LAUNCHER "/usr/libexec/qemu-kvm"

# COPY startvm /var/lib/bbva/startvm
# RUN chmod u+x /var/lib/bbva/startvm

VOLUME /var/lib/bbva
VOLUME /image
EXPOSE 4555

ENTRYPOINT ["/var/lib/bbva/startvm"]

