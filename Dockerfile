FROM alpine:latest

RUN wget -P /tmp/ http://github.com/just-containers/s6-overlay/releases/download/v1.22.1.0/s6-overlay-amd64.tar.gz && \
    tar xzf /tmp/s6-overlay-amd64.tar.gz -C / && \ 
    #addgroup -S users && \
    #adduser -S nobody -G users && \
    #groupmod -g 1000 users && \
    #useradd -u 911 -U -d /config -s /bin/false nobody -G users && \
    #useradd nobody -G users  && \
    #usermod -G users nobody && \
    rm -rf /tmp/* 

RUN printf "\
@edge http://dl-cdn.alpinelinux.org./alpine/edge/main\n\
@testing http://dl-cdn.alpinelinux.org/alpine/edge/testing\n\
@community http://dl-cdn.alpinelinux.org/alpine/edge/community\n\
" >> /etc/apk/repositories

RUN apk update && \
    apk upgrade && \
    apk add --no-cache \
        bash \
        coreutils \
        shadow \
        tzdata \
        ffmpeg@community \
        atomicparsley@testing && \
    rm -rf \
        /root/.cache \
        /root/packages

RUN apk add python3
RUN python3 -m pip install youtube_dl

COPY root/ /

ENV PUID="911"
ENV PGID="911"
ENV S6_BEHAVIOUR_IF_STAGE2_FAILS="2"
ENV youtubedl_interval="3h"
ENV youtubedl_quality="1080"

RUN addgroup --gid "$PGID" nobody && \
    adduser \
    --disabled-password \
    --gecos "" \
    --home "$(pwd)" \
    --ingroup nobody \
    --no-create-home \
    --uid "$PUID" \
    nobody

VOLUME /config
VOLUME /downloads

WORKDIR /config

ENTRYPOINT ["/init"]
