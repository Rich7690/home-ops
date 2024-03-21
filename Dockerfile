FROM ubuntu:22.04

RUN  apt-get install python-software-properties && \
 apt-add-repository ppa:zfs-native/stable && \
 apt-get update && \
 apt-get install ubuntu-zfs libzfs-dev

ENTRYPOINT []
