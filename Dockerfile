FROM ubuntu:22.04@sha256:77906da86b60585ce12215807090eb327e7386c8fafb5402369e421f44eff17e

RUN  apt-get install python-software-properties && \
 apt-add-repository ppa:zfs-native/stable && \
 apt-get update && \
 apt-get install ubuntu-zfs libzfs-dev

ENTRYPOINT []
