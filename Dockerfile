FROM ubuntu:24.04@sha256:a08e551cb33850e4740772b38217fc1796a66da2506d312abe51acda354ff061

RUN apt-get update && apt-get install --no-install-recommends -y zfsutils-linux rsync openssh-client htop pv

ADD https://github.com/bdd/runitor/releases/download/v1.2.0-build.2/runitor-v1.2.0-build.2-linux-amd64  /bin/runitor
RUN chmod +x /bin/runitor

ADD https://github.com/zrepl/zrepl/releases/download/v0.6.1/zrepl-linux-amd64 /bin/zrepl
RUN chmod +x /bin/zrepl

ENTRYPOINT ["tail", "-f", "/dev/null"]
