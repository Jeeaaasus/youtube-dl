#!/usr/bin/with-contenv bash

apk upgrade --no-cache > /dev/null
yt-dlp -U > /dev/null
sleep 3h
