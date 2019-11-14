FROM alpine:latest

RUN \
wget -P /tmp/ http://github.com/just-containers/s6-overlay/releases/download/v1.22.1.0/s6-overlay-amd64.tar.gz && \
tar xzf /tmp/s6-overlay-amd64.tar.gz -C / && \ 
groupmod -g 1000 users && \
useradd -u 911 -U -d /config -s /bin/false abc && \
usermod -G users abc && \
rm -rf /tmp/* 

RUN printf "\
@edge http://dl-cdn.alpinelinux.org./alpine/edge/main\n\
@testing http://dl-cdn.alpinelinux.org/alpine/edge/testing\n\
@community http://dl-cdn.alpinelinux.org/alpine/edge/community\n\
" >> /etc/apk/repositories

RUN \
apk update && apk upgrade && \
apk add --no-cache \
    coreutils \
    bash \
    tzdata && \
rm -rf \
    /tmp/* \
    /root/.cache \
    /root/packages

RUN apk add python3
RUN python3 -m pip install --upgrade youtube_dl
RUN apk add --no-cache ffmpeg@community
RUN apk add --no-cache atomicparsley@testing

COPY root/ /

VOLUME /config
VOLUME /downloads

WORKDIR /config

ENV S6_BEHAVIOUR_IF_STAGE2_FAILS="2"
ENV PGID="911"
ENV PUID="911"
ENV youtubedl_interval="3h"
ENV youtubedl_quality="1080"

ENTRYPOINT ["/init"]
