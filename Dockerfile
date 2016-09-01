FROM centos:latest
MAINTAINER BBVA Innovation <eurocloud-oneteam.group@bbva.com>
ENV container docker

RUN yum clean all \
    && yum update -y \
    && yum install -y qemu-kvm bridge-utils \
    && yum clean all

ENV LAUNCHER "/usr/libexec/qemu-kvm"

COPY startvm /usr/local/sbin/startvm
RUN chmod u+x /usr/local/sbin/startvm

VOLUME /image
EXPOSE 4555

ENTRYPOINT ["/usr/local/sbin/startvm"]

