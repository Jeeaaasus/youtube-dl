FROM alpine:latest

ENV S6_BEHAVIOUR_IF_STAGE2_FAILS="2" \
    PUID="911" \
    PGID="911" \
    youtubedl_interval="3h" \
    youtubedl_quality="1080" \
    youtubedl_debug="false" \
    youtubedl_webui="false" \
    youtubedl_webuiport="8080" \
    youtubedl_lockfile="true"

RUN set -ex && \
    ARCH=`uname -m` && \
    if [ "$ARCH" == "x86_64" ]; then \
        s6_package="s6-overlay-amd64.tar.gz" \
    elif [ "$ARCH" == "aarch64" ]; then \
        s6_package="s6-overlay-aarch64.tar.gz" \
    else \
        echo "unknown arch" && \
        exit 1 \
    fi && \
    wget -P /tmp/ https://github.com/just-containers/s6-overlay/releases/latest/download/${s6_package} && \
    tar xzf /tmp/${s6_package} -C / && \
    rm -rf /tmp/*

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
        curl \
        gcompat \
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
    chmod a+x /usr/bin/sponskrub

RUN set -x && \
    wget https://github.com/yt-dlp/yt-dlp/releases/latest/download/yt-dlp -O /usr/bin/yt-dlp && \
    chmod a+x /usr/bin/yt-dlp

VOLUME /config /downloads

WORKDIR /config

ENTRYPOINT ["/init"]
