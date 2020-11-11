FROM alpine:latest

ENV S6_BEHAVIOUR_IF_STAGE2_FAILS="2"
ENV PUID="911"
ENV PGID="911"
ENV youtubedl_interval="3h"
ENV youtubedl_quality="1080"

RUN printf "\
@edge http://dl-cdn.alpinelinux.org./alpine/edge/main\n\
@testing http://dl-cdn.alpinelinux.org/alpine/edge/testing\n\
@community http://dl-cdn.alpinelinux.org/alpine/edge/community\n\
" >> /etc/apk/repositories

RUN wget -P /tmp/ http://github.com/just-containers/s6-overlay/releases/download/v2.1.0.0/s6-overlay-amd64.tar.gz && \
    tar xzf /tmp/s6-overlay-amd64.tar.gz -C / && \
    rm -rf /tmp/* 

RUN set -x && \
    apk update && \
    apk upgrade && \
    apk add --no-cache \
        bash \
        coreutils \
        shadow \
        tzdata \
        git \
        python3 \
        atomicparsley@testing \
        ffmpeg@community \
        py3-pip@community && \
    python3 -m pip --no-cache-dir install youtube_dlc && \
    rm -rf \
        /root/.cache \
        /root/packages

RUN addgroup --gid "$PGID" abc && \
    adduser \
        --gecos "" \
        --disabled-password \
        --no-create-home \
        --uid "$PUID" \
        --ingroup abc \
        --shell /bin/bash \
        abc 

COPY root/ /

VOLUME /config /downloads

WORKDIR /config

ENTRYPOINT ["/init"]
