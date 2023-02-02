FROM ubuntu:22.04

RUN sed -Ei 's/(archive|security)\.ubuntu\.com/mirrors.ustc.edu.cn/g' /etc/apt/sources.list && \
    apt-get update && \
    apt-get -y upgrade && \
    apt-get -y install --no-install-recommends rsync zstd && \
    apt-get clean

CMD ["/srv/labstrap"]
