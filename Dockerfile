FROM lsiobase/alpine:3.10

RUN printf "\
@edge http://nl.alpinelinux.org/alpine/edge/main\n\
@testing http://nl.alpinelinux.org/alpine/edge/testing\n\
@community http://nl.alpinelinux.org/alpine/edge/community\n\
" >> /etc/apk/repositories

RUN apk update && apk upgrade
RUN apk add --no-cache youtube-dl@community
RUN apk add --no-cache ffmpeg@community
RUN apk add --no-cache atomicparsley@testing

VOLUME /config
VOLUME /download

COPY etc/ /etc
COPY args.conf /config/args.conf
COPY channels.txt /config/channels.txt

WORKDIR /config

ENV S6_BEHAVIOUR_IF_STAGE2_FAILS="2"
ENV PGID="911"
ENV PUID="911"
ENV youtubedl_interval="60m"
ENV youtubedl_quality="1080"

ENTRYPOINT ["/init"]