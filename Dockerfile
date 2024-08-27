FROM ubuntu:22.04

ARG APT_SOURCE=http://mirrors.ustc.edu.cn
ENV APT_SOURCE=$APT_SOURCE

RUN sed -Ei "s,https?://(archive|security)\.ubuntu\.com,$APT_SOURCE,g" /etc/apt/sources.list && \
    apt-get update && \
    apt-get -y upgrade && \
    apt-get -y install --no-install-recommends libcap2-bin rsync zstd && \
    apt-get clean

CMD ["/srv/labstrap"]
