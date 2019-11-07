FROM lsiobase/alpine:3.10

RUN apk update && apk upgrade
RUN python3 -m pip install --upgrade youtube-dl
RUN python3 -m pip install --upgrade ffmpeq
RUN python3 -m pip install --upgrade atomicparsley

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
