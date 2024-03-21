FROM debian:bookworm-slim

RUN apt-get -y update && apt-get -y install zfsutils-linux

ENTRYPOINT []
