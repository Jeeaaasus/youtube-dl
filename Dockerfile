FROM alpine:latest

ENV S6_BEHAVIOUR_IF_STAGE2_FAILS="2"
ENV PUID="911"
ENV PGID="911"
ENV youtubedl_interval="3h"
ENV youtubedl_quality="1080"
ENV youtubedl_debug="false"
ENV youtubedl_webui="false"
ENV youtubedl_webuiport="8080"

RUN printf "\
http://dl-cdn.alpinelinux.org/alpine/edge/testing\n\
" >> /etc/apk/repositories

RUN set -ex && \
    ARCH=`uname -m` && \
    if [ "$ARCH" == "x86_64" ]; then \
       echo "Architecture = x86_64" && \
       wget -P /tmp/ https://github.com/just-containers/s6-overlay/releases/latest/download/s6-overlay-amd64.tar.gz && \
       tar xzf /tmp/s6-overlay-amd64.tar.gz -C / && \
       rm -rf /tmp/* ; \
    elif [ "$ARCH" == "aarch64" ]; then \
       echo "Architecture = aarch64" && \
       wget -P /tmp/ https://github.com/just-containers/s6-overlay/releases/latest/download/s6-overlay-aarch64.tar.gz && \
       tar xzf /tmp/s6-overlay-aarch64.tar.gz -C / && \
       rm -rf /tmp/* ; \
    else \
       echo "unknown arch" && \
       exit 1 ; \
    fi


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
    apk upgrade --no-cache && \
    apk add --no-cache \
        bash \
        coreutils \
        shadow \
        tzdata \
        python3 \
        py3-pip \
        ffmpeg && \
    rm -rf \
        /root/.cache \
        /root/packages

RUN set -x && \
    python3 -m pip --no-cache-dir install -r /app/requirements.txt

RUN set -x && \
    wget https://github.com/faissaloo/SponSkrub/releases/latest/download/sponskrub -O /usr/bin/sponskrub && \
    chmod a+rx /usr/bin/sponskrub

RUN set -x && \
    wget https://github.com/yt-dlp/yt-dlp/releases/latest/download/yt-dlp -O /usr/bin/yt-dlp && \
    chmod a+x /usr/bin/yt-dlp

VOLUME /config /downloads

WORKDIR /config

ENTRYPOINT ["/init"]
