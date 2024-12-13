FROM debian:12-slim

ARG phantomjs_version="2.1.1"

ENV PATH="/home/abc/.venv/bin:$PATH" \
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
        --uid "$PUID" \
        --ingroup abc \
        --shell /bin/bash \
        abc

COPY root/app/requirements.txt /app/

RUN set -x && \
    apt update && \
    apt install -y \
        supervisor \
        file \
        wget \
        python3 \
        python3-venv \
        python3-pip && \
    apt clean && \
    python3 -m venv /home/abc/.venv && \
    /home/abc/.venv/bin/pip --no-cache-dir install -r /app/requirements.txt && \
    rm -rf \
        /var/lib/apt/lists/* \
        /tmp/*

COPY root/ /

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
    /home/abc/.venv/bin/pip --no-cache-dir install yt-dlp[default]

VOLUME /config /downloads

WORKDIR /config

EXPOSE 8080/tcp

CMD ["/entrypoint.sh"]
