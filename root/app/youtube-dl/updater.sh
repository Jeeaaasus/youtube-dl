#!/usr/bin/with-contenv bash

touch '/tmp/updater-running'
sleep 10s
python3 -m pip --no-cache-dir --quiet install --upgrade yt-dlp[default] > /dev/null
rm -f '/tmp/updater-running'
sleep 3h
