FROM debian:11-slim

ENV S6_BEHAVIOUR_IF_STAGE2_FAILS="2" \
    PUID="911" \
    PGID="911" \
    youtubedl_debug="false" \
    youtubedl_lockfile="false" \
    youtubedl_webui="false" \
    youtubedl_webuiport="8080" \
    youtubedl_cookies="false" \
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
        wget -q $(wget -q https://api.github.com/repos/nihil-admirari/FFmpeg-With-VP9-Timestamp-Fix/releases/latest -O - | grep -ioE 'https://github.com/nihil-admirari/FFmpeg-With-VP9-Timestamp-Fix/releases/download/.*?-linux64-nonfree.tar.xz') -O - | tar -xJ -C /tmp/ && \
        chmod -R a+x $(find /tmp/ffmpeg*/bin/ -type d) && \
        mv $(find /tmp/ffmpeg*/bin/ -type d)/* /usr/bin/ && \
        rm -rf /tmp/* ; \
    elif [ "$ARCH" = "aarch64" ]; then \
        apt update && \
        apt install -y \
            ffmpeg && \
        apt clean && \
        rm -rf \
            /var/lib/apt/lists/* \
            -rf /tmp/* ; \
    else \
        echo "unknown arch: ${ARCH}" && \
        exit 1 ; \
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
    wget -P /tmp/ https://github.com/just-containers/s6-overlay/releases/latest/download/${s6_package} && \
    tar -xzf /tmp/${s6_package} -C / && \
    rm -rf /tmp/*

RUN set -x && \
    wget https://github.com/yt-dlp/yt-dlp/releases/latest/download/yt-dlp -O /usr/bin/yt-dlp && \
    chmod a+x /usr/bin/yt-dlp

VOLUME /config /downloads

WORKDIR /config

ENTRYPOINT ["/init"]
