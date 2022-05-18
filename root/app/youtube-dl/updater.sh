#!/usr/bin/with-contenv bash

touch '/app/updater-running'; sleep 1m
python3 -m pip --no-cache-dir --quiet install --upgrade yt-dlp > /dev/null
rm -f '/app/updater-running'
sleep 3h
