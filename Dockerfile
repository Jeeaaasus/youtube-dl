FROM alpine:latest

ENV S6_BEHAVIOUR_IF_STAGE2_FAILS="2"
ENV PUID="911"
ENV PGID="911"
ENV youtubedl_interval="3h"
ENV youtubedl_quality="1080"
ENV youtubedl_debug="false"

RUN printf "\
@edge http://dl-cdn.alpinelinux.org./alpine/edge/main\n\
@testing http://dl-cdn.alpinelinux.org/alpine/edge/testing\n\
@community http://dl-cdn.alpinelinux.org/alpine/edge/community\n\
" >> /etc/apk/repositories

RUN wget -P /tmp/ https://github.com/just-containers/s6-overlay/releases/latest/download/s6-overlay-amd64.tar.gz && \
    tar xzf /tmp/s6-overlay-amd64.tar.gz -C / && \
    rm -rf /tmp/* 

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

RUN set -x && \
    apk update && \
    apk upgrade && \
    apk add --no-cache \
        bash \
        coreutils \
        shadow \
        tzdata \
        python3 \
        atomicparsley@testing \
        ffmpeg@community \
        py3-pip@community && \
    rm -rf \
        /root/.cache \
        /root/packages

RUN set -x && \
    python3 -m pip --no-cache-dir install youtube_dl

VOLUME /config /downloads

WORKDIR /config

ENTRYPOINT ["/init"]
