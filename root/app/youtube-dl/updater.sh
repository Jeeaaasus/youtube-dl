#!/usr/bin/with-contenv bash

touch '/app/updater-running'; sleep 1m
yt-dlp -U > /dev/null
rm -f '/app/updater-running'
sleep 3h
