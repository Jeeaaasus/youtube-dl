FROM lsiobase/alpine:3.10

RUN printf "\
@edge http://dl-cdn.alpinelinux.org./alpine/edge/main\n\
@testing http://dl-cdn.alpinelinux.org/alpine/edge/testing\n\
@community http://dl-cdn.alpinelinux.org/alpine/edge/community\n\
" >> /etc/apk/repositories

RUN apk update && apk upgrade
RUN apk add python3
RUN python3 -m pip install --upgrade youtube_dl
RUN apk add --no-cache ffmpeg@community
RUN apk add --no-cache atomicparsley@testing

COPY etc/ /etc
COPY args.conf /config.default/
COPY channels.txt /config.default/

VOLUME /config
VOLUME /downloads

WORKDIR /config

ENV S6_BEHAVIOUR_IF_STAGE2_FAILS="2"
ENV PGID="911"
ENV PUID="911"
ENV youtubedl_interval="3h"
ENV youtubedl_quality="1080"

ENTRYPOINT ["/init"]
