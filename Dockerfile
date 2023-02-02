FROM ubuntu:22.04

ARG APT_SOURCE=mirrors.ustc.edu.cn
ENV APT_SOURCE=$APT_SOURCE

RUN sed -Ei "s/(archive|security)\.ubuntu\.com/$APT_SOURCE/g" /etc/apt/sources.list && \
    apt-get update && \
    apt-get -y upgrade && \
    apt-get -y install --no-install-recommends rsync zstd && \
    apt-get clean

CMD ["/srv/labstrap"]
