FROM debian:12

ARG APT_SOURCE=https://mirrors.ustc.edu.cn
ENV APT_SOURCE=$APT_SOURCE

RUN sed -Ei "s,https?://deb\.debian\.org,$APT_SOURCE,g" /etc/apt/sources.list.d/debian.sources && \
    apt-get update && \
    apt-get -y upgrade && \
    apt-get -y install --no-install-recommends libcap2-bin rsync zstd && \
    apt-get clean

CMD ["/srv/labstrap"]
