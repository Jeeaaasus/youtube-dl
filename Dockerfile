FROM debian:11-slim

ARG s6_version="v2.2.0.3"
ARG phantomjs_version="2.1.1"

ENV S6_BEHAVIOUR_IF_STAGE2_FAILS="2" \
    PUID="911" \
    PGID="911" \
    UMASK="022" \
    youtubedl_debug="false" \
    youtubedl_lockfile="false" \
    youtubedl_webui="false" \
    youtubedl_webuiport="8080" \
    youtubedl_subscriptions="false" \
    youtubedl_watchlater="false" \
    youtubedl_interval="3h" \
    youtubedl_quality="1080" \
    OPENSSL_CONF=

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
        file \
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
    arch=`uname -m` && \
    if [ "$arch" = "x86_64" ]; then \
        s6_package="s6-overlay-amd64.tar.gz" ; \
    elif [ "$arch" = "aarch64" ]; then \
        s6_package="s6-overlay-aarch64.tar.gz" ; \
    else \
        echo "unknown arch: ${arch}" && \
        exit 1 ; \
    fi && \
    wget -P /tmp/ https://github.com/just-containers/s6-overlay/releases/download/${s6_version}/${s6_package} && \
    tar -xzf /tmp/${s6_package} -C / && \
    rm -rf /tmp/*

RUN set -x && \
    arch=`uname -m` && \
    if [ "$arch" = "x86_64" ]; then \
        wget https://bitbucket.org/ariya/phantomjs/downloads/phantomjs-${phantomjs_version}-linux-${arch}.tar.bz2 && \
        tar -xf phantomjs-${phantomjs_version}-linux-${arch}.tar.bz2 && \
        mv phantomjs-${phantomjs_version}-linux-${arch}/bin/phantomjs /usr/bin/ && \
        rm -rf phantomjs-* ; \
    fi

RUN set -x && \
    arch=`uname -m` && \
    if [ "$arch" = "x86_64" ]; then \
        wget -q 'https://github.com/yt-dlp/FFmpeg-Builds/releases/download/latest/ffmpeg-master-latest-linux64-gpl.tar.xz' -O - | tar -xJ -C /tmp/ --one-top-level=ffmpeg && \
        chmod -R a+x /tmp/ffmpeg/* && \
        mv $(find /tmp/ffmpeg/* -name ffmpeg) /usr/local/bin/ && \
        mv $(find /tmp/ffmpeg/* -name ffprobe) /usr/local/bin/ && \
        mv $(find /tmp/ffmpeg/* -name ffplay) /usr/local/bin/ && \
        rm -rf /tmp/* ; \
    else \
        if [ "$arch" = "aarch64" ]; then arch='arm64'; fi && \
        wget -q "https://johnvansickle.com/ffmpeg/builds/ffmpeg-git-${arch}-static.tar.xz" -O - | tar -xJ -C /tmp/ --one-top-level=ffmpeg && \
        chmod -R a+x /tmp/ffmpeg/* && \
        mv $(find /tmp/ffmpeg/* -name ffmpeg) /usr/local/bin/ && \
        mv $(find /tmp/ffmpeg/* -name ffprobe) /usr/local/bin/ && \
        rm -rf /tmp/* ; \
    fi

RUN set -x && \
    python3 -m pip --no-cache-dir install yt-dlp[default]

VOLUME /config /downloads

WORKDIR /config

EXPOSE 8080/tcp

ENTRYPOINT ["/init"]
