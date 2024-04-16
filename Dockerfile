FROM ubuntu:22.04@sha256:193c13d13beb11bedfc07587d208f880bce5535dc5f5cbb277e22a3847cc84a8

RUN apt-get update && apt-get install -y zfsutils-linux

ADD https://github.com/bdd/runitor/releases/download/v1.2.0-build.2/runitor-v1.2.0-build.2-linux-amd64  /bin/runitor
RUN chmod +x /bin/runitor

ENTRYPOINT []
