FROM ubuntu:24.04@sha256:186072bba1b2f436cbb91ef2567abca677337cfc786c86e107d25b7072feef0c

RUN apt-get update && apt-get install --no-install-recommends -y zfsutils-linux rsync openssh-client htop pv ca-certificates

ADD https://github.com/bdd/runitor/releases/download/v1.4.1-build.4/runitor-v1.4.1-build.4-linux-amd64 /bin/runitor
RUN chmod +x /bin/runitor

ADD https://github.com/zrepl/zrepl/releases/download/v0.6.1/zrepl-linux-amd64 /bin/zrepl
RUN chmod +x /bin/zrepl

RUN mkdir -p /etc/zrepl
COPY zrepl.yml /etc/zrepl/zrepl.yml

ENTRYPOINT ["tail", "-f", "/dev/null"]
