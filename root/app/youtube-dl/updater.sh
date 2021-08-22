#!/usr/bin/with-contenv bash

apk upgrade --no-cache > /dev/null
yt-dlp -U
sleep 3h
