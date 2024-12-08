#!/bin/bash

while true; do
  touch '/tmp/updater-running'
  sleep 10s
  pip --no-cache-dir --quiet install --upgrade yt-dlp[default] > /dev/null
  rm -f '/tmp/updater-running'
  sleep 3h
done
