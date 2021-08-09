#!/usr/bin/with-contenv bash

apk upgrade --no-cache > /dev/null
#update yt-dlp
/usr/bin/yt-dlp -U
sleep 3h
