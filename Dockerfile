FROM debian:latest

RUN apt-get update && apt-get install -y \
  curl \
  lsb-release && \
  apt-get -y update && apt-get -y install debian-zfs && \
  rm -rf /var/lib/apt/lists/*

ENTRYPOINT []
