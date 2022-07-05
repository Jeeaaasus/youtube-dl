FROM debian:11-slim

ENV S6_BEHAVIOUR_IF_STAGE2_FAILS="2" \
    PUID="911" \
    PGID="911" \
    UMASK="022" \
    youtubedl_debug="false" \
    youtubedl_lockfile="false" \
    youtubedl_webui="false" \
    youtubedl_webuiport="8080" \
    youtubedl_cookies="false" \
    youtubedl_subscriptions="false" \
    youtubedl_watchlater="false" \
    youtubedl_interval="3h" \
    youtubedl_quality="1080" 

RUN set -x && \
    addgroup --gid "$PGID" abc && \
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
    apt update && \
    apt install -y \
        wget \
        python3 \
        python3-pip && \
    apt clean && \
    python3 -m pip --no-cache-dir install -r /app/requirements.txt && \
    rm -rf \
        /var/lib/apt/lists/* \
        -rf /tmp/* \
        /app/requirements.txt

RUN set -x && \
    ARCH=`uname -m` && \
    if [ "$ARCH" = "x86_64" ]; then \
        wget -q 'https://github.com/yt-dlp/FFmpeg-Builds/releases/download/latest/ffmpeg-master-latest-linux64-gpl.tar.xz' -O - | tar -xJ -C /tmp/ --one-top-level=ffmpeg && \
        chmod -R a+x /tmp/ffmpeg/* && \
        mv $(find /tmp/ffmpeg/* -name ffmpeg) /usr/local/bin/ && \
        mv $(find /tmp/ffmpeg/* -name ffprobe) /usr/local/bin/ && \
        mv $(find /tmp/ffmpeg/* -name ffplay) /usr/local/bin/ && \
        rm -rf /tmp/* ; \
    else \
        if [ "$ARCH" = "aarch64" ]; then ARCH='arm64'; fi && \
        wget -q "https://johnvansickle.com/ffmpeg/builds/ffmpeg-git-${ARCH}-static.tar.xz" -O - | tar -xJ -C /tmp/ --one-top-level=ffmpeg && \
        chmod -R a+x /tmp/ffmpeg/* && \
        mv $(find /tmp/ffmpeg/* -name ffmpeg) /usr/local/bin/ && \
        mv $(find /tmp/ffmpeg/* -name ffprobe) /usr/local/bin/ && \
        rm -rf /tmp/* ; \
    fi

RUN set -ex && \
    ARCH=`uname -m` && \
    if [ "$ARCH" = "x86_64" ]; then \
        s6_package="s6-overlay-amd64.tar.gz" ; \
    elif [ "$ARCH" = "aarch64" ]; then \
        s6_package="s6-overlay-aarch64.tar.gz" ; \
    else \
        echo "unknown arch: ${ARCH}" && \
        exit 1 ; \
    fi && \
    wget -P /tmp/ https://github.com/just-containers/s6-overlay/releases/download/v2.2.0.3/${s6_package} && \
    tar -xzf /tmp/${s6_package} -C / && \
    rm -rf /tmp/*

RUN set -x && \
    python3 -m pip --no-cache-dir install yt-dlp

VOLUME /config /downloads

WORKDIR /config

EXPOSE 8080/tcp

ENTRYPOINT ["/init"]
