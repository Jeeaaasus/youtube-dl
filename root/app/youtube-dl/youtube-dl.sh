#!/usr/bin/with-contenv bash

if $youtubedl_debug; then youtubedl_args_verbose=true; else youtubedl_args_verbose=false; fi
if grep -qiEe '--format ' "/config/args.conf"; then youtubedl_args_format=true; else youtubedl_args_format=false; fi
if grep -qiEe '--download-archive ' "/config/args.conf"; then youtubedl_args_downloadarchive=true; else youtubedl_args_downloadarchive=false; fi

if $youtubedl_completed && [ -f '/downloads/youtubedl-completed' ]
then
  rm '/downloads/youtubedl-completed'
fi

youtubedl_binary="yt-dlp"
exec=$youtubedl_binary
if $youtubedl_args_verbose; then exec+=" --verbose"; fi
if ! $youtubedl_args_downloadarchive; then exec+=" --download-archive /config/archive.txt"; fi
exec+=" --config-location /config/args.conf"
exec+=" --batch-file /config/channels.txt"

while ! [ -f "$(which $youtubedl_binary)" ]; do sleep 1s; done
sed -i -E 's!  *$!!; s!//*$!!; s!(youtube.*(channel|user|c))/([^/]+$)!\1/\3/videos!i' /config/channels.txt
youtubedl_version=$($youtubedl_binary --version)
youtubedl_last_run_time=$(date "+%s")

if $youtubedl_args_format; then $exec; else $exec --format "$(cat '/config.default/format')"; fi

if [ $(( ($(date "+%s") - $youtubedl_last_run_time) / 60 )) -ge 2 ]
then
  echo "$(date "+%Y-%m-%d %H:%M:%S") - execution took $(( ($(date "+%s") - $youtubedl_last_run_time) / 60 )) minutes"
else
  echo "$(date "+%Y-%m-%d %H:%M:%S") - execution took $(( ($(date "+%s") - $youtubedl_last_run_time) )) seconds"
fi

if $youtubedl_completed
then
  touch '/downloads/youtubedl-completed'
fi

echo "youtube-dl version: $youtubedl_version"
echo "waiting $youtubedl_interval.."
sleep $youtubedl_interval
date "+%Y-%m-%d %H:%M:%S"
