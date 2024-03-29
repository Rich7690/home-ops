FROM ubuntu:22.04@sha256:77906da86b60585ce12215807090eb327e7386c8fafb5402369e421f44eff17e

RUN apt-get update && apt-get install -y zfsutils-linux

ADD https://github.com/bdd/runitor/releases/download/v1.2.0-build.2/runitor-v1.2.0-build.2-linux-amd64  /bin/runitor
RUN chmod +x /bin/runitor

ENTRYPOINT []
