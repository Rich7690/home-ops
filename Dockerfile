FROM ubuntu:24.04@sha256:59a458b76b4e8896031cd559576eac7d6cb53a69b38ba819fb26518536368d86

RUN apt-get update && apt-get install --no-install-recommends -y zfsutils-linux rsync openssh-client htop pv

ADD https://github.com/bdd/runitor/releases/download/v1.2.0-build.2/runitor-v1.2.0-build.2-linux-amd64  /bin/runitor
RUN chmod +x /bin/runitor

ADD https://github.com/zrepl/zrepl/releases/download/v0.6.1/zrepl-linux-amd64 /bin/zrepl
RUN chmod +x /bin/zrepl

ENTRYPOINT ["tail", "-f", "/dev/null"]
