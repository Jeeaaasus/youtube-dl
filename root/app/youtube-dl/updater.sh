#!/usr/bin/with-contenv bash

touch '/tmp/updater-running'; sleep 1m
python3 -m pip --no-cache-dir --quiet install --upgrade yt-dlp > /dev/null
rm -f '/tmp/updater-running'
sleep 3h
